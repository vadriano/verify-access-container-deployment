#!/bin/bash

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ] ; then
  echo "Failed to get local path"
  exit 1  # fail
fi

. ${RUNDIR}/../common/env-config.sh

if [ ! -f "$KEY_DIR/openldap/ldap.key" ] || [ ! -f "$KEY_DIR/openldap/ldap.crt" ] || [ ! -f "$KEY_DIR/openldap/ca.crt" ] || [ ! -f "$KEY_DIR/openldap/dhparam.pem" ] || [ ! -f "$KEY_DIR/postgresql/server.pem" ]
then
  echo "Key files not found.  Restore or create keys before running this script."
  exit 1
fi

# Create secret for TLS certificates used by this container
echo "Deleting openldap-keys Secret"
kubectl delete secret openldap-keys > /dev/null 2>&1
echo "Creating OpenLDAP SSL Keys as a Secret"
kubectl create secret generic "openldap-keys" --from-file "$KEY_DIR/openldap/ldap.crt" --from-file "$KEY_DIR/openldap/ldap.key" --from-file "$KEY_DIR/openldap/ca.crt" --from-file "$KEY_DIR/openldap/dhparam.pem"

echo "Deleting postgresql-keys Secret"
kubectl delete secret postgresql-keys > /dev/null 2>&1
echo "Creating server.pem as a Secret"
kubectl create secret generic postgresql-keys --from-file "$KEY_DIR/postgresql/server.pem"

echo "Deleting isvaadmin Secret"
kubectl delete secret isvaadmin > /dev/null 2>&1
echo "Creating isvaadmin Secret"
kubectl create secret generic isvaadmin
kubectl patch secret/isvaadmin -p '{"data":{"adminpw":"UGFzc3cwcmQ="}}'

echo "Deleting configreader Secret"
kubectl delete secret configreader > /dev/null 2>&1
echo "Creating configreader Secret"
kubectl create secret generic configreader
kubectl patch secret/configreader -p '{"data":{"cfgsvcpw":"UGFzc3cwcmQ="}}'
echo "Done."
