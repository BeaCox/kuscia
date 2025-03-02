#!/bin/bash
# Copyright 2023 Ant Group Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SERVICE_NAME=$1
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
IP=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
pushd ${ROOT}/etc/certs || exit

DAYS=1000
SERVER=kusciaapi-server
CLIENT=kusciaapi-client
DNS_SERVICE_NAME=""
if [ ${SERVICE_NAME} != "" ] ; then
    DNS_SERVICE_NAME=",DNS:${SERVICE_NAME}"
fi
subjectAltName="IP:127.0.0.1,IP:${IP},DNS:localhost${DNS_SERVICE_NAME}"
echo "subjectAltName=${subjectAltName}" > /tmp/openssh.conf

#create a PKCS#1 key for server, default is PKCS#1
openssl genrsa -out ${SERVER}.key 2048

#generate the Certificate Signing Request
openssl req -new -key ${SERVER}.key -days ${DAYS} -out ${SERVER}.csr \
    -subj "/CN=KusciaAPI"

#sign it with Root CA
openssl x509  -req -in ${SERVER}.csr \
    -extfile /tmp/openssh.conf \
    -CA ca.crt -CAkey ca.key  \
    -days ${DAYS} -sha256 -CAcreateserial \
    -out ${SERVER}.crt

rm -rf /tmp/openssh.conf

#create a PKCS#8 key for client(JAVA native supported), default is PKCS#1
openssl genpkey -out ${CLIENT}.key -algorithm RSA -pkeyopt rsa_keygen_bits:2048

#generate the Certificate Signing Request for client
openssl req -new -key ${CLIENT}.key -days ${DAYS} -out ${CLIENT}.csr \
    -subj "/CN=KusciaAPIClient"

#sign it with Root CA for client
openssl x509  -req -in ${CLIENT}.csr \
    -CA ca.crt -CAkey ca.key  \
    -days 1000 -sha256 -CAcreateserial \
    -out ${CLIENT}.crt

#generate token file
if [ ! -e token ]; then # token not exists
  openssl rand -base64 8 |xargs echo -n > /tmp/token
  sha256sum /tmp/token | cut -d' ' -f1 |xargs echo -n > token
  rm -rf /tmp/token
fi

popd || exit
