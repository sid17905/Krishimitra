#!/usr/bin/env python3
"""Generate QR codes for Krishimitra app and website."""

import qrcode
import os

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "docs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# --- Links ---
WEBSITE_URL = "https://sid17905.github.io/Krishimitra/"
APK_URL = "https://github.com/sid17905/Krishimitra/releases/download/v1.0.0/app-release.apk"

# --- Generate Website QR ---
qr_website = qrcode.QRCode(version=1, box_size=10, border=4)
qr_website.add_data(WEBSITE_URL)
qr_website.make(fit=True)
img_website = qr_website.make_image(fill_color="#1a472a", back_color="white")
website_path = os.path.join(OUTPUT_DIR, "qr_website.png")
img_website.save(website_path)
print(f"Website QR saved: {website_path}")

# --- Generate APK QR ---
qr_apk = qrcode.QRCode(version=1, box_size=10, border=4)
qr_apk.add_data(APK_URL)
qr_apk.make(fit=True)
img_apk = qr_apk.make_image(fill_color="#1a472a", back_color="white")
apk_path = os.path.join(OUTPUT_DIR, "qr_apk.png")
img_apk.save(apk_path)
print(f"APK QR saved: {apk_path}")

print("\nDone! Both QR codes generated successfully.")
print(f"Website: {WEBSITE_URL}")
print(f"APK:     {APK_URL}")
