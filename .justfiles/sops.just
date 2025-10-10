# SOPS secrets management commands

# Update all sops secrets
sops-update:
    #!/usr/bin/env bash
    set -euo pipefail
    SECRET_FILES=$(find . -type f -name '*.sops.yaml' ! -name ".sops.yaml")
    for file in $SECRET_FILES; do
        echo "Updating $file"
        sops updatekeys "$file"
    done
