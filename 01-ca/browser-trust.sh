#!/bin/bash

# Import the local step-ca root certificate into browser NSS stores

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_DIR="$SCRIPT_DIR/step-ca-config"
ROOT_CERT="$CONFIG_DIR/certs/root_ca.crt"
CERT_NAME="Kub Domain CA"

if [ ! -f "$ROOT_CERT" ]; then
    echo "Root certificate not found at $ROOT_CERT" >&2
    exit 1
fi

if ! command -v certutil >/dev/null 2>&1; then
    echo "certutil not found. Install libnss3-tools (e.g. sudo apt install libnss3-tools)." >&2
    exit 1
fi

collect_nss_dirs() {
    local results=()
    local chrome_base=("$HOME/.pki/nssdb")
    local search_roots=("$HOME/.config/google-chrome" "$HOME/.config/chromium" "$HOME/.mozilla/firefox")

    for base in "${chrome_base[@]}"; do
        results+=("$base")
    done

    for root in "${search_roots[@]}"; do
        if [ -d "$root" ]; then
            while IFS= read -r db_file; do
                results+=("$(dirname "$db_file")")
            done < <(find "$root" -maxdepth 4 -type f -name "cert9.db" -print 2>/dev/null)
        fi
    done

    if [ ${#results[@]} -gt 0 ]; then
        printf '%s
' "${results[@]}" | awk 'NF' | sort -u
    fi
}

init_nss_db() {
    local dir="$1"
    mkdir -p "$dir"
    if [ ! -f "$dir/cert9.db" ]; then
        certutil -N --empty-password -d "sql:$dir" >/dev/null 2>&1 || {
            echo "Failed to initialize NSS DB at $dir" >&2
            return 1
        }
        echo "Initialized NSS DB at $dir"
    fi
}

import_cert() {
    local dir="$1"
    init_nss_db "$dir" || return 1
    certutil -D -n "$CERT_NAME" -d "sql:$dir" >/dev/null 2>&1 || true
    if certutil -A -n "$CERT_NAME" -t "C,C,C" -i "$ROOT_CERT" -d "sql:$dir" >/dev/null 2>&1; then
        echo "Trusted $CERT_NAME in $dir"
    else
        echo "Failed to trust $CERT_NAME in $dir" >&2
        return 1
    fi
}

mapfile -t NSS_DIRS < <(collect_nss_dirs || true)

if [ ${#NSS_DIRS[@]} -eq 0 ]; then
    echo "No Chrome/Chromium or Firefox NSS databases found under $HOME"
    exit 0
fi

for dir in "${NSS_DIRS[@]}"; do
    import_cert "$dir" || true
done

echo "Browser trust update complete."
