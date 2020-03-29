#!/usr/bin/env python3

from pathlib import Path
import requests
import re

url = 'https://api.github.com/repos/bitwarden/desktop/releases/latest'
github_assets = requests.get(url, timeout=10).json()['assets']
latest_version_url = [download_url['browser_download_url'] for download_url in github_assets if
                      re.search('https.+AppImage', download_url['browser_download_url'])][0]
download_latest_version = requests.get(latest_version_url, timeout=10)

filename = Path(latest_version_url).name
# filename = re.search('Bitwarden.+AppImage', latest_version_url)[0]
download_location = Path(f'/tmp/{filename}')
download_location.write_bytes(download_latest_version.content)