# PRoNTo Usage Metrics

This folder contains automatically collected usage metrics for the PRoNTo GitHub repository.

## metrics.csv

Updated every Monday by a GitHub Action. Columns:

| Column | Description |
|---|---|
| `date` | Date of collection (YYYY-MM-DD) |
| `stars` | Total GitHub stars |
| `forks` | Total forks |
| `watchers` | Repository watchers |
| `open_issues` | Number of open issues |
| `total_downloads` | Total release asset downloads (all versions) |
| `latest_release` | Tag name of the most recent release |
| `latest_downloads` | Downloads of the most recent release |
| `clones_14d` | Total clones in the last 14 days |
| `unique_clones_14d` | Unique cloners in the last 14 days |
| `views_14d` | Total page views in the last 14 days |
| `unique_views_14d` | Unique visitors in the last 14 days |
| `per_release_json` | Downloads broken down by release tag (JSON) |

## Notes

- Traffic data (clones, views) requires a token with **push access** to the repository.
- The Action runs automatically every Monday at 9am UTC.
- You can also trigger it manually from the **Actions** tab on GitHub.
