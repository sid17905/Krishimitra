# Krishi Mitra — PPT Content Update Plan
**Team NovaCore | SIH 2026 | Theme: Agriculture, FoodTech & Rural Development**

This file tracks every new feature discussed and exactly where it should be added in the existing 6-slide deck (`KrishiMitra-SIH2026-NovaCore.pptx`). Use this as the source content when editing `ppt/slides/slideN.xml`.

---

## ⚠️ Presentation Format Rules (apply to every slide — read before editing)

- **6 slides max, no new slides.** All five new features (Market Analysis, Weather Intelligence, Crop Rotation, Contamination Detection, Nowcasting) get folded into the existing 6 slides as bullets/visuals — none of them get a dedicated slide.
- **Bullets only, no on-slide paragraphs.** Every addition below is already written as short bullet fragments — keep it that way in the deck. The only paragraph-style text in this whole file is the verbal pitch script at the end, which is spoken aloud, never shown on a slide.
- **Visuals over text.** Anywhere a bullet describes data, a trend, or a process (price trends, weather patterns, sensor→alert flow), replace or accompany it with a chart/diagram/icon instead of adding more text. "Visual suggestion" notes are added under each slide below.
- **Slide 1 must instantly state the problem.** Plain, simple words, no jargon — a judge should know exactly what challenge Krishi Mitra solves within the first 5 seconds of that slide appearing.
- **Innovation must be visually called out**, not buried in a bullet list. Give "Innovation & Uniqueness" a distinct visual treatment on Slide 2 (highlight box / icon row / before-after contrast) so it's the first thing that stands out.
- **Total delivery time: 8–10 minutes**, across all 6 slides — not just the closing story. See the timing budget near the end of this file.
- **Fonts:** Body content — **24pt**. Headers/titles — **35–40pt**. Keep the existing font family/style; only the sizes change.

---

## New Features Being Added (Summary)

1. **Market Analysis** — historical + cross-state mandi price trends (Agmarknet / e-NAM)
2. **Weather Pattern Intelligence** — seasonal historical patterns (not just daily forecast)
3. **Soil-Driven Crop Cycle / Rotation Planning** — multi-season recommendations based on nutrient depletion trends
4. **Environmental Contamination Detection** — sensor anomaly + satellite/CPCB cross-referencing for nearby industrial disturbance
5. **Hyperlocal Nowcasting Alerts** — IMD radar + wind-vector based short-range (0–3 hr) warnings

---

## Slide 1 — TITLE / PROBLEM STATEMENT

*(Not detailed in the earlier draft of this file — adding minimum guidance so Slide 1 follows the new rules.)*

**Content (keep it minimal — one line each, large font, no paragraph):**
- The problem, stated plainly: *"Small farmers guess at sowing, spraying, and selling decisions — no affordable, real-time, local-language advisor exists."*
- Team NovaCore | SIH 2026 | PS ID / PS Title / Team ID (placeholders — see Next Steps)

**Visual suggestion:** one strong photo/illustration of a farmer with a smartphone in a field. Let the headline problem line + image carry the slide — no supporting paragraph underneath.

---

## Slide 2 — KRISHI MITRA (Proposed Solution / Innovation & Uniqueness)

**Current bullets (keep as-is):**
- Mobile app with voice + camera input paired with ESP32 field hardware (soil moisture, NPK, DHT22)
- Farmers ask queries by voice about pesticides, fertilizers, growth periods, crop cycles
- ML model trained on Govt. of India weather/soil data answers instantly
- Live hardware sensing fused with knowledge base to predict crop growth, yield, price trends

**ADD to "Proposed Solution":**
- Cross-state market price analysis (historical + current mandi data) to guide crop selection and sell-timing
- Seasonal weather pattern analysis (not just daily forecast) for sowing/irrigation planning
- Soil-nutrient-trend-based crop rotation recommendations across multiple seasons
- Environmental contamination alerts — detects abnormal soil/water readings and correlates with nearby industrial activity
- Hyperlocal nowcasting — short-range (0–3 hr) rain/storm alerts based on radar + wind direction

**ADD to "Innovation & Uniqueness":**
- Goes beyond single-query advisory — acts as a season-long farm companion (plan → grow → protect → sell)
- First-of-its-kind fusion of on-field sensors + government pollution data to flag environmental risk, not just crop health
- Converts generic daily weather into minutes-matter, location-specific action alerts

**Visual suggestion:** icon row for the 5 solution areas (app+voice, hardware sensors, market analysis, weather intelligence, contamination/nowcasting) instead of a long bullet stack. Put "Innovation & Uniqueness" in a visually distinct highlight box, not a plain bullet list — this is the slide judges should remember.

---

## Slide 3 — TECHNICAL APPROACH

**ADD to "Technologies Used":**
- IMD Nowcast/Radar feed (district & station-wise) + wind-vector data for short-range alerts
- CPCB / State Pollution Control Board water quality data (NWMP) for contamination cross-referencing
- Satellite / land-use data (ISRO Bhuvan, Sentinel Hub) to identify nearby industrial zones
- Agmarknet / e-NAM mandi price APIs for market trend analysis
- Additional field sensors: pH, EC/TDS (water & soil), turbidity, MQ-series gas sensor

**ADD to "Methodology" (new steps):**
- Sensor baseline established per field → deviations (EC/pH spikes) trigger anomaly check
- Anomaly location cross-matched with satellite land-use + pollution board records → likely-source alert generated
- Nowcast feed polled at short intervals → wind-adjusted distance/time-to-arrival calculated → proactive alert pushed
- Historical mandi price data trained alongside yield prediction → sell-timing recommendation generated

**Flowchart note:** update `TechnicalApproachFlowchart.jpg` (or rebuild) to show the two new branches — (a) Contamination Detection loop and (b) Nowcasting Alert loop — feeding into the same voice/notification output layer as the existing advisory flow.

**Visual suggestion:** let the updated flowchart carry most of this slide. Turn "Technologies Used" into small icon/logo chips beside the flowchart rather than a text list.

---

## Slide 4 — FEASIBILITY AND VIABILITY

**ADD to "Challenges & Risks":**
- Cheap sensors can flag anomalies but can't confirm exact pollutant (no heavy-metal-grade detection)
- Nowcast/radar accuracy varies by region depending on local radar density
- Government industrial/pollution datasets are not uniformly real-time across states

**ADD to "Feasibility":**
- All new sensors (pH, EC/TDS, turbidity, MQ-series) are low-cost and ESP32-compatible, same hardware family as existing sensors
- IMD nowcast data and CPCB/NWMP data are public and already used in other govt. platforms — no new infrastructure needed
- Agmarknet/e-NAM price data is publicly available and updated regularly

**ADD to "Mitigation Strategy":**
- Frame contamination alerts as "flag for farmer verification," not a confirmed diagnosis — avoids false-alarm liability
- Use wind-adjusted time estimates with a stated margin of error rather than exact-minute promises
- Fall back to regional historical price averages when live mandi feeds are delayed

**Visual suggestion:** 3-column layout (Challenge → Feasibility → Mitigation), each column a short icon-labelled bullet list, instead of three separate text blocks.

---

## Slide 5 — IMPACT AND BENEFITS

**ADD under "Farmers (Users)":**
- Minutes-matter storm warnings protect harvested/drying crop from sudden loss
- Early contamination warnings protect both crop and farmer health from unsafe irrigation water

**ADD under "Economic Impact":**
- Price-trend-based sell timing increases realized income per harvest
- Crop rotation guidance reduces long-term fertilizer costs by maintaining natural soil nitrogen

**ADD under "Environmental & Social Impact":**
- Aggregated, anonymized sensor data can help Pollution Control Boards spot contamination patterns earlier
- Reduces over-fertilization and pesticide misuse through rotation + accurate diagnosis, protecting soil long-term

**Visual suggestion:** simple 3-icon impact grid (Farmer / Economic / Environmental), 3–4 words per line under each icon — not paragraphs.

---

## Slide 6 — RESEARCH AND REFERENCES (optional additions)

**Consider adding:**
- IMD Nowcast Warning System — mausam.imd.gov.in (district-wise nowcast GIS)
- CPCB National Water Quality Monitoring Programme (NWMP) — cpcb.nic.in
- Agmarknet / e-NAM — agricultural market price data
- ISRO Bhuvan — satellite land-use/land-cover data

**Visual suggestion:** small logos/screenshots of the 4 referenced platforms instead of a plain link list.

---

## Delivery Timing (target: 8–10 minutes total)

- Slide 1 (Problem): ~0.5–1 min
- Slide 2 (Solution / Innovation): ~1.5–2 min
- Slide 3 (Technical Approach): ~1.5–2 min
- Slide 4 (Feasibility & Viability): ~1–1.5 min
- Slide 5 (Impact & Benefits): ~1–1.5 min
- Slide 6 (References) + closing: ~1.5–2 min
- The Ramesh narrative below (~2.5–2.75 min at natural pace) is woven into Slides 2, 3, and 5 as the talk-track rather than delivered as one separate block — this keeps total delivery inside 8–10 minutes without needing extra slides.

---

## Pitch Narrative (for verbal delivery — not a slide, spoken only)

> Meet Ramesh, a small farmer in rural Maharashtra. Like millions of Indian farmers, he can't navigate English-heavy agri-advisory apps, the nearest expert is 15 km away, and most of his decisions — what to spray, when to sow, when to sell — are still guesswork passed down for generations.
>
> One morning, his cotton leaves start turning yellow. Instead of guessing or waiting days for an expert, he simply speaks into the Krishi Mitra app: "Why are my leaves turning yellow?" He points his camera at the plant. Meanwhile, our low-cost ESP32 field unit is already reading his soil's moisture, NPK, and temperature in real time.
>
> Within seconds, Krishi Mitra combines his live sensor data with government weather and soil datasets and tells him — in his own language — that it's nitrogen deficiency, not pests. No pesticide wasted, no soil damaged by overuse.
>
> But Krishi Mitra doesn't stop at one query. Over the season, it notices his soil nitrogen has dropped after years of the same crop, and recommends rotating to a nitrogen-fixing legume next season — protecting his land for the long run.
>
> One afternoon, while his soybean is drying in the open yard, Krishi Mitra pulls live radar-based nowcast data and detects a storm forming 11 km away, moving toward his village. It warns him: "Rain in 45 minutes — cover your crop." He does. His neighbor, without Krishi Mitra, doesn't — and loses part of his harvest.
>
> Weeks earlier, those same field sensors had flagged something else — a sudden spike in soil salinity. Krishi Mitra cross-checked it against satellite land-use data and found a new industrial unit upstream on his irrigation canal, warning him before the damage spread — and giving him a contact to report it.
>
> And when it's finally time to sell, Krishi Mitra doesn't let him sell blind either. It shows him historical mandi price trends across Maharashtra — soybean prices typically rise two weeks after peak harvest — so he waits, and earns more.
>
> One farmer. One app. One low-cost hardware unit. Voice and camera instead of literacy barriers. Live sensors instead of guesswork. Government data instead of delayed experts. Real-time alerts for weather, contamination, and price — instead of hindsight.
>
> That's Krishi Mitra — not just a chatbot for farmers, but a season-long, real-time companion that helps them grow smarter, protect their land, and earn more.

*(~400 words, ~2.5–2.75 min at natural pace — designed to be woven into the 8–10 min talk-track across Slides 2, 3, and 5, not read as one standalone block. This is verbal-only and never appears as on-slide text.)*

---

## Next Steps
- [ ] Confirm all new content fits within the existing 6 slides (no new slide added) — if any slide gets too text-heavy, move detail into a visual instead of trimming the feature out
- [ ] Apply font sizes across all slides: 24pt body, 35–40pt headers (keep existing font family)
- [ ] Design Slide 1 problem statement line + visual (photo/illustration)
- [ ] Give "Innovation & Uniqueness" a distinct visual callout on Slide 2
- [ ] Update `TechnicalApproachFlowchart.jpg` with the two new branches
- [ ] Fill placeholder fields on Slide 1 (PS ID, PS Title, Team ID)
- [ ] Rehearse full run-through to confirm 8–10 minute total delivery time
- [ ] Rebuild deck from this content once approved
