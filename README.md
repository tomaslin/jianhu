# Dreaming of Jianghu

**A playable, native Godot 4 physics roguelike for one thumb and a long imagination.**

Eight worlds, eight original ink-wash backdrops, eight distinct physical rules,
48 interactive wuxia citizens and contraptions, 56 draftable boons,
48 conditional secret forms, three mastery tiers, 18 original musical/foley
assets, a 15-day economy,
saved runs, permanent scroll stamps, touch aiming, and procedurally unfolding
combinations. No browser, HTML interface, web services, telemetry, or accounts.

**Version 0.8: The Living Border City.** The paintings now frame kinetic
towns that grow as you add actors. Every installed place adds rooflines,
street annexes and tangible collision shapes. Neighbors make named alliances;
townspeople travel the margins; rotating street events and eight one-use
martial interventions give the world an unpredictable life of its own.
Each address can now be **renovated through five distinct physical levels**:
new storeys and balcony collisions redirect pearls, make hits more valuable,
and increase the income of nearby allied households.

**Cast depth:** Each character has a primary action and a second conditional
"secret form," grows stronger at 6/18/40 impacts, and can enter a **four-form
Righteous, Rogue, or Wanderer training lineage**. Physical strikes earn martial
seals that fund successive forms, conditional on an actor's earned practice.
Every third-day tribute (except
the final one) opens a three-choice boon draft, adding permanent run modifiers
for actor families, statuses, lanes, rhythm, offspring, physics or the economy.

## Start here

1. Download and unzip this complete project.
2. Open `project.godot` in **Godot 4.7.2** or a compatible 4.7 release.
3. Press **F6** with `scenes/main.tscn` open, or **F5** to play the project.
4. Swipe the eight scrolls, tap **Open This Scroll**, pick a draft card,
   tap a vacant ring to buy/place it (if you can afford it), then tap **Play**.
5. Adjust the **Entry** and **Angle** rails by touch, then **Release the Pearl**.
   During the tumble, tap the large **world technique** button once per day
   for an on-beat deflection, recovery, or spectacular counterattack.
   A second pearl is granted each day. On every third day, pay tribute.
6. After paying a tribute, tap one of three large favor cards. This boon
   changes the rules for the rest of the run.

The first day's installed trio is free. You can skip building until you've
earned enough silver. A player's run is saved after safe phase transitions and
can be resumed from the title scroll. The game is entirely offline.

During building, **tap an existing household to inspect it.** From there:

- **Upgrade:** spend taels on an additional storey (up to five). The extra
  balcony is a real collision surface; the address contributes more income
  to its own contacts and to neighboring oath-bound households.
- **Kung Fu:** open the four-stage training scroll. Choose a Righteous,
  Rogue, or Wanderer lineage; then deepen that same lineage through four
  forms. Training costs **3 / 5 / 8 / 13 martial seals**, and subsequent
  forms require **6 / 18 / 40** cumulative strikes by that resident.
  Earn seals by making physical contact every third strike on a named
  resident, or by triggering 12/24/36-contact fight choreography. Up to 18
  seals may be earned each morning. Unspent seals roll over.
- **Move:** tap an empty ring with that household selected to rehouse it
  for 40 taels. A move can create or break a district alliance.

## iPhone 13 Pro

- Portrait canvas: **390 × 844 logical points** (the 13 Pro's point-size).
- UI controls: 44–76 points high, suitable for touch and modest reach.
- Notch and home-indicator margins are reserved in the layout.
- Lightweight renderer: **GL Compatibility**, 60 Hz physics, compact 22.05 kHz
  mono original audio, painterly static backdrops and native 2D collisions.
- The included source is ready to open on a Mac for iOS export. Godot's iOS
  export templates, **macOS and Xcode** are required to build/sign/install the
  actual iPhone application. This Linux-built handoff is **not an .ipa**.
- On iPhone, use the settings panel for Music, Haptics, Reduced Motion,
  and High Contrast. No precise swipes are needed to play.

## What the rules really are

Your falling jade pearl hits physical pegs and named actors. Contacts earn
**silver taels and martial training seals**; the route can transform the pearl into wine-drunk, blessed,
wanted, poisoned, cursed, or cargo-laden states. Actors turn statuses into
bounces, payments, copies, portals, or new pearls. Neighboring actors establish
oaths, rivalries and business combinations. Musical hits aligned with
each world's beat improve yields. A single pearl can trigger a wild chain.

Every day:

1. Draft actors in sets of three, buy and place up to two if solvent; reroll
   for 60 taels. Use spare taels on estate renovations, or earned martial
   seals on an actor's persistent kung fu lineage.
2. Aim and fire two pearls.
3. Collect automatically, inspect the day's ledger and move on.
4. Every third day, pay the red magistrate's tribute; optionally sell a
   companion at half value. Missing a payment ends the run.

Pay the five escalating tributes through day 15 to stamp the scroll. The
eight worlds can be finished independently; their victory stamps persist.

## The eight Jianghu scrolls

| Scroll | Distinct board physics | Separate economic rule | Emotional palette |
| --- | --- | --- | --- |
| **Dragon Inn Valley** | Sloping roadside roofs | Three different trade districts trigger a bonus; goods can be sold | Ochre, clay, teahouse warmth |
| **Hundred Bell Monastery** | Temple terraces, beat-synced upward air | On-beat bells re-launch and multiply returns | Sage, limestone, silence |
| **City of Painted Faces** | Two moving opera platforms; crosswinds | Masks change wanted status, and stage impacts pay applause | Vermilion, theatrical crimson |
| **Nine Bridges Ghost Market** | Lateral warps and bridge rails | Crossing earns silver **and incurs debt** | Midnight blue, pale ghost light |
| **Bamboo Sea of Drifting Swords** | Unsteady horizontal gusts and angled bamboo | Beat-timed sword gusts and split projectiles | Celadon, lacquer-black bamboo |
| **Five Poisons Marsh** | Heavy drag and underwater-like float | Poison pays more while increasing debt; a physician cashes cures | Olive, medicinal amber |
| **Caravan of the Red Dunes** | Sideways sand drift, weight-changing cargo | Loaded pearls earn on distance and sale | Copper, ochre, far-off red |
| **Court of the Celestial Abacus** | Gravity alternates over four-beat halves | Every fourth abacus strike multiplies the ledger | Ivory, pale gold, marble |

The boards also differ in rail placements, opening trio, draft pool,
tempo (72–120 BPM), gravity, art direction, scoring multipliers and route
opportunities. They are **not eight color swaps**.

## Project structure

```text
project.godot                  Godot native project and portrait settings
scenes/main.tscn              Main scene
scripts/main.gd              Economy, game state, physics rules, touch and saves
scripts/world_catalog.gd     8 worlds + 48 authored actors
scripts/actor.gd             Colliders, rooftops, physical buildings and ink motifs
scripts/city_stage.gd        Additive border city, annexes, NPCs, world scenery
scripts/district_system.gd   Named neighborhood oaths, rivalries and businesses
scripts/boon_catalog.gd      56 persistent run modifiers, seven rule families
scripts/reaction_catalog.gd  48 secret forms and 48 named evolutions
scripts/pearl.gd             RigidBody2D pearls, statuses, trails
scripts/hud.gd               Contrast-aware, hand-drawn mobile interface
scripts/sound_director.gd    World music and reactive impact voices
assets/worlds/               8 original painted portrait landscapes
assets/audio/                8 original loops + 10 original effects
assets/fonts/                Bundled DejaVu fonts and their license
tools/generate_audio.py      Reproducible original audio generation
tests/smoke.gd               600+ engine checks
tests/trajectory.gd          Real 2D physics-through-eight-worlds check
DESIGN.md                    Expanded mechanical and production design
```

## Verification

Using Godot 4.7.2 on Linux:

```bash
godot --headless --path . --script res://tests/smoke.gd
godot --headless --path . --script res://tests/trajectory.gd
```

Also play the main scene on a Mac or desktop for visual/audio tuning. The
automated checks exercise native Godot code but do **not** constitute a physical
iPhone performance or iOS signing test. Any Godot cached `.godot` folder can
be regenerated on first import; it is intentionally excluded from the archive.

## Prior design continuity

This realization builds on the earlier **Dreaming of Xianju** illustrated
design bible, the **Spirit Cascade** rhythm-and-impact study, the AI game
generation specification and the game-spec-kit artifact principles. The
canonical current title is **Dreaming of Jianghu**. The inspiration is the
physical pleasure of Peggle/Ballionaire, but the identity here is the wuxia
microcosm: trades and betrayals, ritual gravity, masked identities, ghostly
debt, poisoned wealth and the emperor's completely unreasonable receipts.

The revision draws from the movement grammar of wuxia cinema: floating bamboo
duels, rooftop chases, teahouse brawls, ritual monasteries, opera-fight
choreography, theatrical masks and improvised martial weapons. These are
original interactive systems, not copied film images, dialogue, music or scenes.

**Art:** Eight original AI-assisted ink-wash images produced for this game.
**Sound:** 100% newly synthesized musical loops and impact sounds produced
by the included procedural script; no sampled copyrighted music.
**Fonts:** DejaVu Sans/Serif, license in `assets/fonts/FONT_LICENSE.txt`.
