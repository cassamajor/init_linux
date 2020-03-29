#!/usr/bin/env python3

from pathlib import Path
import requests
import re

url = 'https://data.services.jetbrains.com/products/releases'
params = {'code': 'PC', 'latest': True, 'type': 'release'}
latest_version_url = requests.get(url,params=params, timeout=10).json()['PCP'][0]['downloads']['linux']['link']
download_latest_version = requests.get(latest_version_url, timeout=10)

filename = Path(latest_version_url).name
# filename = re.search('pycharm.+gz', latest_version_url)[0]
download_location = Path(f'/tmp/{filename}')
# download_location = Path(f'/tmp/pycharm-latest.tar.gz')
download_location.write_bytes(download_latest_version.content)
print(f'{download_location}')