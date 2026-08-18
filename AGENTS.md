# DEFCON BUBBLE operating law

## Authority

The owner has final product authority. ChatGPT serves as Game Director/Integrator. External agents such as Antigravity are bounded workers unless an exact task explicitly grants broader authority.

## New-chat recovery protocol

1. Resolve live GitHub truth first: repository, `main` HEAD, relevant open PRs/branches, and CI state.
2. Read `AGENT_CONTEXT.md` for stable project identity and laws.
3. Read `docs/ACTIVE_HANDOFF.md` for the current bounded milestone and immediate execution state.
4. Read `docs/DIRECTORS_NOTES.md` for current strategic intent, cautions, taste, and the reasoning that should survive chat boundaries.
5. Read the relevant decision/system docs for the task.
6. Pull deeper Google Drive design truth when the task depends on creative direction or a locked project decision not mirrored in-repo.
7. Reconcile before acting. Live GitHub state wins for implementation facts; recorded decisions win for locked design law; Director's Notes guide judgment but do not override either.
8. Work only inside the assigned scope and run the required proof before reporting completion.

Do not infer repository state from repository-size metadata, an old handoff, or chat memory when GitHub can answer directly.

## Context roles

- `AGENT_CONTEXT.md`: stable identity, game laws, technical baseline.
- `docs/ACTIVE_HANDOFF.md`: current milestone, scope boundaries, immediate next move.
- `docs/DIRECTORS_NOTES.md`: compact Game Director interpretation, current emphasis, risks, and intent that would otherwise be lost between chats.
- `docs/DECISIONS.md`: durable implementation decisions.
- `docs/SYSTEM_MAP.md`: current ownership and architecture map.

## Director's Notes law

Director's Notes are required recovery context, but they must stay lightweight. Record strategic nuance that materially changes how the next session should steer the work. Do not duplicate GitHub status, large diffs, CI logs, or settled decisions. Promote settled decisions into `docs/DECISIONS.md`; keep transient implementation state in `docs/ACTIVE_HANDOFF.md`; prune notes that no longer affect judgment.

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
