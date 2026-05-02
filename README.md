# OpenAVDClient
OpenAVDClient means **Open Azure Virtual Desktop Client**. It is an unofficial Electron client for Azure Virtual Desktop web access at `https://windows.cloud.microsoft`.
The project wraps the Windows Cloud Devices web interface in a native shell, uses a current Microsoft Edge on Windows x64 browser profile for compatibility, and supports Linux packaging while also building native Apple Silicon macOS artifacts.
## Features
- Microsoft Edge-compatible User-Agent and Client Hints for Windows 11 x64 compatibility.
- Azure Virtual Desktop remote-session popup handling with shared authentication/session state.
- Camera, microphone, media, notification, pointer-lock, and fullscreen permission handling.
- Focus-gated keyboard handling so renderer keyboard input is explicitly blocked if Electron ever receives it while the target window is not focused and visible.
- Sandboxed Electron renderer windows.
- Linux Snap and Flatpak packaging metadata.
- macOS Apple Silicon packaging with signing/notarization automation.
## Prerequisites
- Bun 1.3.13 or newer for the preferred install/build workflow.
- Node.js for the built-in `node --test` and syntax checks.
- Xcode Command Line Tools or Xcode for macOS signing/notarization.
- `just` for the release recipes in `Justfile`.
- Linux-only package builds additionally need Snapcraft or Flatpak Builder.
## Development
Install dependencies from the repository root:
```bash
bun install
```
Run the app:
```bash
bun run start
```
Run quick validation:
```bash
bun run lint
bun run test
bun run verify
```
## macOS Apple Silicon build
Build a signed macOS arm64 app/DMG/zip using electron-builder:
```bash
bun run build:mac
```
Build an unpacked `.app` only:
```bash
bun run build:mac:dir
```
The default macOS output is written to `build/dist/`. With the current metadata, the primary app bundle is `build/dist/mac-arm64/OpenAVDClient.app` and the DMG name starts with `OpenAVDClient-`.
## macOS signing, notarization, and stapling
The `Justfile` wraps a Developer ID signing and Apple notarization flow:
```bash
just macos-release
```
The release recipe uses system Bun, discovers a `Developer ID Application` signing identity unless `CODESIGN_ID` or `CSC_NAME` is set, validates `notarytool`/`stapler`, builds a signed arm64 `.app`, notarizes and staples the `.app`, then creates, signs, notarizes, staples, and validates a DMG.
By default, notarization uses the keychain profile `OpenAVDClientNotaryProfile`. To create or refresh that profile without printing secrets, provide `APPLE_ID`, `APP_PASSWORD`, and optionally `TEAM_ID`/`CODESIGN_ID`, then run:
```bash
just macos-store-notary-credentials
```
`TEAM_ID` can be omitted if `CODESIGN_ID` contains a team ID in parentheses.
## Linux packaging
The Linux command/package identifiers remain compatible with the upstream project, but user-facing names now display OpenAVDClient.
Build a Snap:
```bash
bun run build:snap
```
Build a Flatpak:
```bash
bun run build:flatpak
```
## Configuration
OpenAVDClient stores runtime settings in Electron user data:
- Linux non-Snap: `~/.config/windows-app-for-linux/config.json` for compatibility with existing installs.
- Snap: `$SNAP_USER_DATA/config.json`.
- macOS and other platforms: Electron’s native per-app user data path.
The settings dialog can change the default connection URL, User-Agent string, default window size, and cookies/cache.
The built-in default User-Agent is a current common Microsoft Edge Stable profile for Windows x64:
```text
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36 Edg/147.0.3912.60
```
Windows 11 still reports `Windows NT 10.0` in Chromium-family User-Agent strings; Windows 11 identity is represented through Client Hints.
## Keyboard shortcuts
- F11: Toggle fullscreen.
- F12: Toggle Developer Tools.
- Cmd/Ctrl+N: New window.
- Cmd/Ctrl+R: Reload.
- Cmd/Ctrl+Shift+R: Force reload.
Keyboard shortcuts are handled only while the relevant Electron window is focused and visible.
## Project structure
```text
.
├── src/
│   ├── main.js
│   ├── app-metadata.js
│   ├── input-guard.js
│   ├── windows-app-for-linux.desktop
│   └── windows-app-for-linux.desktop.yml
├── scripts/
│   ├── build-snap.sh
│   ├── lint.sh
│   └── macos-release.sh
├── tests/
├── docs/
├── snapcraft.yaml
├── Justfile
├── package.json
└── bun.lock
```
## Notes
- OpenAVDClient is not affiliated with or endorsed by Microsoft.
- A Microsoft account and an Azure Virtual Desktop entitlement are required to use the service.
- Direct third-party dependencies are pinned to current stable Electron and electron-builder versions; transitive versions are controlled by those upstream packages.
