# DEFCON BUBBLE operating law

## Authority

The owner has final product authority. ChatGPT serves as Game Director/Integrator. External agents such as Antigravity are bounded workers unless an exact task explicitly grants broader authority.

## New-chat recovery protocol

1. Resolve live GitHub truth first: repository, `main` HEAD, relevant open PRs/branches, and CI state.
2. Read `AGENT_CONTEXT.md` for stable project identity and laws.
3. Read `docs/ACTIVE_HANDOFF.md` for the current bounded milestone and immediate execution state.
4. Read `docs/DIRECTORS_NOTES.md` for current strategic intent, cautions, taste, and the reasoning that should survive chat boundaries.
5. Read `docs/MOBILE_FIRST.md` when the task touches controls, UI, rendering, performance, platform behavior, preview delivery, or player acceptance.
6. Read the relevant decision/system docs for the task.
7. Pull deeper Google Drive design truth when the task depends on creative direction or a locked project decision not mirrored in-repo.
8. Reconcile before acting. Live GitHub state wins for implementation facts; recorded decisions win for locked design law; Director's Notes guide judgment but do not override either.
9. Work only inside the assigned scope and run the required proof before reporting completion.

Do not infer repository state from repository-size metadata, an old handoff, or chat memory when GitHub can answer directly.

## Context roles

- `AGENT_CONTEXT.md`: stable identity, game laws, technical baseline.
- `docs/ACTIVE_HANDOFF.md`: current milestone, scope boundaries, immediate next move.
- `docs/DIRECTORS_NOTES.md`: compact Game Director interpretation, current emphasis, risks, and intent that would otherwise be lost between chats.
- `docs/MOBILE_FIRST.md`: durable mobile product and engineering law.
- `docs/DECISIONS.md`: durable implementation decisions.
- `docs/SYSTEM_MAP.md`: current ownership and architecture map.

## Director's Notes law

Director's Notes are required recovery context, but they must stay lightweight. Record strategic nuance that materially changes how the next session should steer the work. Do not duplicate GitHub status, large diffs, CI logs, or settled decisions. Promote settled decisions into `docs/DECISIONS.md`; keep transient implementation state in `docs/ACTIVE_HANDOFF.md`; prune notes that no longer affect judgment.

## Branch law

After Foundation 0, `main` must remain buildable. Meaningful work occurs on focused `agent/<task>` branches. A worker does not self-merge or self-promote a candidate.

## Mobile product law

- DEFCON BUBBLE is a native mobile-first game. The phone is the product target, not a later port target.
- Desktop is for authoring, debugging, profiling, automation, and fast iteration. Desktop behavior is not the final authority for touch controls, readability, lifecycle behavior, or performance.
- Web builds are rapid-access previews that should map to an exact reviewable source revision. Web hosting must stay replaceable and outside gameplay architecture.
- Preserve the full beach-war fantasy. Mobile constraints are solved with measured budgets, scalable presentation, staging, and platform-aware engineering rather than automatic feature retreat.
- Do not silently lock the initial native storefront/platform order. Record that choice when evidence and product intent support it.

## Code law

- Prefer typed GDScript and typed signals.
- Prefer composition and explicit contracts over deep inheritance.
- Keep responsibilities small and ownership obvious.
- Use Resources and stable IDs for expandable content.
- Use named input actions and named collision layers.
- Keep platform input adapters separate from gameplay authority. Touch UI requests player intent; it does not own combat rules.
- Keep gameplay frame-rate independent.
- Avoid magic coordinates and magic layer numbers in gameplay code.
- Avoid arbitrary absolute scene-tree paths across system boundaries.
- Use semantic anchors such as `[DB:CASTLE:CHUNK]` where searchability has real value.
- Anchors are navigation infrastructure, not substitute architecture.

## Performance law

- Mobile performance is a design constraint from the start, but optimize from measurements rather than superstition.
- Establish concrete frame-time, memory, thermal, draw-call, physics, audio, and effect budgets as target devices are selected.
- Prefer scalable presentation quality that preserves gameplay truth.
- Pool, batch, simplify, or reduce effects only when profiling or a known platform constraint justifies it.
- Never let a quality tier alter authoritative gameplay outcomes.

## Dependency law

New addons, packages, fonts, libraries, native extensions, services, and asset sources require a reason, provenance/license record, and an exit strategy. Prefer Godot built-ins and project code when they solve the problem cleanly.

## Secret law

Never commit API keys, tokens, signing secrets, credentials, or private environment files. Protected automation owns credentials.

## Acceptance law

Worker completion is not Game Director acceptance. Green CI is not player acceptance. Every milestone needs the proof appropriate to its risk: automated checks, code review, visual evidence, hands-on play, and mobile-device evidence when player-facing phone behavior is materially involved.
