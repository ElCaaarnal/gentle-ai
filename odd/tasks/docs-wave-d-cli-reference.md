# docs-wave-d-cli-reference

Issue: #5221 (tracker #4556). Branch: `docs/5221-cli-telemetry-arch` from upstream/main 5d449e52 (includes v4.0.0).
Goal: align CLI reference, telemetry and architecture docs with the code on main. Docs only; no Go changes.

## Specs

- S1 `docs/usage.md`: "Remove the `--strict-tdd` row and add one line saying it was retired in v4.0.0." Evidence: `internal/cli/sync.go:213-227` rejects the flag.
- S2 `docs/usage.md` + `docs/non-interactive.md`: "Add the missing install and sync flags and env vars" — install (`internal/cli/install.go:67-69`): `--channel`, `--opencode-background-subagents`, `--pi-background-subagents`; sync (`internal/cli/sync.go:189-192`): the same background-subagent flags and `--scope`; env vars `GENTLE_AI_CHANNEL`, `GENTLE_AI_*_BACKGROUND_SUBAGENTS`. Values and defaults must match the code.
- S3 `docs/usage.md`: "add a short "Other commands" table that links to the existing docs (`rollback.md`, `telemetry.md`, `review-integration.md`, `skill-registry.md`)" covering `restore`, `telemetry`, `review`, `codegraph`, `skill-registry list`, `uninstall opencode-plugin` (`internal/app/app.go:103-154`); drop the stale "changed in v1.x slice 5" marker.
- S4 `docs/trigger-rules.md`: "Rewrite the `trigger-rules.md` paragraph: file count never decides the route, and high risk adds an independent verifier without changing task size." Evidence: `internal/components/agentguidance/routing.go:55,91` (commit 66399a57).
- S5 `docs/telemetry.md`: "Drop "unreleased" from `telemetry.md:30`, and reword the SDD contrast at line 264." The aggregate schema was added in 3f5d1e73, contained in v4.0.0. Keep `sdd-*` agent classes at 117,121 but label them legacy (`aggregate.schema.json:54`).
- S6 `docs/architecture.md`: "Refresh the adapter and component lists in `architecture.md`, and point to `docs/agents.md` instead of listing every agent inline." Component tree must match `internal/components/*` on main.
- S7 `docs/review-integration.md`: "Document `--escalate-item` and `--escalate-reason`." Evidence: `internal/cli/review_assess.go:314-315`.
- S8 "Update the 11 banners to v4.0.0": `docs/codebase/{dashboard,integrations,interfaces,maintainer-playbook,memory-core,mental-model,reference-map,repository-map,sync-and-cloud}.md`, `docs/architecture/{organic-rdd,guard-population}.md`.
- Out of scope: README.md and entry docs (wave F), `docs/audits/`, `docs/releases/`. Diff budget: under 400 lines (estimate 130-170).

## Tasks

- [ ] T1 S1-S3 CLI reference (usage.md, non-interactive.md) — route: delegated writer — commit: 
- [ ] T2 S4-S5,S7 Behavior docs (trigger-rules.md, telemetry.md, review-integration.md) — route: delegated writer — commit: 
- [ ] T3 S6,S8 Architecture and banners (architecture.md, 11 banners) — route: delegated writer — commit: 
- [ ] T4 Verify all S#, RDD review (sync fork main first), PR saying "issue 4556" in plain text, #4556 comment — route: verifier + parent — commit: n/a

## Log

- L1 (user, 2026-10-03): "Retomá la wave D de docs (tracker #4556) desde el handoff odd/docs-wave-d/handoff"
- L2 (user): approved the issue draft ("adelante"); #5221 created; user applied status:approved and type:docs ("Listo").
- L3 (evidence): explorer musvh21t-1-kvvj report; seed 2 resolved by parent (`git tag --contains 3f5d1e73` → v4.0.0).
