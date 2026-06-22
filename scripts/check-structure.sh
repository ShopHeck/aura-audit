#!/usr/bin/env bash
set -euo pipefail

test -f backend/src/index.ts
test -f backend/migrations/0001_initial.sql
test -f ios/AuraAudit/App/AuraAuditApp.swift
test -f ios/AuraAudit/Features/Audit/HomeView.swift
test -f web/pages/privacy.html
test -f docs/app-store-review-notes.md

echo "Aura Audit starter structure looks good."
