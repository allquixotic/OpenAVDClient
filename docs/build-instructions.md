# Build Instructions for OpenAVDClient
OpenAVDClient means **Open Azure Virtual Desktop Client**. These instructions cover development, Linux packaging, and macOS Apple Silicon release builds.
## Common development commands
Install dependencies from the repository root:
```bash
bun install
```
Run validation:
```bash
bun run lint
bun run test
bun run verify
```
Run from source:
```bash
bun run start
```
## macOS arm64 build
Build the regular electron-builder macOS artifacts:
```bash
bun run build:mac
```
Build only the unpacked `.app`:
```bash
bun run build:mac:dir
```
The app bundle displays as `OpenAVDClient.app` and uses the bundled `.icns` icon.
## Signed, notarized, stapled macOS release
The `Justfile` uses a Developer ID Application identity, `xcrun notarytool`, and `xcrun stapler`.
Create or refresh the notarytool keychain profile:
```bash
APPLE_ID="you@example.com" APP_PASSWORD="app-specific-password" just macos-store-notary-credentials
```
If `TEAM_ID` is not provided, the script tries to derive it from `CODESIGN_ID`.
Build, sign, notarize, staple, and validate:
```bash
just macos-release
```
Defaults:
- `NOTARY_PROFILE=OpenAVDClientNotaryProfile`
- first available `Developer ID Application` identity if `CODESIGN_ID`/`CSC_NAME` is unset
- output directory `build/dist`
## Snap package
Install Snapcraft:
```bash
sudo snap install snapcraft --classic
```
Build:
```bash
bun run build:snap
```
The Snap command remains `windows-app-for-linux` for compatibility, while desktop UI metadata displays `OpenAVDClient`.
## Flatpak package
Install Flatpak tooling:
```bash
sudo apt install flatpak flatpak-builder
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```
Build:
```bash
bun run build:flatpak
```
Install locally:
```bash
bun run install:flatpak
```
The Flatpak app-id currently remains `com.microsoft.WindowsAppForLinux` for upstream compatibility.
