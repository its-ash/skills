# Publishing, Monetization, and Release Checklist

## Publish
1. Prepare: check manifest version, icons, required fields.
2. Test: load unpacked in `chrome://extensions` with Developer Mode on. Firefox: `web-ext lint`.
3. Package: zip the extension root. Exclude source-control files.
4. Upload: Chrome Web Store or Mozilla Add-ons. Explain each requested permission.

## Monetize (optional)
- Open a donation page from `chrome.runtime.onInstalled`.
- Offer a premium tier that uses extra optional permissions.
- Follow each store's payment policy.

## Release checklist
- [ ] Folders follow the standard layout.
- [ ] `manifest_version: 3`; all file paths correct.
- [ ] Only required permissions; optional permissions where they fit.
- [ ] Service worker has an `onInstalled` handler and does not block.
- [ ] Content scripts set `run_at` and precise `matches`.
- [ ] UI pages load ES modules with `type="module"`.
- [ ] Message handlers call `sendResponse` and return `true` for async replies.
- [ ] Storage calls use the Chrome Storage API with error handling.
- [ ] Lint passes (`web-ext lint`; no `chrome://extensions` warnings).
- [ ] Tested in Chrome, Edge, and Firefox.
- [ ] Zip holds only needed files and icons.
- [ ] Store listing explains each permission and has screenshots.
