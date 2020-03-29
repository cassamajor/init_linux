#!/usr/bin/env python3

from pathlib import Path
import requests

bitwarden_url = 'https://vault.bitwarden.com/download/'
github_url = 'https://api.github.com/repos/bitwarden/desktop/releases/latest'
params = {'app': 'desktop', 'platform': 'linux', 'varient': 'appimage'}
latest_version = requests.get(github_url, timeout=10).json()['name']
download_latest_version = requests.get(bitwarden_url, params=params, timeout=10)

filename = f'Bitwarden-{latest_version}-x86_64.AppImage'
download_location = Path(f'/tmp/{filename}')
download_location.write_bytes(download_latest_version.content)
