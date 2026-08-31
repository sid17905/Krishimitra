# AgriMM — PPT Content Update Plan
**Team NovaCore | SIH 2026 | Theme: Agriculture, FoodTech & Rural Development**

This file tracks every new feature discussed and exactly where it should be added in the existing 6-slide deck (`AgriMM-SIH2026-NovaCore.pptx`). Use this as the source content when editing `ppt/slides/slideN.xml`.

---

## New Features Being Added (Summary)

1. **Market Analysis** — historical + cross-state mandi price trends (Agmarknet / e-NAM)
2. **Weather Pattern Intelligence** — seasonal historical patterns (not just daily forecast)
3. **Soil-Driven Crop Cycle / Rotation Planning** — multi-season recommendations based on nutrient depletion trends
4. **Environmental Contamination Detection** — sensor anomaly + satellite/CPCB cross-referencing for nearby industrial disturbance
5. **Hyperlocal Nowcasting Alerts** — IMD radar + wind-vector based short-range (0–3 hr) warnings

---

## Slide 2 — AGRIMM (Proposed Solution / Innovation & Uniqueness)

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

---

## Slide 6 — RESEARCH AND REFERENCES (optional additions)

**Consider adding:**
- IMD Nowcast Warning System — mausam.imd.gov.in (district-wise nowcast GIS)
- CPCB National Water Quality Monitoring Programme (NWMP) — cpcb.nic.in
- Agmarknet / e-NAM — agricultural market price data
- ISRO Bhuvan — satellite land-use/land-cover data

---

## 3-Minute Pitch Script (for verbal delivery — not a slide)

> Meet Ramesh, a small farmer in rural Maharashtra. Like millions of Indian farmers, he can't navigate English-heavy agri-advisory apps, the nearest expert is 15 km away, and most of his decisions — what to spray, when to sow, when to sell — are still guesswork passed down for generations.
>
> One morning, his cotton leaves start turning yellow. Instead of guessing or waiting days for an expert, he simply speaks into the AgriMM app: "Why are my leaves turning yellow?" He points his camera at the plant. Meanwhile, our low-cost ESP32 field unit is already reading his soil's moisture, NPK, and temperature in real time.
>
> Within seconds, AgriMM combines his live sensor data with government weather and soil datasets and tells him — in his own language — that it's nitrogen deficiency, not pests. No pesticide wasted, no soil damaged by overuse.
>
> But AgriMM doesn't stop at one query. Over the season, it notices his soil nitrogen has dropped after years of the same crop, and recommends rotating to a nitrogen-fixing legume next season — protecting his land for the long run.
>
> One afternoon, while his soybean is drying in the open yard, AgriMM pulls live radar-based nowcast data and detects a storm forming 11 km away, moving toward his village. It warns him: "Rain in 45 minutes — cover your crop." He does. His neighbor, without AgriMM, doesn't — and loses part of his harvest.
>
> Weeks earlier, those same field sensors had flagged something else — a sudden spike in soil salinity. AgriMM cross-checked it against satellite land-use data and found a new industrial unit upstream on his irrigation canal, warning him before the damage spread — and giving him a contact to report it.
>
> And when it's finally time to sell, AgriMM doesn't let him sell blind either. It shows him historical mandi price trends across Maharashtra — soybean prices typically rise two weeks after peak harvest — so he waits, and earns more.
>
> One farmer. One app. One low-cost hardware unit. Voice and camera instead of literacy barriers. Live sensors instead of guesswork. Government data instead of delayed experts. Real-time alerts for weather, contamination, and price — instead of hindsight.
>
> That's AgriMM — not just a chatbot for farmers, but a season-long, real-time companion that helps them grow smarter, protect their land, and earn more.

*(~400 words, ~2.5–2.75 min at natural pace — leaves buffer for other slides in a 3-min pitch)*

---

## Next Steps
- [ ] Confirm which slides get new bullets vs. a dedicated new slide for contamination/nowcasting features
- [ ] Update `TechnicalApproachFlowchart.jpg` with the two new branches
- [ ] Fill placeholder fields on Slide 1 (PS ID, PS Title, Team ID)
- [ ] Rebuild deck from this content once approved
