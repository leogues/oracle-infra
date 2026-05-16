#!/bin/bash

set -euo pipefail

export SOPS_AGE_KEY_FILE="keys/age.key"

for file in namespaces/*/*.enc.json; do
  if [[ -f "$file" ]]; then
    out="${file%.enc.json}.dec.json"
    sops --decrypt "$file" > "$out"
    echo "Decrypted $file → $out"

    rm -f "$file"
  fi
done
