# DREAMING OF JIANGHU
## A playable design specification — Version 0.11, The Fighting Dream

> The jianghu is not a map. It is a machine for turning strangers into debts.

### Creative argument

The primary action must feel as immediate as dropping a pebble into a fountain:
move an entry point, tilt a shot, release. The deeper game is a constructed
society in which each contact has consequences. An assassin might mark a pearl
wanted. A mask painter might remove its identity; a magistrate taxes it; a
ghost sells it a bridge to somewhere unfortunate. Later, that same pearl
meets a drunken master and flies back into the whole bureaucracy.

The dignity of the world is genuine. The painted landscapes, music and quiet
frames never wink at the player. The **systems** are ridiculous: a wine jar
can become a lucrative strategic technology, heavenly accounting changes
gravity on every fourth beat, and bridges take out loans in your name.

This is not a plot-heavy RPG. Its story is performed by **objects, paths,
rhythms and tiny consequences**. Text is short, precise and legible.

### Control contract

| Interaction | Touch gesture | Feedback |
| --- | --- | --- |
| Choose scroll | Swipe horizontally or hit 68pt arrows | Backdrop, color, score rule and world tune change |
| Select draft | Tap a 109×85pt card | Selection border, cost and brief explanation |
| Place draft | Tap or drag to a vacant ring | Ink-disc appears; paid cost deducted |
| Re-roll | 107×47pt button, 60 taels | New world-specific three-card draft |
| Skip draft | 88×47pt Play button | Entry and angle rails appear |
| Shift entry | Drag a 321pt horizontal rail | Launcher tracks touch |
| Aim angle | Drag the second 321pt rail, or touch board | Twelve dotted path markers |
| Shoot | 306×51pt button | The physics begins, music and foley respond |
| Rehouse a citizen | Tap installed actor, then an empty ring | 40-tael move changes geometry and neighborhood relationships |
| Martial intervention | Tap the 320×48pt world-technique button during a drop | One active wuxia technique per day; on-beat taps are stronger |
| Pause / speed | 63pt upper buttons | Motion freezes / 1.5× sim speed |
| Progress | Day report and page-turn button | Silver, combo, streak and next ledger |
| Pay / sell | Large tribute panel | Economic failure or narrative advancement |
| Boon draft | Tap one 322×91pt favor card after tribute | Adds one of 56 permanent run laws |
| Upgrade a place | Inspect an address, tap its 149×51pt Upgrade button | Spend taels on a real new collision storey; up to five |
| Open kung fu path | Inspect a resident, tap the 151×51pt Kung Fu button | Four connected forms, practice milestones and a martial seal purse |
| Train a resident | Tap a 104×50pt school choice, then a 240×51pt next-form button | Persistent Righteous, Rogue or Wanderer lineage with new physics at each rank |
| Pick a shot stance | Tap one of three 107×48pt buttons above aim rails | Crane rescues, Tiger speeds and earns at debt, Monkey spawns an accomplice |
| Qi Parry during flight | Tap within 100pt of a moving pearl, costs 3 of 9 Qi | Directional impulse, short cooldown, bonus for on-beat skill |
| Choose a martial writ | Tap one of three 104×50pt morning contract seals | Commit to a world-specific measurable feat; earn silver/seals or owe a failure debt |
| Duel a rival | Aim a pearl at the day-5/10/15 moving masked opponent | Timed impacts remove health, retaliation changes travel, trained citizens amplify damage |

No small corner gesture is required for the core loop. Hover is not part of
the control scheme. iPhone 13 Pro uses a native 390×844 portrait design.

### The living border city: the 0.8 city-builder foundation

**The town is the rim; the pearl's trajectory is the stage.** Each original
portrait landscape is treated as a deep backdrop, not a complete preassembled
city that never responds to the player. Around the ivory physics field run
two inhabited side streets, an irregular brushwork frame, roof silhouettes,
flags, lanterns, medicine bags, hanging masks and storefronts that differ
between the eight scrolls. They intentionally leave a clear play corridor.

Development is additive and physically observable:

1. **Landscape.** Mountains, teahouses, monastery, opera streets and caravan
   passes are stable, carefully painted geography.
2. **Founding households.** Three free characters arrive as real physical
   bodies. An inn has a roof, a carpenter a bridge rail, and an umbrella a
   parrying canopy; their geometry affects the very next pearl.
3. **Construction.** Each purchased actor grows a little annex at the edge
   city, with an awning, beams, an illuminated hanging sign and a connecting
   path to its actual position. Its own ink miniature depicts its specific
   profession; 48 characters do not all look like the same bumper.
   **Renovation** later adds second through fifth storeys in two linked places:
   its streetside border annex visibly rises, while the interior household
   gains an actual balcony `SegmentShape2D` collision at a new height.
4. **Neighborhood politics.** Closely placed houses make visible ink-thread
   paths and named economic or martial alliances. The location matters.
5. **Population.** Shops and political relationships attract more small
   travelers on the margin streets. Straw-hatted swordsmen and townsfolk
   walk, carry bundles, and react to the chaos. These are atmospheric, while
   placed buildings remain physically operative.
6. **The day's life.** Every morning rotates among three authored occasions
   for that particular location. Scoring biases change: a festival helps
   tradesmen, a crackdown benefits outlaws, a final performance favors
   perfectly timed contacts. World-specific labels explain the occasion.
7. **Fight spectacle.** A 12/24/36-contact chain sets off a three-act
   short wuxia performance, redirects the moving pearl, and paints a brief
   black ink explosion. The city is responding, not merely applauding.

Thus the world is not an unlockable menu of passive decorative skins: **each
purchase changes its silhouette, collision geometry, economic adjacency,
population and future possible trajectories**. This is the central creative
distinction from a straightforward peg game.

### Cinema language translated into play

This is an original work, not a reproduction of movie actors, soundtrack,
costumes, dialogue, or exact fight sequences. The classic cinema references
are studies in *movement grammar and staged geography*:

| Wuxia film language | Distilled quality | Playable translation |
| --- | --- | --- |
| *Crouching Tiger, Hidden Dragon* | Weightless pauses, bamboo height, breathtaking negative space | Lightness Step redirects a flying pearl over bamboo; periodic winds make air itself a second opponent |
| Jet Li's *Once Upon a Time in China* and *Fong Sai Yuk* | Material choreography: tables, fans, medical halls, travelling fighters | Table-Flipping Palm, fan parries, rooftop archery, unlicensed market trades, acrobatic sleeves and medicine counters |
| Jet Li's *Hero* | Monumental scale, stillness, strokes of highly legible color | Pale-gold celestial court, 4/8-beat gravity reversal, simple shapes against vast negative space |
| Shaw Brothers' *The 36th Chamber of Shaolin* | Training halls as physical machines; rhythmic repetition | Wooden dummies, bells, abbots, concentric martial loops and skillful on-beat impact chains |
| Shaw Brothers' *Come Drink with Me* and *Five Deadly Venoms* | Elaborate indoor sets, deadly social etiquette, distinct schools and poisons | Innkeeper bargains, court and outlaw rivalries, five-poison rackets and visible alliances between sect houses |
| Traditional opera and old-school studio wuxia staging | Banners, masked identities, reveals, trap floors, bright red curtains | The moving opera stages, costumes, trapdoor physics, wanted-status swaps, slapstick firecrackers |

The aesthetic ratio is approximately **three grounded people, places, or
objects for every one supernatural effect**. Most funny things begin as
recognizable material business: wine, noodles, goods, constables, rooftops,
bridges, clubs, staffs, umbrellas, drums, caravan weights. Only occasionally
does a pearl pass through a moon gate, reverse gravity, or become a ghost.
Ink scenery remains serious; the absurdity arises from the properties of
real-looking things bumping into each other.

### Neighborhood engine: the importance of placement

An actor connects to another in one of its eight neighboring board sockets.
The connection is recalculated after a purchase, move, sale or save restore.
An ink thread makes the relationship visible; it contributes passive silver
and, for named pairs, real status or impulse effects.

| Oath or rivalry | Example neighbors | Mechanical consequence |
| --- | --- | --- |
| The Unpaid Banquet | Dragon Inn + Drunken Master | Drunken status, higher tavern earnings, occasional banquet dividend |
| Antidote Racket | Five Poisons Master + Physician | Poison becomes a cured asset; some debt is erased |
| Flying Sword School | Bamboo Swordsman + Sword Pavilion | Frequent aerial re-launches and bonus silver |
| Caravan Cartel | Caravan Gate + Silk Warehouse | Cargo status travels along a neighborhood freight network |
| Dead Man's Taxes | Ghost Market + Dream Magistrate | Cursed objects earn large payouts while creating debt |
| Second Face Society | Masks of Death + Mask Painter | Wanted identities become profitable repeat encounters |
| Thunder Procession | War Drum + Bronze Gong | On-beat strikes pay out and add lift |
| Rival Schools | Shaolin Monk + Bandit Toll | Conflict gives lucrative kinetic counters |
| Burning Stage | Opera House + Firecracker Alley | A staged explosion can send the pearl back up the scroll |
| Unlicensed Crossing | Old Ferryman + Moon Gate | A lateral river crossing redistributes route momentum |

If no named combination exists, shared professional tags can still form
ordinary brotherhoods. This means making a district of merchants is different
from making one of monastics, actors, or outlaws. Players can *rehouse* a
building for 40 taels, destroying one relationship to create another.

### Cast depth: signature moves, secret forms, mastery and schools

The official [Ballionaire publisher page](https://rawfury.com/games/ballionaire/)
identifies **125+ triggers and 50+ boons** as a useful breadth benchmark.
Dreaming of Jianghu currently has fewer base objects (48), but the characters
now have multiple meaningful axes rather than a single on-hit point value:

- **48 primary signature actions:** different trades, attacks, movements,
  transformations, summons, curses, cures, and financial consequences.
- **48 conditional secret forms:** a separate authored rule for every actor,
  triggered by an on/off beat, impact direction, velocity, hit count, combo,
  lane, economic pressure, debt, or a precise status. Examples: the inn's
  second floor throws a rising pearl back toward the roof; the physician
  erases debt when the household is indebted; a bamboo swordsman's on-beat
  contact produces an iron pearl.
- **Three mastery thresholds:** at six, eighteen, and forty activations,
  the resident's payouts grow and its silhouette gains additional ink seals.
  Each identity has its own authored ascension title. Training progress and
  chosen path survive safe-phase saves.
- **Martial credits, not a one-off purchase:** every third strike against a
  named resident creates a martial seal. Each three-act wuxia fight also earns
  seals. A maximum of 18 new seals may be earned in one day; unspent seals
  accumulate independently of taels. Schools have four successive ranks,
  costing 3/5/8/13 seals with 0/6/18/40 practice impacts required. The first
  form determines a permanent discipline; the following three must advance
  that lineage, never switch freely. On the touch inspector, four connected
  ink circles fill as the student develops.
- **Three fully progressive schools:** *Righteous* begins with blessings and
  beat-timed cleansing, then discovers upward impulse, purification of poison
  and debt, and paper-pearl apprentices. *Rogue* learns wanted/outlaw bonuses,
  infection with wanted status, spectacular lateral ambushes and iron-pearl
  accomplices, while accruing debt. *Wanderer* first rewards cargo and speed,
  then adds a curved impulse, carried freight, and lateral river crossing.
  These are **four skill tiers per school**, not twelve static bonuses.
  School-color rings and one to four ink seal dots reveal the training rank.
- **Five-level player-owned addresses:** an estate starts at level one and
  can be improved four times for silver. The base renovation costs are
  150/300/600/1,000 taels plus a price-scaled surcharge at upper levels.
  Each tier adds 16% of its base hit payout, stacked with earned mastery;
  the annex grows higher, balcony shapes change the actual bounce route, and
  each directly adjacent oath-bound neighbor gets 21 silver per upgrade tier
  and 13 per trained form on qualifying contacts. Investing in one business
  therefore alters the income of its block, not merely its own price tag.
- **Ten named relationships and wider tag brotherhoods:** a patronage graph
  that depends on where actors live, and can be reorganized.
- **56 run boons:** independent physical, economic and scoring laws that can
  change the behavior of the entire cast.
- **36 physical sequence recipes:** unlike adjacency, these require real
  ordered hits. Example: a pearl must actually strike the Tea Stall before
  the Dragon Inn to perform the Unpaid Banquet. Each pearl can complete a
  route only once, at most five total; the sequence is discovered in the
  campaign journal and may change velocity, physics, status or offspring.
- **Eight rival mechanics:** each fifth-day opponent moves as an animatable
  collider and retaliates with an authored world-specific rule. Cultivated
  citizens contribute actual combat leverage, not just passive damage stats.

This is a dense, replayable **system of interacting rule layers**, not yet a
claim that there are as many distinct base actors as Ballionaire. The next
large content milestone is additional unique citizens and more event types,
while maintaining the 75/25 grounded/supernatural balance.

### The 56-article Jianghu law book

At each successful tribute through day twelve, the magistrate offers three
random favors. The player selects one. Rarities are weighted 16:7:2 for
common, rare and legendary. Duplicate offers are prevented, and existing
boons are excluded from future drafts.

| Family | Count | Examples and actual mechanical changes |
| --- | ---: | --- |
| Sect patronage | 8 | Rice Futures adds silver to trade hits; Imperial Stipend pays for official seals |
| Status dividends | 8 | Ghost Dividend rewards curses; Wanted Poster pays on outlaw status; Carp King taxes transformed fish |
| Position and trajectory | 8 | Left/right gates, rooftops, cellars, center court, rising or falling contacts |
| Rhythmic laws | 8 | On/off-beat dividends; odd beats; chains of 3/5; 15/30-hit milestones |
| Ball generation | 8 | Paper Martyrs, Temple Echoes, Market Children, Ghost Pilgrims and other conditional offspring events |
| Physics amendments | 8 | East/west wind, light/heavy bones, magnetism, wall attraction, slippery or sticky travel |
| Economic amendments | 8 | Discounts, tax rebate, third building permit, better pawning, dawn income, debt amnesty |

The critical distinction is **when** the boon takes effect. A finance law
changes decisions on the build screen; a magnetic field acts continuously
during flight; a rhythm dividend acts on collision; a ghost offspring law
acts only on the correct kind of collision at the right activation count.
This sequencing produces unexpected interactions without requiring hundreds
of bespoke if-statements for every possible pair.

One concrete high-order interaction: a Wandering Sword Pavilion neighboring a
Bamboo Swordsman, aided by Paper Martyrs and a left-lane rent boon, can spawn
iron and paper projectiles from different contact conditions; the Flying Sword
School oath kicks them into the upper court, where an on-beat rebate and the
citizen's mastery tier modify their earnings. All of this runs through
physical rigid bodies and bounded summoning, with the birth limit preserving
mobile playability.

### Eight active wuxia interventions

The player can press one deliberate, highly visible technique per day during
the rolling physics. The chosen world gives it a different animation, force
law and material side effect. A tap close to a musical downbeat is stronger.

| Scroll | Move | Immediate tactical use |
| --- | --- | --- |
| Dragon Inn Valley | Table-Flipping Palm | Sends a pearl up and sideways while loading it with goods |
| Hundred Bell Monastery | Buddha Palm | Powerful vertical reversal and blessing |
| City of Painted Faces | Flying Silk Sleeve | Sideways counter and wanted-mask change |
| Nine Bridges Ghost Market | Ghost Step | Reappears across the board; incurs a small debt |
| Bamboo Sea | Lightness Step | Airborne diagonal step, particularly useful during adverse wind |
| Five Poisons Marsh | Meridian Cleanse | Clears poison and curses, repays some debt, grants lift |
| Caravan of the Red Dunes | Iron Palm | Freight-loading horizontal blow through sand drift |
| Celestial Abacus | Heavenly Reversal | Flips velocity, resists gravity for a short interval and blesses |

The intervention is never an unrelated spell menu. It is **a martial action
the player performs on the very physics object already in flight**. The game
shows its cost (once per day), grays it out after use, and renews it next
morning. This adds a moment of control without trivializing carefully built
paths.

### Route choreography: 36 combinations that must physically happen

Adjacency oaths are a static question—*who lives next door?* Route recipes
are dynamic—*whom did this specific pearl meet, and in which order?*
The `chain_catalog.gd` defines 36 named combinations with two or three actor
IDs each. A pearl keeps a short route history; the system tests suffixes of
that history against the entire catalog after a real actor activation. A
matching recipe can change trajectory with one of these authored action
families:

| Technique consequence | Actual world change |
| --- | --- |
| Spring / lateral / flip | Strong vertical strike, side kick or reversed velocity |
| Paper / copper / iron / spirit | Material metamorphosis or new offspring of that type |
| Drunken / blessing / ambush | Status, momentum and economic transformation |
| Cargo / rain | Freight changes or a staged extra pearl |
| Exorcise / teleport | Cleanse a curse or cross the board in a single leap |

A discovery grants silver and training seals, but each recipe fires at most
once per pearl and a pearl cannot trigger more than five recipes. No text
adventure choice is substituted for physical contact. This also makes draft
selection legible: the three offers now favor an undiscovered compatible
piece, an underrepresented role and a deliberately novel wildcard.

### Immediate pleasures: onboarding, mayhem, comedy and sensory rhythm

**Four-step, diegetic onboarding:** The first dream highlights one actual
touch target at a time while permitting normal play. Building points to the
PLAY button; aiming points to the release action and explains ENTRY/ANGLE;
the drop reveals the one-use martial technique; the day report teaches the
next morning. These cues auto-advance on real phase transitions and never
block the physics. A 79×47-point SKIP control completes onboarding immediately
and persists the choice in settings. The guidance deliberately contains one
sentence per scene, not an instructional scroll.

**Three-stage MAYHEM:** When contacts in one pearl's drop reach 7, 17 and 31,
the city detonates an authored original action-comedy beat. Stage 1 adds an
upward deflection and a paper child; stage 2 blesses the moving projectile,
redirects others and launches a copper child; stage 3 adds iron/paper offspring,
a heavier knockback and debt relief. Each stage lasts 4.85–6.15 seconds,
introducing sideways swirls, lift and a temporary 12/24/36% economic bonus.
This rewards a *planned physical cascade* without letting a high combo run
forever. Daughter pearls remain subject to the existing birth/field limits.
The mayhem timer resets at the day's ledger, so a dead burst cannot enrich
the next morning's unrelated finances.

**Three sensory layers, no cutscenes:** Every fourth named impact can print a
short world-specific comic exclamation; successful chain recipes, training,
renovations, rival knockouts and tribute payments get stronger stamps. The
shards are colorful rag-paper, not generic UI confetti. Existing original
foley voices are dynamically pitched and layered with a tempo accent only
during heightened mayhem. Characters breathe, recoil and squash visually,
while their fixed colliders preserve precise play and predictable routing.

**Accessibility guardrail:** `Spectacle & Mayhem FX` is enabled by default
and suppresses exuberant motion/stinger layers when switched off; all
bonuses and trajectory changes still happen. `Reduced Motion` freezes
decorative travel and suppresses paper shards, but keeps a single readable
impact caption. No mandatory rhythmic timing window was made narrower.

### Player agency inside the physics: stance and Qi

This revision directly addresses the gap between watching an automated peg
drop and feeling like a wuxia performer. There are two coupled decisions:

1. **Before each shot**, choose among three asymmetric stances. *Crane*
   starts with two Qi, gently resists early gravity and allows a rescue even
   after three contacts. *Tiger* fires its seed roughly 71% faster, earns
   28% more live-drop silver, but incurs 35 debt. *Monkey* starts with a
   second paper projectile and accepts a 22% payout haircut. Each choice
   works with one-thumb touch buttons and persists at safe save points.
2. **During the fall**, each named-actor strike earns one Qi, plus another
   for good rhythm and one from a trained second-form master. Up to nine Qi
   can be banked per shot. A tap within 100 logical points of a pearl spends
   three Qi, kicking the nearest rigid body upward and sideways toward the
   touch. Perfect on-beat parries provide additional lift and pay 100 base
   taels. The 420ms cooldown and earned Qi stop mindless tapping. The
   once-per-day world technique stays independent.

**Second Wind** is a deliberately generous fail-soft: one seed per drop
that escapes below the stage with almost no hits is kicked back into the
field exactly once. It earns one Qi. It does not award money automatically;
the rebounding pearl still has to strike a real person or structure. Crane
protects a slightly longer weak opening than Tiger or Monkey.

**Readable strategy:** choosing a draft highlights existing citizens
compatible with an authored multi-stop route. The lower inspector says
whether a known route partner is present. The intent is learning the cast
through experimentation, not reading a 48-entry database before playing.

### Morning writs: an optional objective layer with teeth

Each world owns three independent commissions in `commission_catalog.gd`,
24 total. A player may accept one before playing the day's two pearls. Its
counter is advanced by physical events, not by a pretend daily payout: trade
impacts, drunk contact, route performances, righteous hits, on-beat notes,
mask changes, wanted encounters, offspring, curse transfers, martial forms,
poison, remedies, goods, or official judgments. Completion is assessed once
after the second pearl, rewarding both taels and seals. A failed accepted writ
adds debt, a controllable risk. A declined writ does nothing. Contract choice,
progress and outcome are safe-save fields.

### The masked rivals: three escalations across a run

On mornings 5, 10 and 15, an opponent walks into the kinetic field. Each has
an independent physical collider, its own mask and 4/5/6 health. On-beat
contacts cause two wounds instead of one. A contact preceded by a second-form
martial master or third-level building adds a wound; a nearby world technique
can wound the rival again. The enemy retaliates on each hit, so players must
choose whether to use scarce daytime tempo to fight or optimize income.

| World | Rival | Retaliation |
| --- | --- | --- |
| Dragon Inn | Tax-Eating Eunuch | Seizes silver, shoves the courier away |
| Monastery | Abbot Who Stole Sound | Curses and silences through downward recoil |
| Painted Faces | White-Faced Censor | Marks the pearl wanted, swaps lateral direction |
| Ghost Market | Ninth Debt Ferryman | Issues debt and sends the courier over the bridge |
| Bamboo Sea | Reed Executioner | Sweeps the pearl violently across the stage |
| Five Poisons | Venom Registrar | Applies poison and pulls the courier toward the marsh |
| Red Dunes | Brigand of Seven Tolls | Loads burdens and throws the courier sideways |
| Celestial Abacus | Auditor of Heaven | Reverses velocity and briefly changes gravity |

Winning pays silver and enough martial seals to advance a cultivated
household. Ignoring the adversary levies a stage-scaled toll at night. Defeats
and surviving HP are saved; opponents cannot be erased by reopening a session.

### A day in the life — emergent example

In Dragon Inn Valley, a new Noodle Stall arrives next to the Wine Jar. The
innkeeper's neighboring Drunken Master establishes an Unpaid Banquet. A jade
pearl falls through the roof of the stall, becomes drunk, ricochets off the
master's actual roof slope, and strikes the Inn. A woman with an umbrella
parries it into the broker's cargo lane. The player waits for the music to
settle into a strong beat, then taps **Table-Flipping Palm**. The pearl, now
carrying goods, goes airborne through the same street, and the magistrate
issues a receipt for an event that was technically a bar fight.

The production goal is not merely a high score. It is a sequence of physical
events that a player can **describe to a friend without mentioning a single
numerical perk**.

### Macrostructure

An independent scroll is 15 mornings / 30 initial pearls / 5 tributes. At
each morning, the player may acquire up to **two actors** from successive
three-card drafts. The board holds up to 25 position sockets plus a dense
field of physical stones.
Companions can be sold at the red ledger for half their original value.
Every third morning, the account is audited. A failed payment ends the run.

The objective has three competing pressures:

- **Solvency:** hoard enough to meet the next quota.
- **Compounding:** purchase actors that amplify routes and new pearl births,
  expand their estates and cultivate martial paths with credits from real play.
- **Finesse:** aim and timed contacts exploit the current world's physics.

The economy is intentionally positive in the first cycle, with sharper
pressure later. The current authored quotas are 350 / 1,200 / 4,000 / 12,000 /
35,000 taels, multiplied by the world's difficulty coefficient. Renown
increases ordinary earnings by 18% per elapsed day, plus 1.9% per contact
combo, with a bounded 25-hit combo supplement. Statuses and actor effects can
exceed these routine payments by producing whole new trajectories.

### Microstructure: what a hit means

1. A physics contact is deduplicated within 160 milliseconds, so resting
   against a bell does not mint infinite money.
2. A contact increments the current run combo. Scenery pegs pay escalating
   small silver; named objects pay their authored value plus route bonuses.
3. A contact within 110 milliseconds of a musical beat counts as on-beat,
   earns a multiplier and can sustain an increasingly rare rhythm chain.
4. A status modifies the score and routes. Statuses wear down over successive
   contacts. A pearl can carry three statuses at once.
5. The touched actor performs its custom consequence: impulse, infection,
   cure, multiplication, cargo transaction, teleportation or taxation.
6. The local world rule performs a second action. On a monastery beat that
   may be another lift; in a ghost market it might be toll on a crossing.
7. The physical pearl continues, possibly joined by offspring. To avoid
   degenerate loops, the field caps live pearls at 48 and births per drop at 9.
8. The city's social rules intervene. Adjacent compatible actors form named
   bonds with scoring and physical consequences; separating them breaks the bond.
9. On combos 12, 24 and 36, each world stages an original three-act wuxia
   fight phrase with a *real* rigidbody deflection, not merely a title card.

**Why it is fun:** the contact is both a musical note and a rewrite of the
simulation. The player learns distinct chains, then deliberately builds them.

### The eight authored, mechanically separate chapters

#### 1. Dragon Inn Valley / The price of weather

A warm teahouse among river mountains. Three inns and shops form a market
district. Trade status and carried goods matter; a broker cashes a loaded
pearl. The walls are ordinary slopes, so skillful routing between merchants
drives profit. Starter set: Dragon Inn, Wine Jar, Rice Merchant. A seemingly
respectable economy is built on ever less respectable drinking habits.

#### 2. Hundred Bell Monastery / Ritual gravitation

Green-gray stone and enormous silent bells. Repeated, temporary updrafts
are synchronized to an unhurried 72 BPM pulse. Bells summon paper pearls;
the monk confers blessings and Wudang's wheel launches a pearl upward. On-beat
ritual contacts pay extra. This world values patience and rebound timing.

#### 3. City of Painted Faces / The theatre of wanted men

Bright lacquer-red opera banners, buildings and masks. Two stage rails slide
horizontally during the drop. A sideways theatrical draft changes trajectories.
Opera House throws pearls into new arcs; Mask Painter trades wanted status;
Masks of Death makes fugitives lucrative. A performer may emerge from an
accidental collision to become the most expensive person in the room.

#### 4. Nine Bridges Ghost Market / Interest in the afterlife

Blue moonlit bridges between island stalls. Cross the left/right thresholds
to warp to the opposite edge at inverted height. Each warp earns a crossing
fare but accrues debt. Ghosts and moon gates mark curses, doubling certain
later contacts. The strongest score often also contains the most danger.

#### 5. Bamboo Sea of Drifting Swords / The invisible hand

Deep jade-green mountain groves. Sinusoidal horizontal wind acts constantly;
slanted bamboo rails help the player exploit it. The swordsman pushes the
pearl, the Iron Fan reverses travel, and Sword Pavilion spawns an iron pearl
with sword-like impulse. A bonus rewards contacts struck in tempo.

#### 6. Five Poisons Marsh / Very profitable medicine

Still yellow-green marshes and lotus medicine houses. Below the waterline,
linear drag is heavy and a faint upward float resists gravity. Poisoned
pearls yield more silver but their continued attacks accumulate debt. The
Traveling Physician removes poison/curses for a cure dividend. The puzzle
is not whether to poison but **when to stop**.

#### 7. Caravan of the Red Dunes / Freight and momentum

Sand-colored frontier gates, moving caravan routes and sun-bleached cliffs.
Wide periodic wind pushes copper cargo pearls. A loaded pearl becomes heavier
and slightly damped, but a broker can sell its load. Long journeys with goods
pay periodically. Bandit Toll turns legitimate shipping into wanted profit.

#### 8. Court of the Celestial Abacus / Heaven's accountant

White-gold floating pavilions and suspended abacus monuments. For half of
every eight-beat phrase, a vertical counterforce reverses gravity unless the
pearl has temporary immunity. Official stamps and abacus strikes make the
score jump; every fourth abacus event multiplies returns. This final world
is mathematical, near-silent, slightly cruel and vastly ornate.

### Actor families and emergent recipes

| Family | Characters | What may happen together |
| --- | --- | --- |
| Tavern/trade | Dragon Inn, Wine Jar, Drunken Master, Rice Merchant, Pawn Broker, Rice Mill, Caravan Gate | Wine boosts tavern pay; goods load, travel and sell; rice spills new pearls |
| Monastic | Shaolin Bell, Shaolin Monk, Wudang Wheel, Bronze Gong | Blessing boosts ritual strikes; bells create paper; wheels undo falling |
| Outlaw/theatre | Bandit Toll, Opera House, Mask Painter, Masks of Death, Dream Magistrate | A pearl becomes wanted, is taxed, unmasked, marked for bounty, or thrown back on stage |
| Spirit | Ghost Market, Moon Gate, Red Lantern, Moon Mirror, Cloud Stair, Paper Boat | Curse multipliers, teleports and paper swarms pile up, at a price |
| Wilderness | Iron Fan Adept, Bamboo Swordsman, Sword Pavilion, Carp Pond | Fans and bamboo bend the route; carp swimming can send a pearl into a new district |
| Alchemy/official | Five Poisons Master, Traveling Physician, Celestial Abacus | Toxic profit is cured for a dividend; the official ledger re-multiplies its tally |

The comedy comes from causality, never dialog boxes. There are currently **48
authored actors** with individual physical motifs and powers, and each scroll
has its own 17–18-actor draft pool. The expanded roster includes a Noodle
Stall, Crooked Dice Den, Umbrella Swordswoman, Lion Dance Troupe, Bridge
Carpenter, Silk Sleeve Acrobat, Rooftop Archer, Secret Manual Seller, Masked
Constable, Nine-Staff Abbot, Wooden Dummy Hall, War Drum Procession, Opera
Costume House, Stage Trapdoor, Old Ferryman, Jade Relic Dealer, Medicine
Gourd, Firecracker Alley and Silk Road Warehouse.

### Look and pacing

- Watercolor and ink landscapes are expansive, not tile maps or flat neon UI.
- The physical board is a translucent ivory sheet; actors are drawn as
  town miniatures—stamped identity at the center and functional roofline,
  gate, bridge, dojo arch or stage prop around it, not HTML cards.
- The score uses hand-stamped numbers that briefly float up after strong hits.
- Between shots, the game falls quiet. During chains, pitched impacts become
  a self-composed response to the simulated route.
- Each scroll has original procedural pentatonic music at its own BPM and
  distinct register; the soundtrack never depends on a proprietary sample.
- A brief audible reward, escalating silver, and rhythmic on-beat feedback
  create cadence without demanding strict rhythm-game accuracy.

### Accessibility and rendering

The high-contrast paper treatment, persistent touch targets, one-handed play,
four settings toggles, no essential flick gesture, low-motion option and
offline save are first-class. The project uses static painted images, drawn
UI and simple circle/segment collision shapes for feasible 60 Hz physics on
an iPhone 13 Pro-class device. Per-world hand tuning and actual device QA
remain required before a commercial release.

### Done / not yet done

**Playable now:** three fighting stances, named-hit Qi building, touch-directed
midflight parry, bounded bad-luck rescue, route synergy previews; four-step
touch onboarding and a skip, three escalating
physics-and-economy mayhem states, reactive comedy stamps and foley, actor
recoil and reduced-spectacle controls; all eight boards, physical launch, 48 actors with separate
secret forms, mastery and twelve progressive martial forms (four in each of
three school paths), martial seal economy, five-level building renovations,
56 boon laws, 36 ordered route performances, 24 daily martial writs, eight
physical boss opponents appearing three times per run, post-tribute
drafting, architecture, district oaths, movable households, townsfolk
animation, rotating street events, eight active martial moves, three-act
fight choreography, buying, rerolls, statuses, songs, foley, silver economy,
daily and three-day loops,
failure/victory, save/resume, world stamps, touch and settings.

**Future polish:** guided tutorial as three diegetic gestures; stronger world
cutscenes; richer phase-based rival move sets; further procedural event cards;
achievements; physical-device profiling; localized Chinese typography;
VoiceOver accessibility; iOS signing and TestFlight deployment; balance QA
with actual human player runs; hand-tuned music mixes; reduced texture memory.

### Production acceptance tests

1. The title screen can select each of eight genuinely different worlds.
2. Each world has its own art, collision rail map, motion or force law,
   tempo, starting actors, draft pool, and scoring complication.
3. Purchases are rejected if insufficient funds, and credited only on placement.
4. A drop creates a real rigidbody pearl and awards taels on actual collision.
5. Pausing freezes the simulated rigid bodies; resuming continues.
6. Two pearls pass one day; the third day leads to the red ledger.
7. Paying tribute removes the correct funds and advances a day.
8. Five payments through day 15 stamp the current scroll as finished.
9. The current run can be saved and resumed at a safe decision point.
10. Address renovation adds real collision segments, changes the border city,
    and persists across safe saves. Martial credits persist; later school ranks
    require both a higher seal cost and increased personal practice.
11. Godot 4.7.2 runs the native scene and eight trajectory tests without
    parse errors. Physical iOS export and ergonomics need independent QA.
12. The 36 multi-contact recipes are documented, finite, and have repeat
    caps. Writs update only from real triggers and produce a reward or debt.
13. Each of eight world rivals can be damaged, defeated, serialized and
    distinguished by retaliation. Final-day survivors charge an actual toll.
14. A pinned GitHub Actions pipeline tests native logic and trajectories,
    exports a genuine single-threaded Godot WebAssembly build, verifies
    release artifacts and deploys via GitHub Pages. External account
    configuration and real Safari performance remain separate acceptance gates.
