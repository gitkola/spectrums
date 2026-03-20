#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Generate a self-signed TLS cert/key for local testing.

Usage: ./scripts/generate-dev-cert.sh [--ip <LAN_IP>]
  --ip, -i   Optional IP reachable by your phone on the local network (e.g., 192.168.1.42).
  -h, --help Show this help.

The cert and key will be written to ./certs/cert.pem and ./certs/key.pem.
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
CERT_DIR="$ROOT_DIR/certs"
CERT_FILE="$CERT_DIR/cert.pem"
KEY_FILE="$CERT_DIR/key.pem"

mkdir -p "$CERT_DIR"

OPENSSL_CFG=$(mktemp)
trap 'rm -f "$OPENSSL_CFG"' EXIT

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

openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -config "$OPENSSL_CFG"

echo "Created cert: $CERT_FILE"
echo "Created key:  $KEY_FILE"
