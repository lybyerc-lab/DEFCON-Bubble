# Active handoff

## Recovery rule

Resolve live GitHub state first. Then read `AGENT_CONTEXT.md`, this handoff, `docs/DIRECTORS_NOTES.md`, and `docs/MOBILE_FIRST.md` before acting on player-facing or platform work.

Do not assume this file's PR numbers or branch state are current. Verify them live.

## Canonical baseline

Accepted on `main`:
- `[DB:COMBAT:POP]` at `98ce22ed5f119bbb9d4adfc3f72e8468b1aafe58`
- `[DB:CASTLE:IMPACT]` at `10cb2f20446c759dfa62a1303483552634fddda4`
- `[DB:WAVE:FIRST_DEFENSE]` at `306f7a8c94fe55e17b7dd29850f9f327211ccb9c`
- `[DB:ENCOUNTER:MIXED_THREE_WAVE]` at `942083789e8d7dc4c61e9aad78757d95eb083451`

The shared damage boundary remains `DamageRequest` -> `DamageReceiver` -> target-owned outcome. Native mobile is the product target, desktop is development/automation, and Web Compatibility is the rapid phone review surface.

The phone-accepted mixed encounter establishes Basic/Brute, Fast/Runner, Heavy/Big Blub, one persistent two-health CastleChunk, roof-fired toothpicks, three authored escalating waves, readable intermissions/terminal states, pristine RETRY, and a presentation-only `BeachEnvironment`.

## Current bounded milestone

`[DB:UPGRADE:FIRST_CHOICE]`

### Player-facing question

After surviving Wave 1, does one tiny between-wave choice between **more popping power** and **more castle durability** make the next waves feel obviously different and worth choosing on a phone?

### Exact proof

Wave 1 clear enters the accepted INTERMISSION state, then the upgrade authority holds its 2.25-second clock until exactly one stable-ID choice is made:

- **SKEWER** (`upgrade:weapon:skewer`)
  - +1 damage to newly fired toothpicks for the rest of the run
  - base 1 damage becomes 2
  - projectile silhouette becomes 1.55x longer
  - five-health Big Blub therefore requires three Skewer hits instead of five base hits

- **SHELL REINFORCEMENT** (`upgrade:defense:shell_reinforcement`)
  - +1 maximum and current CastleChunk durability
  - the two-health castle becomes three-health without erasing any existing damage history
  - pale shell bands are presentation-only evidence of the added protection

After the choice, the authored 2.25-second intermission starts and the existing Wave 2 / Wave 3 schedules proceed unchanged.

### Ownership

- `UpgradeDefinition` is data only and owns stable ID/display/tunable effect values.
- `FirstUpgradeChoice` owns this one run-scoped decision, the selected stable ID, and the narrow gameplay effect application.
- `MixedEncounter` gains only a generic hold/release seam for its existing intermission clock; it still owns wave progression.
- `ToothpickProjectile` owns its configured damage request and travel; upgrade state does not own hits or POP.
- `CastleChunk` owns added durability and all subsequent damage/destruction truth.
- Upgrade HUD renders definitions and sends stable choice IDs; it owns no effect.
- Castle and Skewer visuals remain presentation-only.

### Phone acceptance target

- Wave 1 clear visibly presents two large, readable choices without accidental FIRE input behind the overlay.
- The choice waits for the player rather than timing out.
- SKEWER is visually longer and makes Big Blub's reduced hit count obvious.
- SHELL REINFORCEMENT immediately changes the HUD to `CASTLE: 3 / 3` when chosen at full health and visibly adds shell armor bands.
- Only one upgrade can be taken per run.
- Wave 2 and FINAL PUSH retain their accepted timing, enemy behavior, POP, damage, win/loss, and RETRY contracts.
- RESET/RETRY starts a pristine run with no upgrade selected.
- deterministic upgrade proof, all prior regression fixtures, headless boot, Web export, and exact-source Pages delivery pass.

## Non-goals

- no currency, rewards economy, shop, prices, rarity, rerolls, inventory, or permanent meta progression
- no repair crabs or castle repair timing
- no generalized upgrade tree/catalog UI beyond the two explicit definitions needed by this proof
- no new weapon family beyond the one Skewer damage/length upgrade
- no new castle chunks/material simulation beyond the one durability hook
- no wave timing or enemy rebalance
- no new monster archetype
- no save schema or storefront work

## Immediate sequence

1. Implement the two stable definitions and bounded run-choice authority on `agent/first-upgrade-choice`.
2. Preserve all accepted encounter regression tests and add `[DB:TEST:FIRST_UPGRADE_CHOICE]`.
3. Build/deploy the exact feature head to the phone review booth.
4. Judge choice readability, Skewer payoff, Shell payoff, intermission rhythm, and pristine reset on a phone.
5. Tune only evidenced defects inside this milestone.
6. Promote only after explicit Game Director acceptance.

## Standing laws

- Targets own resistance, health, death, and destruction decisions.
- Presentation reacts to gameplay truth; it never becomes damage or upgrade authority.
- Touch UI requests player intent; it never becomes combat authority.
- Keep `main` buildable.
- Automation proves; promotion is deliberate.
- Player-facing mobile behavior needs representative phone/touch evidence.
- No secrets in Git and no new dependency without explicit justification/provenance.
