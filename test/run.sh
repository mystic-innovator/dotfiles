#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="dotfiles-integration-test"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

docker build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Dockerfile" "${REPO_DIR}"

echo "Build complete. Run 'docker run -it --rm ${IMAGE_NAME}' to open a shell with the configured dotfiles."
