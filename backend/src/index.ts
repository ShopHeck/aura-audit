export interface Env {
  DB: D1Database;
  CONFIG_KV: KVNamespace;
  SHARE_CARDS: R2Bucket;
  OPENAI_API_KEY: string;
  APP_SHARED_SECRET: string;
  AI_GATEWAY_URL: string;
  OPENAI_MODEL: string;
  APP_ENV: string;
}

type AuditMode = "classic" | "dating" | "linkedin" | "group_chat" | "villain" | "main_character" | "red_flag" | "npc";

type AuditRequest = {
  installId: string;
  mode: AuditMode;
  imageBase64: string;
  imageMimeType: "image/jpeg" | "image/png" | "image/heic";
};

type AuditResult = {
  mode: AuditMode;
  auraScore: number;
  mainCharacterEnergy: number;
  chaosIndex: number;
  npcRisk: number;
  groupChatSurvival: number;
  title: string;
  verdict: string;
  roasts: string[];
  warnings: string[];
  shareCaption: string;
};

const MODES: Array<{ id: AuditMode; name: string; premium: boolean; description: string }> = [
  { id: "classic", name: "Classic Aura Audit", premium: false, description: "The default fictional vibe tribunal." },
  { id: "dating", name: "Dating App Audit", premium: true, description: "Playful dating profile energy, never attractiveness scoring." },
  { id: "linkedin", name: "LinkedIn Aura Audit", premium: true, description: "Corporate cringe and networking aura." },
  { id: "group_chat", name: "Group Chat Audit", premium: true, description: "Survival odds in a chaotic group chat." },
  { id: "villain", name: "Villain Origin Audit", premium: true, description: "Comedic villain arc energy." },
  { id: "main_character", name: "Main Character Audit", premium: true, description: "Main character energy diagnosis, fictionally." },
  { id: "red_flag", name: "Red Flag Audit", premium: true, description: "Absurd fictional red flags, not real judgments." },
  { id: "npc", name: "NPC Risk Assessment", premium: true, description: "Internet-native NPC risk comedy." }
];

const BLOCKED_TERMS = [
  "ugly", "fat", "obese", "skinny", "punchable", "slappable", "kill", "die", "stupid", "dumb",
  "nose", "teeth", "forehead", "hairline", "skin", "acne", "wrinkles", "hot or not", "sexy",
  "race", "ethnicity", "disabled", "autistic", "depressed", "bipolar", "criminal", "dangerous"
];

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization,X-Aura-App-Secret"
};

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    const url = new URL(request.url);

    try {
      if (url.pathname === "/v1/health" && request.method === "GET") {
        return json({ ok: true, environment: env.APP_ENV ?? "unknown" });
      }

      if (url.pathname === "/v1/modes" && request.method === "GET") {
        return json({ modes: MODES });
      }

      if (url.pathname === "/v1/audits" && request.method === "POST") {
        await requireAppSecret(request, env);
        return await createAudit(request, env);
      }

      if (url.pathname === "/v1/entitlements/sync" && request.method === "POST") {
        await requireAppSecret(request, env);
        return await syncEntitlements(request, env);
      }

      if (url.pathname === "/v1/report" && request.method === "POST") {
        return await reportSafetyIssue(request, env);
      }

      return json({ error: "Not found" }, 404);
    } catch (error) {
      const message = error instanceof HttpError ? error.message : "Unexpected server error";
      const status = error instanceof HttpError ? error.status : 500;
      return json({ error: message }, status);
    }
  }
};

async function createAudit(request: Request, env: Env): Promise<Response> {
  const body = await safeJson<AuditRequest>(request);
  validateAuditRequest(body);

  const mode = MODES.find((item) => item.id === body.mode);
  if (!mode) throw new HttpError(400, "Unknown audit mode");

  await ensureInstall(env, body.installId);
  const premium = await hasPremium(env, body.installId);

  if (mode.premium && !premium) {
    throw new HttpError(402, "Premium mode locked");
  }

  if (!premium) {
    await enforceDailyLimit(env, body.installId, 1);
  }

  const result = await generateAudit(env, body);
  const safeResult = enforceSafety(result);

  const auditId = crypto.randomUUID();
  const now = new Date().toISOString();

  await env.DB.prepare(
    `INSERT INTO audits (
      id, install_id, mode, aura_score, main_character_energy, chaos_index, npc_risk,
      group_chat_survival, title, verdict, roasts_json, warnings_json, share_caption, created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
  ).bind(
    auditId,
    body.installId,
    safeResult.mode,
    safeResult.auraScore,
    safeResult.mainCharacterEnergy,
    safeResult.chaosIndex,
    safeResult.npcRisk,
    safeResult.groupChatSurvival,
    safeResult.title,
    safeResult.verdict,
    JSON.stringify(safeResult.roasts),
    JSON.stringify(safeResult.warnings),
    safeResult.shareCaption,
    now
  ).run();

  return json({ auditId, result: safeResult });
}

async function generateAudit(env: Env, body: AuditRequest): Promise<AuditResult> {
  const prompt = buildPrompt(body.mode);
  const imageDataUrl = `data:${body.imageMimeType};base64,${body.imageBase64}`;

  const response = await fetch(`${env.AI_GATEWAY_URL}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${env.OPENAI_API_KEY}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: env.OPENAI_MODEL || "gpt-4.1-mini",
      messages: [
        {
          role: "system",
          content: prompt
        },
        {
          role: "user",
          content: [
            {
              type: "text",
              text: "Generate an Aura Audit for this selfie. Keep it fictional, playful, and safe. Return only JSON."
            },
            {
              type: "image_url",
              image_url: { url: imageDataUrl }
            }
          ]
        }
      ],
      response_format: {
        type: "json_schema",
        json_schema: {
          name: "aura_audit_result",
          strict: true,
          schema: auditJsonSchema()
        }
      },
      temperature: 0.9,
      max_tokens: 800
    })
  });

  if (!response.ok) {
    throw new HttpError(502, `AI request failed: ${response.status}`);
  }

  const data = await response.json() as { choices?: Array<{ message?: { content?: string } }> };
  const content = data.choices?.[0]?.message?.content;
  if (!content) throw new HttpError(502, "AI returned no content");

  let parsed: AuditResult;
  try {
    parsed = JSON.parse(content) as AuditResult;
  } catch {
    throw new HttpError(502, "AI returned invalid JSON");
  }

  validateAuditResult(parsed, body.mode);
  return parsed;
}

function buildPrompt(mode: AuditMode): string {
  return `You are Aura Audit, a fictional entertainment app that creates playful vibe reports from selfies.

Mode: ${mode}

Safety rules:
- Roast vibes, not bodies.
- Never mention body parts, attractiveness, weight, skin, age, race, gender, sexuality, disability, religion, health, mental health, intelligence, criminality, violence, or real-world trustworthiness.
- Do not identify the person.
- Do not infer protected traits.
- Do not say "ugly", "hot", "punchable", "slappable", or anything violent.
- Keep it funny, absurd, internet-native, and consent-friendly.
- Treat every score as fictional entertainment, not a real evaluation.

Style examples:
Allowed: "You give 'forgot to reply but watched every story' energy."
Allowed: "Main character energy, but the plot is buffering."
Blocked: "Your nose looks weird."
Blocked: "You look untrustworthy."

Return exactly the requested JSON schema.`;
}

function auditJsonSchema() {
  return {
    type: "object",
    additionalProperties: false,
    required: [
      "mode", "auraScore", "mainCharacterEnergy", "chaosIndex", "npcRisk",
      "groupChatSurvival", "title", "verdict", "roasts", "warnings", "shareCaption"
    ],
    properties: {
      mode: { type: "string", enum: MODES.map((mode) => mode.id) },
      auraScore: { type: "integer", minimum: 1, maximum: 100 },
      mainCharacterEnergy: { type: "integer", minimum: 1, maximum: 100 },
      chaosIndex: { type: "integer", minimum: 1, maximum: 100 },
      npcRisk: { type: "integer", minimum: 1, maximum: 100 },
      groupChatSurvival: { type: "integer", minimum: 1, maximum: 100 },
      title: { type: "string", minLength: 3, maxLength: 60 },
      verdict: { type: "string", minLength: 20, maxLength: 180 },
      roasts: {
        type: "array",
        minItems: 3,
        maxItems: 3,
        items: { type: "string", minLength: 10, maxLength: 120 }
      },
      warnings: {
        type: "array",
        minItems: 2,
        maxItems: 2,
        items: { type: "string", minLength: 10, maxLength: 120 }
      },
      shareCaption: { type: "string", minLength: 20, maxLength: 120 }
    }
  };
}

function enforceSafety(result: AuditResult): AuditResult {
  const allText = [
    result.title,
    result.verdict,
    ...result.roasts,
    ...result.warnings,
    result.shareCaption
  ].join(" ").toLowerCase();

  const unsafe = BLOCKED_TERMS.some((term) => allText.includes(term));
  if (!unsafe) return clampScores(result);

  return {
    mode: result.mode,
    auraScore: 77,
    mainCharacterEnergy: 84,
    chaosIndex: 61,
    npcRisk: 18,
    groupChatSurvival: 42,
    title: "Vibe Tribunal Redirected",
    verdict: "The tribunal got too spicy, so your official aura is chaotic, camera-ready, and legally safer than the first draft.",
    roasts: [
      "Your aura has read receipts off emotionally.",
      "Main character energy, but the plot is buffering.",
      "You look like brunch could become a brand strategy meeting."
    ],
    warnings: [
      "May overthink a thumbs-up reaction.",
      "Could accidentally turn a casual update into a full rebrand."
    ],
    shareCaption: "My Aura Audit got legally rerouted and I still feel exposed."
  };
}

function clampScores(result: AuditResult): AuditResult {
  return {
    ...result,
    auraScore: clamp(result.auraScore),
    mainCharacterEnergy: clamp(result.mainCharacterEnergy),
    chaosIndex: clamp(result.chaosIndex),
    npcRisk: clamp(result.npcRisk),
    groupChatSurvival: clamp(result.groupChatSurvival)
  };
}

function clamp(value: number): number {
  if (!Number.isFinite(value)) return 50;
  return Math.max(1, Math.min(100, Math.round(value)));
}

async function syncEntitlements(request: Request, env: Env): Promise<Response> {
  const body = await safeJson<{ installId: string; productId: string; transactionId?: string; lifetimePremium?: boolean; premiumUntil?: string }>(request);
  if (!body.installId || !body.productId) throw new HttpError(400, "installId and productId are required");

  await ensureInstall(env, body.installId);

  const lifetime = body.lifetimePremium ? 1 : 0;
  const premiumUntil = body.premiumUntil ?? null;

  await env.DB.prepare(
    "UPDATE installs SET lifetime_premium = ?, premium_until = ?, last_seen_at = ? WHERE id = ?"
  ).bind(lifetime, premiumUntil, new Date().toISOString(), body.installId).run();

  await env.DB.prepare(
    "INSERT INTO entitlement_events (id, install_id, product_id, transaction_id, event_type, created_at) VALUES (?, ?, ?, ?, ?, ?)"
  ).bind(
    crypto.randomUUID(),
    body.installId,
    body.productId,
    body.transactionId ?? null,
    "sync",
    new Date().toISOString()
  ).run();

  return json({ ok: true, isPremium: lifetime === 1 || Boolean(premiumUntil) });
}

async function reportSafetyIssue(request: Request, env: Env): Promise<Response> {
  const body = await safeJson<{ auditId?: string; reason?: string; message?: string }>(request);
  await env.DB.prepare(
    "INSERT INTO safety_reports (id, audit_id, reason, message, created_at) VALUES (?, ?, ?, ?, ?)"
  ).bind(
    crypto.randomUUID(),
    body.auditId ?? null,
    body.reason ?? "unspecified",
    body.message ?? "",
    new Date().toISOString()
  ).run();
  return json({ ok: true });
}

async function ensureInstall(env: Env, installId: string): Promise<void> {
  const now = new Date().toISOString();
  await env.DB.prepare(
    "INSERT INTO installs (id, created_at, last_seen_at) VALUES (?, ?, ?) ON CONFLICT(id) DO UPDATE SET last_seen_at = excluded.last_seen_at"
  ).bind(installId, now, now).run();
}

async function hasPremium(env: Env, installId: string): Promise<boolean> {
  const row = await env.DB.prepare(
    "SELECT lifetime_premium, premium_until FROM installs WHERE id = ?"
  ).bind(installId).first<{ lifetime_premium: number; premium_until: string | null }>();

  if (!row) return false;
  if (row.lifetime_premium === 1) return true;
  if (!row.premium_until) return false;
  return new Date(row.premium_until).getTime() > Date.now();
}

async function enforceDailyLimit(env: Env, installId: string, maxFreeAudits: number): Promise<void> {
  const date = new Date().toISOString().slice(0, 10);
  const id = `${installId}:${date}`;

  const row = await env.DB.prepare(
    "SELECT audit_count FROM daily_usage WHERE install_id = ? AND usage_date = ?"
  ).bind(installId, date).first<{ audit_count: number }>();

  if (row && row.audit_count >= maxFreeAudits) {
    throw new HttpError(429, "Daily free audit limit reached");
  }

  await env.DB.prepare(
    `INSERT INTO daily_usage (id, install_id, usage_date, audit_count)
     VALUES (?, ?, ?, 1)
     ON CONFLICT(install_id, usage_date)
     DO UPDATE SET audit_count = audit_count + 1`
  ).bind(id, installId, date).run();
}

async function requireAppSecret(request: Request, env: Env): Promise<void> {
  const received = request.headers.get("X-Aura-App-Secret");
  if (!received || received !== env.APP_SHARED_SECRET) {
    throw new HttpError(401, "Unauthorized");
  }
}

function validateAuditRequest(body: AuditRequest): void {
  if (!body.installId || body.installId.length < 8) throw new HttpError(400, "Invalid installId");
  if (!body.mode) throw new HttpError(400, "mode is required");
  if (!body.imageBase64 || body.imageBase64.length < 1000) throw new HttpError(400, "imageBase64 is required");
  if (body.imageBase64.length > 8_000_000) throw new HttpError(413, "Image is too large");
  if (!["image/jpeg", "image/png", "image/heic"].includes(body.imageMimeType)) throw new HttpError(400, "Unsupported image type");
}

function validateAuditResult(result: AuditResult, expectedMode: AuditMode): void {
  if (result.mode !== expectedMode) throw new HttpError(502, "AI returned wrong mode");
  for (const key of ["auraScore", "mainCharacterEnergy", "chaosIndex", "npcRisk", "groupChatSurvival"] as const) {
    if (!Number.isFinite(result[key])) throw new HttpError(502, `AI result missing ${key}`);
  }
  if (!result.title || !result.verdict || !result.shareCaption) throw new HttpError(502, "AI result missing text fields");
  if (!Array.isArray(result.roasts) || result.roasts.length !== 3) throw new HttpError(502, "AI result needs 3 roasts");
  if (!Array.isArray(result.warnings) || result.warnings.length !== 2) throw new HttpError(502, "AI result needs 2 warnings");
}

async function safeJson<T>(request: Request): Promise<T> {
  try {
    return await request.json() as T;
  } catch {
    throw new HttpError(400, "Invalid JSON body");
  }
}

function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...CORS_HEADERS
    }
  });
}

class HttpError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}
