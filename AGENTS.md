# DEFCON BUBBLE operating law

## Authority

The owner has final product authority. ChatGPT serves as Game Director/Integrator. External agents such as Antigravity are bounded workers unless an exact task explicitly grants broader authority.

## Startup order

1. Read `AGENT_CONTEXT.md`.
2. Read `docs/ACTIVE_HANDOFF.md`.
3. Read the relevant system/decision docs.
4. Inspect exact repository state and base SHA.
5. Work only inside the assigned scope.
6. Run required proof before reporting completion.

## Branch law

After Foundation 0, `main` must remain buildable. Meaningful work occurs on focused `agent/<task>` branches. A worker does not self-merge or self-promote a candidate.

## Code law

- Prefer typed GDScript and typed signals.
- Prefer composition and explicit contracts over deep inheritance.
- Keep responsibilities small and ownership obvious.
- Use Resources and stable IDs for expandable content.
- Use named input actions and named collision layers.
- Avoid magic coordinates and magic layer numbers in gameplay code.
- Avoid arbitrary absolute scene-tree paths across system boundaries.
- Use semantic anchors such as `[DB:CASTLE:CHUNK]` where searchability has real value.
- Anchors are navigation infrastructure, not substitute architecture.

## Dependency law

New addons, packages, fonts, libraries, native extensions, services, and asset sources require a reason, provenance/license record, and an exit strategy. Prefer Godot built-ins and project code when they solve the problem cleanly.

## Secret law

Never commit API keys, tokens, signing secrets, credentials, or private environment files. Protected automation owns credentials.

## Acceptance law

Worker completion is not Game Director acceptance. Green CI is not player acceptance. Every milestone needs the proof appropriate to its risk: automated checks, code review, visual evidence, and/or hands-on play.
