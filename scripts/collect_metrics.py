#!/usr/bin/env python3
"""
PRoNTo GitHub Metrics Collector
Collects stars, forks, release downloads, clones and views
and appends them to metrics/metrics.csv
"""

import os
import csv
import json
import datetime
import urllib.request
import urllib.error

REPO   = os.environ.get('GITHUB_REPOSITORY', 'MLNL/PRoNTo')
TOKEN  = os.environ.get('GITHUB_TOKEN', '')
TODAY  = datetime.date.today().isoformat()

HEADERS = {
    'Authorization': f'token {TOKEN}',
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'PRoNTo-metrics-collector'
}

def get(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())

def get_repo_stats():
    data = get(f'https://api.github.com/repos/{REPO}')
    return {
        'stars':     data.get('stargazers_count', 0),
        'forks':     data.get('forks_count', 0),
        'watchers':  data.get('subscribers_count', 0),
        'open_issues': data.get('open_issues_count', 0),
    }

def get_release_downloads():
    releases = get(f'https://api.github.com/repos/{REPO}/releases')
    total = 0
    per_release = {}
    for rel in releases:
        tag  = rel.get('tag_name', 'unknown')
        count = sum(a.get('download_count', 0) for a in rel.get('assets', []))
        per_release[tag] = count
        total += count
    return total, per_release

def get_traffic(endpoint):
    """Get clones or views — requires push access token"""
    try:
        data = get(f'https://api.github.com/repos/{REPO}/traffic/{endpoint}')
        return data.get('count', 0), data.get('uniques', 0)
    except urllib.error.HTTPError:
        # Traffic API requires push access — returns 403 otherwise
        return 0, 0

def append_to_csv(row, filepath='metrics/metrics.csv'):
    file_exists = os.path.isfile(filepath)
    with open(filepath, 'a', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=row.keys())
        if not file_exists:
            writer.writeheader()
        writer.writerow(row)
    print(f"✓ Metrics saved to {filepath}")

def main():
    print(f"Collecting metrics for {REPO} on {TODAY}...")

    stats = get_repo_stats()
    total_downloads, per_release = get_release_downloads()
    clone_count, clone_uniques   = get_traffic('clones')
    view_count,  view_uniques    = get_traffic('views')

    # Build latest release name and downloads
    latest_release = list(per_release.keys())[0] if per_release else 'none'
    latest_downloads = list(per_release.values())[0] if per_release else 0

    row = {
        'date':                TODAY,
        'stars':               stats['stars'],
        'forks':               stats['forks'],
        'watchers':            stats['watchers'],
        'open_issues':         stats['open_issues'],
        'total_downloads':     total_downloads,
        'latest_release':      latest_release,
        'latest_downloads':    latest_downloads,
        'clones_14d':          clone_count,
        'unique_clones_14d':   clone_uniques,
        'views_14d':           view_count,
        'unique_views_14d':    view_uniques,
        'per_release_json':    json.dumps(per_release),
    }

    for k, v in row.items():
        if k != 'per_release_json':
            print(f"  {k}: {v}")

    append_to_csv(row)

if __name__ == '__main__':
    main()
