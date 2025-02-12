#!/bin/bash
set -euo pipefail

curl -X PUT -u icopensearch:${os_ic_password} ${host}/_plugins/_security/api/internalusers/openmetadata -H 'Content-Type: application/json' -d"
{
    \"password\": \"${os_om_password}\",
    \"backend_roles\": [],
    \"attributes\": {}
}"
curl -X PUT -u icopensearch:${os_ic_password} ${host}/_plugins/_security/api/rolesmapping/all_access -H 'Content-Type: application/json' -d'
{
    "users" : [ "openmetadata" ]
}'
