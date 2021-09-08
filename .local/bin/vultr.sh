#!/bin/sh
#
# vultr

# disable double quote warning
# shellcheck disable=2086

get_ids() { awk -F ',' '{ for (i = 1; i <= NF; i++) if ($i ~ /"id"/) print $i }' | awk -F ':' '{ for (i = 1; i <= NF; i++) if ($i ~ /-/) print $i }' | tr -d \" ; }

# DO NOT SHARE THIS
VULTR_API_KEY='RETRACTED'

INSTANCE='mcarlson.xyz'

INSTANCE_ID="$(curl 'https://api.vultr.com/v2/instances'    \
                -X GET                                      \
                -H "Authorization: Bearer ${VULTR_API_KEY}" \
                | get_ids)"

snapshot_ids="$(curl 'https://api.vultr.com/v2/snapshots'   \
                -X GET                                      \
                -H "Authorization: Bearer ${VULTR_API_KEY}" \
                | get_ids)"

# Get oldest snapshot ID -- will be first in list
set -- ${snapshot_ids}
oldest_snapshot_id="${1}"

# Vultr only allows eleven(?) snapshots at this moment
SNAPSHOT_LIMIT=11
snapshot_count=$(printf '%s\n' "${snapshot_ids}" | wc -w)

# Delete oldest snapshot if limit if reached
if [ "${snapshot_count}" -eq "${SNAPSHOT_LIMIT}" ]; then
    curl "https://api.vultr.com/v2/snapshots/${oldest_snapshot_id}" -X DELETE -H "Authorization: Bearer ${VULTR_API_KEY}" || exit 1;
fi

# Create new snapshot for instance
curl 'https://api.vultr.com/v2/snapshots'         \
    -X POST                                       \
    -H "Authorization: Bearer ${VULTR_API_KEY}"   \
    -H 'Content-Type: application/json'           \
    --data '{
        "instance_id":"'${INSTANCE_ID}'",
        "description":"Snapshot of '${INSTANCE}'"
    }'
