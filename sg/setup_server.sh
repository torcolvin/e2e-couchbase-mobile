#!/bin/bash

set -eux

CURL="curl -u Administrator:password --fail -L"
CURL_RETRY="$CURL --retry-all-errors --connect-timeout 5 --max-time 2 --retry 20 --retry-delay 0 --retry-max-time 120"

# Test to see if Couchbase Server is up
# Each retry min wait 5s, max 10s. Retry 20 times with exponential backoff (delay 0), fail at 120s
$CURL_RETRY ${SERVER_ADDR}

# Set up CBS

$CURL ${SERVER_ADDR}/nodes/self/controller/settings -d 'path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d 'index_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d '  cbas_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&' -d 'eventing_path=%2Fopt%2Fcouchbase%2Fvar%2Flib%2Fcouchbase%2Fdata&'
$CURL ${SERVER_ADDR}/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex'
$CURL ${SERVER_ADDR}/pools/default -d 'memoryQuota=3072' -d 'indexMemoryQuota=3072' -d 'ftsMemoryQuota=256'
$CURL ${SERVER_ADDR}/settings/web -d 'password=password&username=Administrator&port=SAME'
$CURL ${SERVER_ADDR}/settings/indexes -d indexerThreads=4 -d logLevel=verbose -d maxRollbackPoints=10 \
    -d storageMode=plasma -d memorySnapshotInterval=150 -d stableSnapshotInterval=40000

/sync_gateway /sync_gateway_config.json
