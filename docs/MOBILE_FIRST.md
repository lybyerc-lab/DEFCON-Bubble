# Mobile-first product and engineering law

## Product target

DEFCON BUBBLE is a native mobile-first game. The intended shipped experience is the full 3D/2.5D beach-defense fantasy on a phone, not a desktop game that is later compressed into a mobile port.

Desktop remains a powerful development environment. Web remains a fast preview surface. Neither replaces native mobile as the product target.

## Ambition law

Mobile-first does not mean reduced ambition.

Keep the sandcastle siege, escalating absurdity, visible destruction, weapon and defense growth, bubble hordes, bosses, repair activity, personality, audio impact, and large-feeling battlefield fantasy. Solve mobile constraints with composition, staging, batching, culling, level-of-detail choices, scalable VFX, controlled simulation, content budgets, and measured performance work.

Do not remove a core fantasy beat merely because a brute-force implementation would be expensive.

## Platform roles

### Native mobile

- Primary player experience and final product authority.
- Touch interaction, safe areas, interruption handling, thermal behavior, memory pressure, battery cost, and device performance matter from the start.
- Significant player-facing milestones require representative on-device evidence when these concerns are relevant.

### Desktop

- Authoring, debugging, profiling, automation, deterministic reproduction, and fast iteration.
- Desktop may use higher-fidelity developer views or tooling, but gameplay contracts must not depend on desktop-only input or presentation behavior.
- Desktop success alone does not prove mobile readability, touch feel, lifecycle behavior, or performance.

### Web preview

- Rapid-access preview that can be opened from a phone without a native install.
- Used for early feel checks, visual review, touch-layout review, and sharing exact-source candidates.
- Not the final performance authority and not the shipped-product architecture.
- Preview infrastructure must stay replaceable and must not become a gameplay dependency.

## Orientation

- DEFCON BUBBLE is played in landscape. `display/window/handheld/orientation` is `sensor_landscape`, so both landscape rotations are allowed.
- Combat runs left to right, and the approach axis takes the long edge of the screen. A phone cannot give both the patrol axis and the approach axis the long edge; approach wins because approach pressure is the accepted core tension.
- Portrait is not a supported play orientation. Framing code still handles portrait aspects gracefully for rotation transitions and unusual viewports; that is defensiveness, not support.

## Renderer policy

- Desktop development default: Forward+.
- Native mobile override: Mobile renderer.
- Web preview override: Compatibility renderer.

These settings are project contracts and are checked by the foundation smoke test.

Changing them requires a measured reason and an explicit decision update.

## Input law

- Gameplay consumes player intent, not platform widgets.
- Touch controls, keyboard controls, controllers, accessibility controls, and future input methods should translate into shared named actions or explicit intent contracts.
- Touch UI may request fire, aim, select, pause, repair, upgrade, or other player intent. It does not own the gameplay consequence.
- Controls must remain readable, reachable, and forgiving on the target phone layouts.
- Do not assume a specific orientation, one-handed scheme, or two-thumb layout until it is intentionally tested and locked.

## Screen and readability law

- Important enemies, projectiles, castle damage, warnings, upgrade choices, and interaction states must read at phone scale.
- Safe areas and varying aspect ratios must not hide critical information or touch targets.
- Presentation should prioritize silhouettes, timing, contrast, motion, and spatial separation before adding fine detail that disappears on a small screen.
- UI must scale without changing gameplay truth.

## Lifecycle law

Native mobile must eventually handle normal phone behavior cleanly:

- pause/background and resume
- focus loss
- audio interruption and restoration
- screen/system overlays
- safe-area changes
- interrupted sessions
- save integrity during lifecycle transitions

These do not all belong in the current POP milestone, but future architecture must leave room for them.

## Performance law

- Mobile performance is designed, measured, and budgeted. It is not a final optimization pass.
- Do not invent permanent numeric budgets before a target-device matrix exists.
- Once representative devices are selected, record concrete frame-time, memory, thermal, draw-call, physics, audio-voice, and effect budgets.
- Use quality tiers for presentation cost, never for authoritative gameplay results.
- Profile before adding pooling or other complexity.
- Prefer deterministic caps and controlled escalation over uncontrolled object counts.

## Build and preview law

- Builds and previews should be traceable to an exact Git revision.
- Prefer source-driven GitHub automation over manual uploads for repeatable Web previews and test artifacts.
- Hosting is replaceable infrastructure. A provider change must not require gameplay changes.
- Native signing credentials and store secrets never belong in the repository.

## Open platform decisions

These are intentionally not locked yet:

- initial native storefront/platform order
- target-device matrix and minimum supported device tier
- final orientation policy
- final control layout and handedness assumptions
- concrete performance budgets
- store packaging and release pipeline details

Lock each when product intent and device evidence are strong enough to justify it.
