#!/bin/bash
set -e

APP_NAME="AppForegronder"
BUILD_DIR=".build/release"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
SDK="/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk"

echo "=== Compiling ${APP_NAME} ==="
mkdir -p "${BUILD_DIR}"
swiftc -parse-as-library \
    -sdk "${SDK}" \
    -target arm64-apple-macosx13.0 \
    -O \
    -framework AppKit \
    -framework SwiftUI \
    -framework ServiceManagement \
    -o "${BUILD_DIR}/${APP_NAME}" \
    AppForegronder/*.swift

echo "=== Creating app bundle ==="
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
cp AppForegronder/Info.plist "${APP_BUNDLE}/Contents/"
cp AppForegronder/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"

cat > "${APP_BUNDLE}/Contents/PkgInfo" << 'EOF'
APPL????
EOF

echo "=== Signing ==="
if [ -n "${SIGNING_IDENTITY:-}" ]; then
    codesign --force --sign "${SIGNING_IDENTITY}" \
        --entitlements AppForegronder/AppForegronder.entitlements \
        --options runtime \
        "${APP_BUNDLE}"
    echo "Signed with ${SIGNING_IDENTITY}"
else
    echo "Skipped (set SIGNING_IDENTITY to sign)"
fi

echo "=== Done ==="
echo "App bundle: ${APP_BUNDLE}"
echo ""
echo "Install to Applications:"
echo "  cp -r ${APP_BUNDLE} /Applications/"
echo ""
echo "Or run directly:"
echo "  open ${APP_BUNDLE}"
