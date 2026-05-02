default:
    @just --list

install:
    bun install

lint:
    bun run lint

test:
    bun run test

verify: lint test
    bun audit

macos-check:
    ./scripts/macos-release.sh check

macos-build:
    bun run build:mac

macos-store-notary-credentials:
    ./scripts/macos-release.sh store-credentials

macos-release: verify
    ./scripts/macos-release.sh release
