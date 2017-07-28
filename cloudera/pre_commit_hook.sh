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

set -e

# set up thrift, protoc and Java
THRIFT_VERSION=0.9.3
wget "http://mirror.infra.cloudera.com/toolchain/thrift-${THRIFT_VERSION}.tar.gz" -O - | tar xz -C "$WORKSPACE"
cd "$WORKSPACE/thrift-${THRIFT_VERSION}"
./configure \
  --without-cpp \
  --without-libevent \
  --without-zlib \
  --without-qt4 \
  --without-qt5 \
  --without-c_glib \
  --without-csharp \
  --without-java \
  --without-erlang \
  --without-nodejs \
  --without-lua \
  --without-python \
  --without-perl \
  --without-php \
  --without-php_extension \
  --without-ruby \
  --without-haskell \
  --without-go \
  --without-haxe \
  --without-d
make
cd -
export JAVA_HOME="${JAVA8_HOME}"
export PATH="$JAVA_HOME/bin:$WORKSPACE/thrift-${THRIFT_VERSION}/compiler/cpp:/opt/toolchain/protobuf-2.5.0/bin:$PATH"

mvn clean test --fail-at-end
