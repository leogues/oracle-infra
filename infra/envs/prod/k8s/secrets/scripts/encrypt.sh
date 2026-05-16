#!/bin/bash

set -euo pipefail

for file in namespaces/*/*.dec.json; do
  if [[ -f "$file" ]]; then
    echo "Encrypting $file"

    sops --encrypt "$file" > "${file%.dec.json}.enc.json"

    echo "Encrypted $file → ${file%.dec.json}.enc.json"

    rm -f "$file"
  fi
done
