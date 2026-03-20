#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Generate a self-signed TLS cert/key and encode them as base64 for .env

Usage: ./scripts/generate-env-cert.sh [--ip <LAN_IP>]
  --ip, -i   Optional IP reachable by your phone on the local network (e.g., 192.168.1.42).
  -h, --help Show this help.

The cert and key will be encoded as a JSON object and output as TLS_OPTIONS
environment variable ready to be added to your .env file.
EOF
}

EXTRA_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip|-i)
      EXTRA_IP=${2:-}
      if [[ -z "$EXTRA_IP" ]]; then
        echo "--ip requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required but not found in PATH" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

# Create temporary files for cert and key
TEMP_CERT=$(mktemp)
TEMP_KEY=$(mktemp)
OPENSSL_CFG=$(mktemp)
trap 'rm -f "$TEMP_CERT" "$TEMP_KEY" "$OPENSSL_CFG"' EXIT

cat > "$OPENSSL_CFG" <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = US
ST = Local
L = Local
O = Local Dev
CN = localhost

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

if [[ -n "$EXTRA_IP" ]]; then
  echo "IP.3 = ${EXTRA_IP}" >> "$OPENSSL_CFG"
fi

# Generate certificate and key
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout "$TEMP_KEY" \
  -out "$TEMP_CERT" \
  -config "$OPENSSL_CFG" 2>/dev/null

# Read cert and key content
CERT_CONTENT=$(cat "$TEMP_CERT")
KEY_CONTENT=$(cat "$TEMP_KEY")

# Create JSON object with cert and key
JSON_OBJECT=$(jq -n \
  --arg cert "$CERT_CONTENT" \
  --arg key "$KEY_CONTENT" \
  '{cert: $cert, key: $key}')

# Encode to base64
TLS_OPTIONS_BASE64=$(echo -n "$JSON_OBJECT" | base64)

echo ""
echo "✓ Certificate and key generated successfully"
echo ""
echo "Add the following line to your .env file:"
echo ""
echo "TLS_OPTIONS=$TLS_OPTIONS_BASE64"
echo ""

# Offer to append to .env file
if [[ -f "$ENV_FILE" ]]; then
  read -p "Append to $ENV_FILE? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check if TLS_OPTIONS already exists
    if grep -q "^TLS_OPTIONS=" "$ENV_FILE"; then
      echo "Warning: TLS_OPTIONS already exists in .env file"
      read -p "Overwrite existing TLS_OPTIONS? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Use sed to replace the line (macOS compatible)
        if [[ "$OSTYPE" == "darwin"* ]]; then
          sed -i '' "s|^TLS_OPTIONS=.*|TLS_OPTIONS=$TLS_OPTIONS_BASE64|" "$ENV_FILE"
        else
          sed -i "s|^TLS_OPTIONS=.*|TLS_OPTIONS=$TLS_OPTIONS_BASE64|" "$ENV_FILE"
        fi
        echo "✓ Updated TLS_OPTIONS in $ENV_FILE"
      fi
    else
      echo "" >> "$ENV_FILE"
      echo "TLS_OPTIONS=$TLS_OPTIONS_BASE64" >> "$ENV_FILE"
      echo "✓ Added TLS_OPTIONS to $ENV_FILE"
    fi
  fi
fi
