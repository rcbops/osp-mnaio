#!/bin/bash

set -uvx -o pipefail

cd "${HOME}"

LOG_DIR="logs/overcloud"
if [ -d "${LOG_DIR}" ]; then
  TIME_STAMP=$(date -r "${LOG_DIR}" +%Y-%m-%d_%H:%M:%S%:z)
  mv "${LOG_DIR}" "${LOG_DIR}-${TIME_STAMP}"
fi

source stackrc

openstack server list \
  --format csv --column Name --column Networks --quote none \
| tail -n +2 \
| sed -e 's|,ctlplane=| |' \
| while read NAME IP; do
  # Execute body of while-loop within block and connect /dev/null to stdin so
  # it doesn't unintentionally consume the while-loop variables of server name
  # and IP.
  {
    LOG_DIR="logs/overcloud/${NAME}"
    mkdir -p "${LOG_DIR}"
    ssh heat-admin@${IP} \
      -o StrictHostKeyChecking=no \
      sudo tar -cz /var/log/{containers,swift}/ \
    | tar -xz -C "${LOG_DIR}"
  } </dev/null
done

# exit with success despite possible failures as this is best-effort
# TODO(coreywright): Exit with error if tar exits with 2, but not 1
exit 0
