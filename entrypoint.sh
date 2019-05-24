#!/bin/bash

export APPLICATION_SECRET="${APPLICATION_SECRET:-$(date +%s | sha256sum | base64 | head -c 64 ; echo)}"
export HTTP_CONTEXT="${HTTP_CONTEXT:-/}"
export ZK_HOSTS="${ZK_HOSTS:-zookeeper:2181}"
export BASE_ZK_PATH="${BASE_ZK_PATH:-/kafka-manager}"
export KAFKA_MANAGER_LOGLEVEL="${KAFKA_MANAGER_LOGLEVEL:-INFO}"
export LOGGER_STARTUP_TIMEOUT="${LOGGER_STARTUP_TIMEOUT:-60s}"
export TRUST_STORE_PATH="${MESOS_SANDBOX}/${TRUST_STORE_PATH}"
export KEY_STORE_PATH="${MESOS_SANDBOX}/${KEY_STORE_PATH}"
export TRUST_STORE_PASSWORD="${MESOS_SANDBOX}/${TRUST_STORE_PASSWORD}"
export KEY_STORE_PASSWORD="${MESOS_SANDBOX}/${KEY_STORE_PASSWORD}"
KAFKA_MANAGER_CONFIG="${KAFKA_MANAGER_CONFIG:-./conf/application.conf}"
HTTP_PORT="${HTTP_PORT:-9000}"

export SECURE_JMX_TRUST_STORE_PASSWORD_ENV=`cat $TRUST_STORE_PASSWORD`
export SECURE_JMX_KEY_STORE_PASSWORD_ENV=`cat $KEY_STORE_PASSWORD`
export LIBPROCESS_SSL_REQUIRE_CERT=1

if [ -z "$KAFKA_MANAGER_JMX_OPTS" ]; then
  KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false "
fi


exec /app/bin/kafka-manager -Djavax.net.ssl.trustStorePassword=${SECURE_JMX_TRUST_STORE_PASSWORD_ENV} \
							-Djdk.tls.client.protocols=TLSv1.2 \
							-Djavax.net.ssl.keyStorePassword=${SECURE_JMX_KEY_STORE_PASSWORD_ENV} \
							-Djavax.net.ssl.trustStoreType=JKS \
							-Djavax.net.ssl.keyStoreType=JKS \
							-Djavax.net.ssl.trustStore=${TRUST_STORE_PATH} \
							-Djavax.net.ssl.keyStore=${KEY_STORE_PATH} \
							-Dconfig.file=${KAFKA_MANAGER_CONFIG} -Dhttp.port=${HTTP_PORT} "${KAFKA_MANAGER_ARGS}" "${@}"
