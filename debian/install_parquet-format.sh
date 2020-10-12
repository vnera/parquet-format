#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to parquet-format tarball with binaries
     --prefix=PREFIX             path to install into

  Optional options:
     --lib-dir=DIR               path to install parquet-format jar files
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'lib-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

LIB_DIR=${LIB_DIR:-/usr/lib/parquet}
HADOOP_HOME=${HADOOP_HOME:-/usr/lib/hadoop}
RELATIVE_PATH='../parquet' # LIB_DIR relative to HADOOP_HOME

# First we'll move everything into lib
install -d -m 0755 $PREFIX/$LIB_DIR/lib
install -d -m 0755 $PREFIX/$HADOOP_HOME
versions='s#-[0-9.]\+-cdh[0-9\-\.]*[0-9x]\(-\(alpha\|beta\|patch\)-\?[0-9]\+\)\?\(-SNAPSHOT\)\?##'
for jar in `find $BUILD_DIR -name *.jar | grep -v '\-tests.jar' | grep -v '\/original-parquet'`; do
    cp $jar $PREFIX/$LIB_DIR/lib
    versionless=`echo \`basename ${jar}\` | sed -e ${versions}`
    ln -fs lib/`basename ${jar}` ${PREFIX}/${LIB_DIR}/${versionless}
    ln -fs ${RELATIVE_PATH}/${versionless} $PREFIX/$HADOOP_HOME/
done

# Cloudera specific
install -d -m 0755 $PREFIX/$LIB_DIR/parquet-format/cloudera
cp cloudera/cdh_version.properties $PREFIX/$LIB_DIR/parquet-format/cloudera/

