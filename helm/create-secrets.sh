#!/bin/bash

# Get directory for this script
RUNDIR="`dirname \"$0\"`"         # relative
RUNDIR="`( cd \"$RUNDIR\" && pwd )`"  # absolutized and normalized
if [ -z "$RUNDIR" ] ; then
  echo "Failed to get local path"
  exit 1  # fail
fi

. ${RUNDIR}/../common/env-config.sh

if [ ! -f "${DOCKERKEYS}/openldap/ldap.key" ] || [ ! -f "${DOCKERKEYS}/openldap/ldap.crt" ] || [ ! -f "${DOCKERKEYS}/openldap/ca.crt" ] || [ ! -f "${DOCKERKEYS}/openldap/dhparam.pem" ] || [ ! -f "${DOCKERKEYS}/postgresql/server.pem" ]
then
  echo "Key files not found.  Restore or create keys before running this script."
  exit 1
fi

# Create secret for TLS certificates used by this container
echo "Deleting openldap-keys Secret"
kubectl delete secret openldap-keys > /dev/null 2>&1
echo "Creating OpenLDAP SSL Keys as a Secret"
kubectl create secret generic "openldap-keys" --from-file "${DOCKERKEYS}/openldap/ldap.crt" --from-file "${DOCKERKEYS}/openldap/ldap.key" --from-file "${DOCKERKEYS}/openldap/ca.crt" --from-file "${DOCKERKEYS}/openldap/dhparam.pem"

echo "Deleting postgresql-keys Secret"
kubectl delete secret postgresql-keys > /dev/null 2>&1
echo "Creating server.pem as a Secret"
kubectl create secret generic postgresql-keys --from-file "${DOCKERKEYS}/postgresql/server.pem"

echo "Deleting helm-iviaadmin Secret"
kubectl delete secret helm-iviaadmin > /dev/null 2>&1
echo "Creating helm-iviaadmin Secret"
kubectl create secret generic helm-iviaadmin
kubectl patch secret/helm-iviaadmin -p '{"data":{"adminPassword":"UGFzc3cwcmQ="}}'
