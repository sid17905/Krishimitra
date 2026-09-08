#!/usr/bin/env python3
"""Generate QR codes for Krishimitra app and website."""

import os
import qrcode

def save_image(img, path):
    with open(path, "wb") as f:
        img.save(f, format="PNG")

def generate():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    docs_dir = os.path.join(base_dir, "docs")
    assets_dir = os.path.join(base_dir, "assets", "images")

    os.makedirs(docs_dir, exist_ok=True)
    os.makedirs(assets_dir, exist_ok=True)

    website_url = "https://sid17905.github.io/Krishimitra/"
    apk_url = "https://sid17905.github.io/Krishimitra/download.html?auto=true"
    apk_direct_url = "https://github.com/sid17905/Krishimitra/releases/download/v1.0.0/app-release.apk"

    # Website QR
    qr_web = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=4,
    )
    qr_web.add_data(website_url)
    qr_web.make(fit=True)
    img_web = qr_web.make_image(fill_color="#1a472a", back_color="white").convert("RGB")
    
    web_file = os.path.join(docs_dir, "qr_website.png")
    save_image(img_web, web_file)
    save_image(img_web, os.path.join(docs_dir, "krishimitra_qr.png"))
    save_image(img_web, os.path.join(assets_dir, "krishimitra_qr.png"))
    print(f"Saved Website QR -> {web_file}")

    # APK QR
    qr_app = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=4,
    )
    qr_app.add_data(apk_url)
    qr_app.make(fit=True)
    img_app = qr_app.make_image(fill_color="#1a472a", back_color="white").convert("RGB")

    apk_file = os.path.join(docs_dir, "qr_apk.png")
    save_image(img_app, apk_file)
    save_image(img_app, os.path.join(docs_dir, "krishimitra_apk_qr.png"))
    print(f"Saved APK QR -> {apk_file}")

    print("\nSummary:")
    print(f"  Website URL:    {website_url}")
    print(f"  APK Portal URL: {apk_url}")
    print(f"  APK Direct URL: {apk_direct_url}")

if __name__ == "__main__":
    generate()
