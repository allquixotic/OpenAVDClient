#!/bin/bash
# Setup script for OpenAVDClient - Development Environment

echo "Setting up OpenAVDClient development environment..."

# Check if Bun is installed
if ! command -v bun &> /dev/null; then
    echo "Bun is not installed. Install Bun from https://bun.sh/ and re-run this script."
    exit 1
fi

# Check if Node.js is installed for tests/linting
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed."
    echo ""
    echo "Please install Node.js using one of these methods:"
    echo ""
    echo "Option 1 - Using Snap (Recommended):"
    echo "  sudo snap install node --classic"
    echo ""
    echo "Option 2 - Using apt:"
    echo "  sudo apt update"
    echo "  sudo apt install nodejs npm"
    echo ""
    echo "Option 3 - Using nvm (Node Version Manager):"
    echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
    echo "  source ~/.bashrc"
    echo "  nvm install --lts"
    echo ""
    exit 1
fi

echo "Node.js version: $(node --version)"
echo "Bun version: $(bun --version)"
echo ""

# Create build directory
echo "Creating build directory..."
mkdir -p build

# Install dependencies
echo "Installing dependencies..."
if bun install; then
    echo ""
    echo "Setup complete! You can now:"
    echo "  - Run the app: bun run start"
    echo "  - Run validation: bun run verify"
    echo "  - Build macOS: bun run build:mac"
    echo "  - Build snap: bun run build:snap"
    echo "  - Build flatpak: bun run build:flatpak"
    echo "  - Clean build artifacts: bun run clean"
else
    echo ""
    echo "Failed to install dependencies. Please check the error messages above."
    exit 1
fi

