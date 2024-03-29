#!/bin/sh

export WEBSERVER="intranet.mdb-lab.com"
export URL="https://"$WEBSERVER
export CERTROOT="rootCA.crt"
export CERTISSUING="issuingCA.crt"

cd /usr/local/share/ca-certificates/

# Download Root CA certificate
/usr/bin/curl -k -O "$URL/$CERTROOT"

# Download Issuing CA certificate
/usr/bin/curl -k -O "$URL/$CERTISSUING"

# Update the CA bundle
/usr/sbin/update-ca-certificates