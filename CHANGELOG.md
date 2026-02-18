## [1.0.1] - 2026-02-18

### PR subjects since 1.0.0
- Prepare 1.0.1 release metadata.

## [1.0.0] - 2026-02-17

### Changed
- Major transport overhaul: replaced Tesla integration with Req.
- Removed legacy `plug` customization API from `Restlax.Client`.
- Simplified dependency surface to Req-centric defaults.
- Removed custom JSON handling from Restlax and now rely on Req defaults.
- Added request customization hook via `req/1` callback in `Restlax.Client`.
