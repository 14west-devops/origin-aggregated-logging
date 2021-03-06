#!/bin/bash
#
# Copyright 2017 Red Hat, Inc. and/or its affiliates
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

export NSS_SDB_USE_CACHE=no

# TODO: try re-use code from ./run.sh
ES_REST_BASEURL=https://localhost:9200
EXPECTED_RESPONSE_CODE=200
secret_dir=${ES_PATH_CONF}/secret
max_time=${READINESS_PROBE_TIMEOUT:-30}

function check_if_ready() {
  path="$1"
  err_msg="$2"
  response_code=$(curl -s --head \
      --cacert $secret_dir/admin-ca \
      --cert $secret_dir/admin-cert \
      --key  $secret_dir/admin-key \
      --max-time $max_time \
      -o /dev/null \
      -w '%{response_code}' \
      "${ES_REST_BASEURL}${path}")

  if [ "${response_code}" != ${EXPECTED_RESPONSE_CODE} ]; then
    echo "${err_msg} [response code: ${response_code}]"
    exit 1
  fi
}

function check_for_init_running() {
  test -f ${HOME}/init_running
}

function check_for_init_complete() {
  test -f ${HOME}/init_complete
}

function show_failures() {
  if [ -f ${HOME}/init_failures ]; then
    cat ${HOME}/init_failures
  else
    # this should never happen"
    echo "Elasticsearch node is in unknown state"
  fi
}

check_if_ready "/" "Elasticsearch node is not ready to accept HTTP requests yet"
check_for_init_complete || ( check_for_init_running && echo "Elasticsearch node is initializing" ) || show_failures
