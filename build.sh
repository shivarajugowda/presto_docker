#!/usr/bin/env bash

set -euxo pipefail

# Retrieve the script directory.
SCRIPT_DIR="${BASH_SOURCE%/*}"
cd ${SCRIPT_DIR}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 PRESTO_VERSION"
    echo "Missing PRESTO_VERSION"
    exit 1
fi

PRESTO_VERSION=$1
#DOCKER_TAG="${DOCKER_ID_USER}/prestosql:latest"
DOCKER_TAG="${DOCKER_ID_USER}/prestosql:jdk11"
PRESTO_LOCATION="https://repo1.maven.org/maven2/io/prestosql/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz"
CLIENT_LOCATION="https://repo1.maven.org/maven2/io/prestosql/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar"

WORK_DIR="$(mktemp -d)"
curl -o ${WORK_DIR}/presto-server-${PRESTO_VERSION}.tar.gz ${PRESTO_LOCATION}
tar -C ${WORK_DIR} -xzf ${WORK_DIR}/presto-server-${PRESTO_VERSION}.tar.gz
rm ${WORK_DIR}/presto-server-${PRESTO_VERSION}.tar.gz

# Remove large plugins, we won't use.
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/phoenix
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/hive-hadoop2
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/raptor
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/accumulo
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/kafka
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/redis
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/mongodb
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/presto-elasticsearch
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/ml
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/cassandra
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/sqlserver
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/kudu
rm -rf ${WORK_DIR}/presto-server-${PRESTO_VERSION}/plugin/geospatial

cp -R bin ${WORK_DIR}/presto-server-${PRESTO_VERSION}
cp -R default/etc ${WORK_DIR}/presto-server-${PRESTO_VERSION}

curl -o ${WORK_DIR}/presto-cli-${PRESTO_VERSION}-executable.jar ${CLIENT_LOCATION}
chmod +x ${WORK_DIR}/presto-cli-${PRESTO_VERSION}-executable.jar

docker build ${WORK_DIR} -f Dockerfile -t "${DOCKER_TAG}" --build-arg "PRESTO_VERSION=${PRESTO_VERSION}"

rm -r ${WORK_DIR}

# Source common testing functions
. container-test.sh

test_container "${DOCKER_TAG}"

docker login -u ${DOCKER_ID_USER} -p ${DOCKER_ACCESS_TOKEN}
docker push "${DOCKER_TAG}"
