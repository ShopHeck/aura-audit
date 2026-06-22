# Aura Audit Starter

Aura Audit is an iOS-first viral entertainment app where users upload a selfie and receive a fictional, funny vibe report with a shareable result card.

This starter includes:

- SwiftUI source scaffold for the iOS app.
- Cloudflare Worker backend with D1 schema.
- OpenAI-through-Cloudflare-AI-Gateway integration.
- Safety prompt and blocked-term fallback.
- StoreKit 2 entitlement scaffold.
- Ad placeholder for later AdMob integration.
- Cloudflare Pages-ready privacy, terms, support, and landing pages.
- App Store review notes and roadmap.

## Architecture

```txt
Aura Audit iOS App
  -> Cloudflare Worker API
    -> D1 for installs, audits, entitlements, usage limits
    -> KV for config and prompts
    -> R2 for optional share cards
    -> AI Gateway for OpenAI calls
      -> OpenAI API
```

## Backend setup

```bash
cd backend
npm install
cp wrangler.toml.example wrangler.toml
```

Create Cloudflare resources:

```bash
wrangler d1 create aura_audit_d1
wrangler kv namespace create CONFIG_KV
wrangler r2 bucket create aura-audit-sharecards-r2
```

Update `wrangler.toml` with the IDs returned by Cloudflare.

Set secrets:

```bash
wrangler secret put OPENAI_API_KEY
wrangler secret put APP_SHARED_SECRET
```

Run migrations:

```bash
npm run db:migrate:local
npm run dev
```

Deploy:

```bash
npm run db:migrate:prod
npm run deploy
```

## iOS setup

1. Create a new Xcode iOS app named `AuraAudit`.
2. Copy `ios/AuraAudit` into the Xcode project.
3. Set minimum iOS target to 17.0 for the prototype.
4. Add privacy strings for Camera and Photos.
5. Replace the API URL and shared secret in `APIClient.swift`.
6. Add StoreKit product `app.auraaudit.premium.lifetime` in App Store Connect.
7. Add Google Mobile Ads SDK after the core app compiles.

## App Store safety stance

Aura Audit must stay framed as fictional entertainment.

Do not add:

- beauty ranking
- public voting
- public feeds
- face leaderboards
- punchable/slappable/violent language
- body-part insults
- claims about identity, health, intelligence, criminality, or real personality

## Next implementation tasks

1. Create Xcode project and confirm the SwiftUI scaffold compiles.
2. Deploy Worker with mocked health/modes routes.
3. Connect the iOS app to the Worker.
4. Test real audit generation with safe prompt outputs.
5. Add StoreKit product and AdMob placements.
# aura-audit
