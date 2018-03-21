#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

. /opt/toolchain/toolchain.sh
export THRIFT_VERSION="0.9.3"
export THRIFT_HOME="/opt/toolchain/thrift-${THRIFT_VERSION}"
export PROTOC_HOME="/opt/toolchain/protobuf-2.5.0"
export PATH="${THRIFT_HOME}/bin:${PROTOC_HOME}/bin:$PATH"

if [[ ! -d "$THRIFT_HOME" ]]; then
    echo "THRIFT HOME ($THRIFT_HOME) does not exist!"
    exit 1
fi

if [[ ! -d "$PROTOC_HOME" ]]; then
    echo "PROTOC HOME ($PROTOC_HOME) does not exist!"
    exit 1
fi

# we need to re-run setup inside the docker container to get mvn-gbn script.
SETUP_FILE="$(mktemp)"
function cleanup_setup_file {
    rm -rf "$SETUP_FILE"
}
trap cleanup_setup_file EXIT

curl http://github.mtv.cloudera.com/raw/cdh/cdh/cdh6.x/tools/gerrit-unittest-setup.sh -o "$SETUP_FILE"
source "$SETUP_FILE"

# mvn-gbn should now be on our path
mvn-gbn clean test --fail-at-end
