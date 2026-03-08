#!/bin/bash
# Checks that Firebase config files exist before building.
# These files are gitignored — generate them with:
#   flutterfire configure --project=cajou-38741

missing=()

[ ! -f "android/app/google-services.json" ] && missing+=("android/app/google-services.json")
[ ! -f "ios/Runner/GoogleService-Info.plist" ] && missing+=("ios/Runner/GoogleService-Info.plist")
[ ! -f "lib/firebase_options.dart" ] && missing+=("lib/firebase_options.dart")

if [ ${#missing[@]} -ne 0 ]; then
  echo ""
  echo "ERROR: Missing Firebase config files:"
  for f in "${missing[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Run: flutterfire configure --project=cajou-38741"
  echo ""
  exit 1
fi

echo "Firebase config files found."
