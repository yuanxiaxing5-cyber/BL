# Oh My Keymint - Changelog Branch

This branch is automatically updated by GitHub Actions when a new release is published.

## Files

- `changelog.md` - Latest release notes
- `update.json` - Module update metadata (version, download URL, changelog link)
- `module.json` - Module information for KernelSU module repository

## How it works

When you publish or edit a release on GitHub, the `Update Changelog and Metadata` workflow automatically:
1. Extracts the release body into `changelog.md`
2. Generates `update.json` with version info and download links
3. Commits and pushes changes to this `changelog` branch

The module's `updateJson` field points to `update.json` on this branch, enabling in-app update checks.
