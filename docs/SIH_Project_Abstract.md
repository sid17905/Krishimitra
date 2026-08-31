# AgriCredit AI
### Explainable AI for Fair Farmer Credit Access

**Track:** Open Innovation (FinTech + AgriTech + AI/ML)

---

## Problem Statement

Millions of smallholder and marginal farmers in India remain excluded from formal credit — not because they're financially unviable, but because they're assessed the wrong way. Banks rely almost entirely on land records and past repayment history, ignoring the factors that actually determine whether a farmer's season will be profitable: soil health, weather, crop choice, and market prices. The result: creditworthy farmers get rejected or under-financed, and many fall back on informal moneylenders at exploitative interest rates — even while government credit and subsidy schemes meant for them go underutilized simply because eligibility is hard to establish.

## Proposed Solution

**AgriCredit AI** is an explainable, AI-driven bankability platform that sits between farmers and lenders — a decision-support layer that banks, NBFCs, and digital lending platforms can plug into their existing loan process, rather than a lending app in itself.

- **Bankability Score Engine** — an ML model that scores a farmer's near-term repayment potential using dynamic, farm-specific data: soil condition, weather patterns, crop type and yield history, and live + historical market prices — instead of static collateral checks alone.
- **Explainability Layer** — every score comes with a plain-language breakdown of *why*, so both the farmer and the loan officer can see and trust the reasoning, not just a number.
- **Scheme Eligibility Assistant** — automatically flags which government schemes (crop insurance, interest subvention, Kisan Credit Card benefits) a farmer likely qualifies for, and pre-fills the application.

## Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Farmer App | Flutter | Cross-platform, runs well on low-end Android devices common in rural India |
| Localization / Voice | Bhashini API (or Google ML Kit) | Regional language + voice input for low-literacy users |
| Lender Dashboard | React + Tailwind | Clean, fast interface for loan officers |
| Backend / API | Python (FastAPI) | Serves ML inference and business logic |
| ML Model | scikit-learn / XGBoost | Solid, explainable performance on structured tabular data |
| Explainability | SHAP | Converts model output into human-readable factor breakdowns |
| Data Sources | IMD (weather), Agmarknet (mandi prices), Soil Health Card portal, state land records | Public, credible, India-specific datasets |
| Database | PostgreSQL + Firebase/Firestore | Structured storage + offline-first sync for patchy rural connectivity |
| Infra (demo) | Docker, AWS/GCP free tier | Quick to spin up and demo within hackathon constraints |

## Workflow Plan

```
Farmer App (voice / regional language)
        │
        ▼
Data Aggregation Layer  ──────────────►  Weather (IMD) · Market Prices (Agmarknet)
        │                                Soil Health · Land Records · Repayment History
        ▼
ML Bankability Scoring Engine
        │
        ├──► Explainability Layer (SHAP) ──► plain-language "why this score"
        │
        └──► Scheme Eligibility Module ──► pre-filled scheme applications
        │
        ▼
Lender Dashboard (loan officer reviews score + explanation)
        │
        ▼
Human-in-the-loop Approval Decision
        │
        ▼
Outcome + Explanation sent back to Farmer App
        │
        ▼
Feedback Loop (approved outcomes retrain/improve the model over time)
```

1. **Onboarding** — farmer registers via app in their language; enters basic farm details (location, crop, land size).
2. **Aggregation** — backend pulls weather, soil, market, and available repayment data for that farm/region.
3. **Scoring** — the ML model turns aggregated features into a bankability score.
4. **Explaining** — SHAP breaks the score into the top factors driving it, in plain language.
5. **Eligibility Check** — a parallel module flags which schemes the farmer likely qualifies for.
6. **Lender Review** — score, explanation, and eligibility flags appear on the bank/NBFC dashboard for human sign-off — the model informs, it doesn't decide.
7. **Feedback** — outcomes flow back to the farmer and into the model, improving future scoring.

## What Makes This Different

Most credit-scoring tools for farmers are black boxes, and most fintech pitches in this space quietly assume they'll become the lender — which runs straight into RBI licensing requirements around who's allowed to lend, assess credit, and hold financial data. AgriCredit AI is designed to work *with* the regulatory grain from day one: it's built as a support tool for regulated lenders, with built-in explainability and a human-in-the-loop approval step — mirroring the direction India's own digital lending infrastructure (Account Aggregator framework, RBI's Unified Lending Interface, e-KCC) is already moving in. That's a credibility edge most competing ideas won't have thought through.

## Impact

- **Farmers** get a fairer shot at institutional credit, evaluated on real agricultural potential rather than collateral alone, in their own language.
- **Lenders** get a tool that helps them meet priority-sector agricultural lending targets they're already required to hit, with better risk visibility and an auditable score.
- **Policy-level impact**: greater formal credit penetration in rural India, reduced dependence on informal high-interest lending, and higher utilization of existing government schemes.

## Feasibility

Every component above is buildable within a hackathon timeframe using public datasets and open-source tools — no proprietary bank data or licensing required for the demo. The architecture is modular and lender-agnostic by design, so it can plug into a partner bank's existing systems rather than needing one built from scratch.

---
*One-page abstract for internal hackathon pitch / registration.*
