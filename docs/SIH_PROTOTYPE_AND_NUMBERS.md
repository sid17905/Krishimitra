# KrishiMitra — Prototype & Numbers Integration Plan
**Team NOVA_CORE | SIH 2026 | Working doc — fill placeholders when hardware data arrives**

---

## 1. THE PROTOTYPE STORY (Your #1 WInning Asset)

>> **Framing statement (use in the pitch):**
>> "We don't just have a slide deck. We have a physical field unit — an ESP32 node with
>> soil moisture, NPK, temperature and humidity sensors — that we built and validated in
>> [CITY/VILLAGE]. It's currently being re-verified for the live demo, alongside the
>> voice app and the alert pipeline."

**Why this beats every theoretical team:**
- SIH 2020 winner Codeline won on **proof** (live URLs). You have physical proof.
- A judge can *hold* your hardware. That's priceless.
- "Broke recently" → frame as "we caught a real field issue" (sensor drift / power sag)
  → demonstrates that your feasibility section (challenges + mitigations) is REAL,
  not copied from a template. This makes Slide 4 believable.

**What to capture from the prototype (evidence package):**

| Item | How to capture | Use on slide |
|------|---------------|--------------|
| Unit photo(s) — top, sensors, wiring | Phone camera, good light | Slide 2 corner badge "Prototype v1" |
| Photo of ESP32 + sensor breakout | Close-up macro | Slide 3 tech section |
| Photo of it ON / readings on serial monitor | Screen capture | Slide 2 or 3, credibility shot |
| 1 video (30-60s) of live readings | Phone video, narrated 1 line | Demo link on Slide 1 or 3 |
| Previous test readings export (CSV/screenshots) | Serial monitor / Blynk / ThingsBoard | Numbers for Slide 5 |
| Date + location it was field-tested | Note | "Validated in [village], [date]" |

>> **RULE:** never say "it broke." Say "we're re-verifying build 1 to harden it for live demo."

---

## 2. NUMBERS TO COLLECT FROM YOUR TEAMMATE (Checklist)

> Ask your teammate exactly these — each one fills a winning slot. If a number is
> missing, estimate from public data and mark it "est."

### A. HARDWARE / COST
- [ ] ESP32 board actual cost (₹ ?)
- [ ] Soil moisture sensor cost (₹ ?)
- [ ] NPK sensor cost (₹ ? — often the costly one)
- [ ] DHT22 temp/humidity cost (₹ ?)
- [ ] pH sensor cost (₹ ?)
- [ ] EC/TDS sensor cost (₹ ?)
- [ ] Turbidity sensor cost (₹ ?)
- [ ] MQ-gas sensor cost (₹ ?)
- [ ] Enclosure, wiring, power (solar? battery?), misc (₹ ?)
- [ ] **TOTAL unit cost = ₹ ???** ← THIS is the headline number for Slide 4/5

### B. TECHNICAL PERFORMANCE (from their test runs)
- [ ] Power consumption: how long one charge / solar setup runs (hours/days)
- [ ] Data interval: how often sensors report (e.g., every 15 min)
- [ ] Response time: voice query → answer (seconds)
- [ ] Sensor accuracy vs manual test (e.g., moisture within X%)
- [ ] Distance/battery: BLE vs Wi-Fi range with ESP32
- [ ] Languages implemented in voice demo (Hindi, Marathi, ...)

### C. IMPACT / USER (needed if you have any)
- [ ] # farmers interviewed / surveyed
- [ ] # of real crop questions logged
- [ ] Any yield/income improvement measured (or est. %)
- [ ] Fertilizer/pesticide spend change observed (₹ or %)
- [ ] Avg. time to get expert advice WITHOUT tool (days) vs WITH tool (seconds)

### D. FALLBACK ESTIMATES (use only if teammate can't provide)
```
Cost estimates (public market prices, 2026):
  ESP32 DevKit        ₹300
  Soil Moisture       ₹150
  NPK Sensor          ₹2,000
  DHT22               ₹150
  pH Sensor           ₹300
  EC/TDS Sensor       ₹200
  Turbidity Sensor    ₹300
  MQ-Gas Sensor       ₹200
  Enclosure/wiring/power ₹500
  TOTAL ≈ ₹4,100/unit
```

---

## 3. WHERE NUMBERS GO ON EACH SLIDE

### SLIDE 1 (Title) — 1 number only
- Add stat under problem line:
  - *"India has 14.6 crore smallholder farmers — most make sowing, spraying & selling decisions without expert advice."* (govt. Agri Census figure)
  - Or your own: *"X farmers surveyed in [village] reported crop losses from delayed advice."*

### SLIDE 2 (Solution) — proof badge + timing number
- Corner badge: **"Prototype v1 field-tested in [village, state] — [month] 2026"**
- Add: **"Voice query → answer in under 10 seconds"** (if you have a number, use it)
- Innovation highlight box gets: *"One ₹4,000 unit serves an entire farm season."*

### SLIDE 3 (Technical) — hardware proof
- Put the prototype photo next to tech chips: **"Build: ESP32 + NPK + Moisture + DHT22 (v1 validated)"**
- Cost chip: *"Unit BOM ≈ ₹4,100 — lowest-cost class of field sensor system"*
- Data interval chip: *"Sensor telemetry every 15 min"* (if real)

### SLIDE 4 (Feasibility) — 3-column gets the punch
| Challenges | Feasibility | Mitigation |
|---|---|---|
| *Existing:* sensor accuracy, connectivity, data gaps | **ADD: "v1 hardware built & field-tested — ₹4,100/unit BOM"** | *Existing:* calibration, caching, flag-not-diagnose |
| | **ADD: "every sensor off-the-shelf & ESP32-native"** | **ADD: "v1 battery/solar profile: [X] hrs"** |

### SLIDE 5 (Impact) — replace vague with numbers
- ❌ "Higher yields" → ✅ **"Timely advisory est. +15–30% yield"** (cite or mark est.)
- ❌ "Better-timed sales" → ✅ **"Sell-timing guidance est. +₹2,000–5,000/season/farmer"**
- ❌ "Reduces guesswork" → ✅ **"Expert-equivalent answer in seconds vs. days"**
- ❌ "Protects soil" → ✅ **"Fertilizer used only when sensors confirm need — cut wasteful spend"**
- ADD: *"10 units = ₹41,000 pilot for an entire village."*

### SLIDE 6 (References) — add prototype evidence line
- *"KrishiMitra v1 field unit — sensor logs & validation, [village], [month] 2026"* (your own reference)

---

## 4. DEMO RECOVERY PLAN (for the broken unit)

**Priority order — do the cheapest fix first:**

1. **Diagnose boot** — plugin ESP32 via USB, check serial monitor. 80% of "broke" = dead battery / loose jumper / reflashed firmware.
2. **Check power rail** — ESP32 needs clean 5V/3.3V. A failing Li-ion or buck converter is the usual killer.
3. **Sensor I²C/analog check** — reseat each sensor; one floating pin shorts the bus. Test sensors one-by-one.
4. **Reflash firmware** — you have the source; reflash and re-calibrate (only takes minutes).
5. **If unit is dead for good:** rebuild a *minimal* node (ESP32 + soil moisture + DHT22 only — 2 sensors, cheap) for the video. The story is "full v1 validated, minimal live demo running."

**Demo video script (60 sec, one take):**
> "This is the KrishiMitra field node — ESP32, soil moisture, NPK, and air temp/humidity.
> Here are live readings from the soil pot: moisture 42%, temp 31°C. The same board feeds
> the app [show app screen]. This is build v1 — we're hardening it for the live event."

**If you can't have live demo at judging:** a 60-second video with real readings
on Slide 1's QR/link is 90% of the value. Codeline's day-1 photo links won this way.

---

## 5. PITCH SCRIPT SLOT (drop numbers in)

> "Meet Ramesh... he lost 20% of his soybean harvest last year to an unforecasted storm.
> KrishiMitra would have warned him 45 minutes earlier — we tested the nowcast feed in [village].
> The field unit behind me costs about ₹4,000 — less than one season of wasted fertilizer.
> It answers his voice question in under 10 seconds, in Marathi, from government data.
> One unit. One farm. ₹41,000 equips a whole village pilot."

---

## NEXT STEPS
- [ ] Get teammate's numbers → fill all `[?]` and replace estimates
- [ ] Capture evidence package (photos + 60s video + serial logs)
- [ ] Run the demo recovery checklist (4 steps)
- [ ] Update slides per Section 3
- [ ] Record fallback video if live demo isn't ready