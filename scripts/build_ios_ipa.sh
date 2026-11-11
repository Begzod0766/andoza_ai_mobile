#!/usr/bin/env bash
# Build an App Store IPA on this Mac with the paid team L797T8GBY4 and no
# registered iPhone.
#
# Why this is not just `flutter build ipa`: automatic signing archives with an
# *development* profile first, and Apple will not create one while the team has
# no devices. So we archive unsigned, sign the archived app locally with the
# Apple Development certificate *and* Runner.entitlements (that puts Sign in with
# Apple and push into the binary), then let `xcodebuild -exportArchive` re-sign
# it with Xcode's cloud-managed Apple Distribution certificate. The export reads
# the entitlements from the binary and turns aps-environment into "production".
#
# Needs: Xcode signed in (Settings → Accounts) with the team, its Apple
# Development certificate in the login keychain, and Sign In with Apple + Push
# Notifications enabled on the App ID uz.andozaai.app in the developer portal.
#
# Output: build/ios/ipa-appstore/*.ipa (upload with Transporter or Xcode).
# UPLOAD=1 ./scripts/build_ios_ipa.sh also sends the build to App Store Connect
# through the Xcode account (no password or API key needed here).
set -euo pipefail

TEAM=L797T8GBY4
BUNDLE=uz.andozaai.app
API=${API_URL:-https://andozaai.uz/api/v1}
BASE=${API_BASE_URL:-https://andozaai.uz}
STUDIO=${STUDIO_BASE_URL:-https://andozaai.uz}

cd "$(dirname "$0")/.."
OUT=build/ios/ipa-appstore
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# The Apple Development certificate issued to this team (its subject OU is the team id).
IDENTITY=""
while IFS= read -r line; do
  hash=$(echo "$line" | awk '{print $2}')
  name=$(echo "$line" | sed 's/^[^"]*"\(.*\)"$/\1/')
  ou=$(security find-certificate -c "$name" -p 2>/dev/null \
    | openssl x509 -noout -subject -nameopt multiline 2>/dev/null \
    | awk -F' = ' '/organizationalUnitName/{print $2}')
  if [ "$ou" = "$TEAM" ]; then IDENTITY=$hash; break; fi
done < <(security find-identity -v -p codesigning | grep '"Apple Development:')
[ -n "$IDENTITY" ] || { echo "No Apple Development certificate for team $TEAM" >&2; exit 1; }

flutter build ipa --release --no-codesign \
  --dart-define=API_URL="$API" \
  --dart-define=API_BASE_URL="$BASE" \
  --dart-define=STUDIO_BASE_URL="$STUDIO"

ARCHIVE=$WORK/Runner.xcarchive
cp -R build/ios/archive/Runner.xcarchive "$ARCHIVE"
APP=$ARCHIVE/Products/Applications/Runner.app

cat > "$WORK/app.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>application-identifier</key><string>$TEAM.$BUNDLE</string>
<key>com.apple.developer.team-identifier</key><string>$TEAM</string>
<key>get-task-allow</key><true/>
</dict></plist>
EOF
cp "$WORK/app.plist" "$WORK/ext.plist"
plutil -replace application-identifier -string "$TEAM.$BUNDLE.ShareExtension" "$WORK/ext.plist"
# Capabilities come from Runner.entitlements (PlistBuddy: these keys contain dots).
PB=/usr/libexec/PlistBuddy
SIWA=$($PB -c "Print :com.apple.developer.applesignin:0" ios/Runner/Runner.entitlements)
$PB -c "Add :com.apple.developer.applesignin array" \
    -c "Add :com.apple.developer.applesignin:0 string $SIWA" \
    -c "Add :aps-environment string development" "$WORK/app.plist"

for f in "$APP"/Frameworks/*; do codesign -f -s "$IDENTITY" "$f" >/dev/null; done
for x in "$APP"/PlugIns/*.appex; do codesign -f -s "$IDENTITY" --entitlements "$WORK/ext.plist" "$x"; done
codesign -f -s "$IDENTITY" --entitlements "$WORK/app.plist" "$APP"

cat > "$WORK/export.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>app-store-connect</string>
<key>signingStyle</key><string>automatic</string>
<key>teamID</key><string>$TEAM</string>
<key>destination</key><string>export</string>
<key>uploadSymbols</key><true/>
</dict></plist>
EOF
rm -rf "$OUT"
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath "$OUT" \
  -exportOptionsPlist "$WORK/export.plist" -allowProvisioningUpdates

IPA=$(ls "$OUT"/*.ipa)
mkdir "$WORK/check" && unzip -q "$IPA" -d "$WORK/check"
ENT=$(codesign -d --entitlements :- "$WORK/check/Payload/Runner.app" 2>/dev/null)
for k in "aps-environment" "com.apple.developer.applesignin"; do
  echo "$ENT" | grep -q "$k" || { echo "IPA is missing $k" >&2; exit 1; }
done
echo "OK: $IPA"

if [ "${UPLOAD:-0}" = "1" ]; then
  sed 's|<string>export</string>|<string>upload</string>|' "$WORK/export.plist" > "$WORK/upload.plist"
  xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath "$WORK/upload" \
    -exportOptionsPlist "$WORK/upload.plist" -allowProvisioningUpdates
  echo "Uploaded; App Store Connect processes it for ~15-30 min before TestFlight shows it."
fi
