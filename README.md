# KrishiMitra

**Smart India Hackathon 2026 Prototype - Team NOVA_CORE**

Voice-enabled, sensor-driven AI companion for instant, localized guidance on crop health, weather, and markets.

## Overview

Inspired by the "KrishiMitra" idea, this Flutter app is the mobile prototype combining:

1. **Voice + Camera Farm App** - Ask questions, identify pests, get expert-level advice
2. **ESP32 Field Sensors** - Real-time soil moisture, NPK, DHT22 data
3. **Market Price Trend Analysis** - Live mandi prices from Agmarknet/e-NAM
4. **Seasonal Weather Intelligence** - IMD weather data with season advice (Kharif/Rabi/Zaid)
5. **Contamination & Nowcast Alerts** - Early warnings from sensors + CPCB/NWMP data fusion

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Hardware | ESP32, Soil Moisture, NPK, DHT22, pH, EC/TDS, Turbidity, MQ-Gas |
| APIs | IMD Weather, Agmarknet/e-NAM, CPCB/NWMP Water Quality, ISRO Bhuvan |
| Backend | Python (FastAPI) - optional for full stack |

## Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio / VS Code with Flutter extension

### Run the app
```bash
cd krishimitra
flutter pub get
flutter run
```

### Build for Android
```bash
flutter build apk --release
```

### Run for web (quick prototype view)
```bash
flutter run -d chrome
```

## Structure
```
lib/
├── constants/         # App colors, strings, config
├── models/            # Data models (sensor, market, weather, alert)
├── screens/
│   ├── home/          # Dashboard
│   ├── voice_camera/  # Voice assistant + camera
│   ├── sensors/       # ESP32 field sensors
│   ├── market/        # Market prices & trends
│   ├── weather/       # Weather intelligence
│   └── alerts/        # Nowcast & contamination alerts
├── services/          # API service layer
└── widgets/           # Shared UI components
```

## Prototype Features
- Interactive dashboard with quick stats
- Voice waveform UI (simulated listening)
- Live sensor card displays with status indicators
- Custom line chart for price trends
- 7-day weather forecast with rain indicators
- Alert cards with severity badges and suggested actions
- Hindi/English language toggle
- ESP32 Bluetooth connection status indicator

## SIH 2026 Alignment
This prototype directly addresses the SIH 2026 problem statement:
- **Voice + Camera** removes literacy barriers
- **Sensor fusion** replaces guesswork (ESP32 + Govt. data)
- **Government APIs** (IMD, Agmarknet, CPCB, Bhuvan) - all public data
- **Both Software and Hardware** components

## Hardware Requirements
- ESP32 DevKit
- Soil Moisture Sensor (capacitive)
- NPK Sensor
- DHT22 (Temperature & Humidity)
- Optional: pH, EC/TDS, Turbidity, MQ-Gas Sensors

---
*Team NOVA_CORE - KrishiMitra @ SIH 2026*
