#!/bin/bash

# Windsurf Netlify Skills Installer
# Works on macOS, Linux, and Windows (Git Bash/WSL)

set -e

echo "🌊 Windsurf Netlify Skills Installer"
echo "======================================"
echo ""

# Detect OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*)    PLATFORM=Windows;;
    MINGW*)     PLATFORM=Windows;;
    MSYS*)      PLATFORM=Windows;;
    *)          PLATFORM="UNKNOWN:${OS}"
esac

echo "Detected platform: ${PLATFORM}"
echo ""

# Determine skills directory
if [ "${PLATFORM}" = "Windows" ]; then
    SKILLS_DIR="${USERPROFILE}/.windsurf/skills"
else
    SKILLS_DIR="${HOME}/.windsurf/skills"
fi

# Create skills directory if it doesn't exist
if [ ! -d "${SKILLS_DIR}" ]; then
    echo "Creating Windsurf skills directory..."
    mkdir -p "${SKILLS_DIR}"
fi

# Check if we're in the repo directory
if [ ! -d "netlify-creating-sites" ]; then
    echo "❌ Error: Please run this script from the windsurf-netlify-skills directory"
    echo ""
    echo "Usage:"
    echo "  git clone https://github.com/jaredm563/windsurf-netlify-skills.git"
    echo "  cd windsurf-netlify-skills"
    echo "  ./install.sh"
    exit 1
fi

# Count existing skills
EXISTING_COUNT=0
for skill in netlify-*; do
    if [ -d "${SKILLS_DIR}/${skill}" ]; then
        EXISTING_COUNT=$((EXISTING_COUNT + 1))
    fi
done

if [ ${EXISTING_COUNT} -gt 0 ]; then
    echo "⚠️  Found ${EXISTING_COUNT} existing Netlify skill(s) in ${SKILLS_DIR}"
    echo ""
    read -p "Overwrite existing skills? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
fi

# Copy skills
echo ""
echo "Installing skills to ${SKILLS_DIR}..."
echo ""

INSTALLED=0
for skill in netlify-*; do
    if [ -d "${skill}" ]; then
        echo "  ✓ ${skill}"
        cp -r "${skill}" "${SKILLS_DIR}/"
        INSTALLED=$((INSTALLED + 1))
    fi
done

echo ""
echo "======================================"
echo "✅ Successfully installed ${INSTALLED} skills!"
echo ""
echo "Skills installed in: ${SKILLS_DIR}"
echo ""
echo "Windsurf will automatically reference these skills"
echo "when working on Netlify projects."
echo ""
echo "Happy coding! 🚀"
