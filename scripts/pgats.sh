#!/usr/bin/env bash -e

TOPLEVEL=$(git rev-parse --show-toplevel)
WORKSPACE="${TOPLEVEL}/workspace"

source "${TOPLEVEL}/scripts/bosh-env.sh"
export PGATS_CONFIG="${WORKSPACE}/pgats.yml"

function ca_cert {
    bosh int "$(git rev-parse --show-toplevel)/workspace/creds.yml" --path /director_ssl/ca
}

shopt -s lastpipe
if ! netstat -nrf inet | grep -q 10.244; then
    echo "No route entries found for 10.244/16 subnet"
    exit 1
fi

bosh int /dev/stdin -v target="${BOSH_ENVIRONMENT}" -v username="${BOSH_CLIENT}" -v password="${BOSH_CLIENT_SECRET}" \
         -v versions="${TOPLEVEL}/src/github.com/cloudfoundry/postgres-release/versions.yml" \
         --var-file ca_cert=<(ca_cert) <<EOF > "${PGATS_CONFIG}"
---
bosh:
  target: ((target))
  username: ((username))
  password: ((password))
  director_ca_cert: ((ca_cert))
cloud_configs:
  default_azs: [z1]
  default_networks:
  - name: default
  default_persistent_disk_type: default
  default_vm_type: default
versions_file: ((versions))
EOF

"${TOPLEVEL}/src/github.com/cloudfoundry/postgres-release/src/acceptance-tests/scripts/test" "$@"
