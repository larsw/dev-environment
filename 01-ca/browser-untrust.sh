#!/bin/bash

# Remove the local step-ca root certificate from browser NSS stores

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CERT_NAME="Kub Domain CA"

if ! command -v certutil >/dev/null 2>&1; then
    echo "certutil not found. Install libnss3-tools (e.g. sudo apt install libnss3-tools)." >&2
    exit 1
fi

collect_nss_dirs() {
    local results=()
    local search_roots=("$HOME/.pki/nssdb" "$HOME/.config/google-chrome" "$HOME/.config/chromium" "$HOME/.mozilla/firefox")

    for root in "${search_roots[@]}"; do
        if [ -d "$root" ]; then
            while IFS= read -r db_file; do
                results+=("$(dirname "$db_file")")
            done < <(find "$root" -maxdepth 4 -type f -name "cert9.db" -print 2>/dev/null)
        fi
    done

    if [ ${#results[@]} -gt 0 ]; then
        printf '%s\n' "${results[@]}" | sort -u
    fi
}

remove_cert() {
    local dir="$1"
    if certutil -D -n "$CERT_NAME" -d "sql:$dir" >/dev/null 2>&1; then
        echo "Removed $CERT_NAME from $dir"
    else
        echo "$CERT_NAME not present in $dir"
    fi
}

mapfile -t NSS_DIRS < <(collect_nss_dirs || true)

if [ ${#NSS_DIRS[@]} -eq 0 ]; then
    echo "No Chrome/Chromium or Firefox NSS databases found under $HOME"
    exit 0
fi

for dir in "${NSS_DIRS[@]}"; do
    remove_cert "$dir"
done

echo "Browser trust removal complete."
