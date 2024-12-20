#!/bin/bash

# variables
base="vault-tls-cert"
root="rootCA"

# create root key and certificate
echo -e "\n\nGenerate root CA\n\n";
openssl genrsa -out "${root}.key" 4096
openssl req -x509 -nodes -sha256 -new -key "${root}.key" -out "${root}.crt" -days 3650 \
  -subj "/C=FR/ST=HDF/O=Dysnomia/CN=Vault CA" #\

# create our key and certificate signing request
echo -e "\n\nGenerate cert\n\n"
openssl req -out "${base}.csr" -newkey rsa:2048 -nodes -keyout "${base}.key" -config san.cnf

# create our final certificate and sign it
echo -e "\n\nFinal cert and sign\n\n"
openssl x509 -req -sha256 -in "${base}.csr" -out "${base}.crt" -days 3650 \
  -CAkey "${root}.key" -CA "${root}.crt" -CAcreateserial \
  -extensions v3_req -extfile san2.cnf

# review files
echo "--"; openssl x509 -in "${root}.crt" -noout -text
echo "--"; openssl req  -in "${base}.csr" -noout -text
echo "--"; openssl x509 -in "${base}.crt" -noout -text
echo "--";