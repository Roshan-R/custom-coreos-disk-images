#!/bin/bash
set -euo pipefail

ARCHES=(aarch64 ppc64le riscv64 s390x x86_64)
COSA_GIT_HASH='e7b71cf6be309dfe7ba92aef03a6870e09219010'
COSA_GIT_REPO_URL="https://raw.githubusercontent.com/coreos/coreos-assembler/${COSA_GIT_HASH}"
PLATFORM_FILENAMES=$(./custom-coreos-disk-images.sh --print-platform-manifest-filenames)
ARCH_MANIFESTS=$(for arch in ${ARCHES[@]}; do echo "coreos.osbuild.${arch}.mpp.yaml"; done)

get_url() {
    url=$1
    filename=$(basename "${url}")
    echo "Grabbing $url"
    echo "# Synced from ${url}" > "${filename}"
    curl -L --no-progress-meter --fail "${url}" >> "${filename}"
}

pushd cosa-imports
get_url "${COSA_GIT_REPO_URL}/src/runvm-osbuild"
chmod +x runvm-osbuild
for manifest in ${ARCH_MANIFESTS} ${PLATFORM_FILENAMES}; do
    get_url "${COSA_GIT_REPO_URL}/src/osbuild-manifests/${manifest}"
done
popd
