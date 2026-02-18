## [1.0.0] - 2026-02-17

### Changed
- Major transport overhaul: replaced Tesla integration with Req.
- Removed legacy `plug` customization API from `Restlax.Client`.
- Simplified dependency surface to Req-centric defaults.
- Removed custom JSON handling from Restlax and now rely on Req defaults.
- Added request customization hook via `req/1` callback in `Restlax.Client`.
