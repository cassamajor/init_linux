#!/usr/bin/env python3

from pathlib import Path
import requests

url = 'https://api.github.com/repos/bitwarden/desktop/releases/latest'
latest_version = requests.get(url, timeout=10).json()
filename = f'Bitwarden-{latest_version["name"]}-x86_64.AppImage'

latest_version_url = [asset['browser_download_url'] for asset in latest_version['assets'] if asset['name'] == filename][0]

download_latest_version = requests.get(latest_version_url, timeout=10)
download_location = Path(f'/tmp/{filename}')
download_location.write_bytes(download_latest_version.content)
