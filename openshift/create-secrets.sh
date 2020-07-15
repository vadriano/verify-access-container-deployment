#!/bin/bash

ADMINPW="Passw0rd"
CFGSVCPW="Passw0rd"

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
oc delete secret openldap-keys > /dev/null 2>&1
echo "Creating OpenLDAP SSL Keys as a Secret"
oc create secret generic "openldap-keys" --from-file "${DOCKERKEYS}/openldap/ldap.crt" --from-file "${DOCKERKEYS}/openldap/ldap.key" --from-file "${DOCKERKEYS}/openldap/ca.crt" --from-file "${DOCKERKEYS}/openldap/dhparam.pem"

echo "Deleting postgresql-keys Secret"
oc delete secret postgresql-keys > /dev/null 2>&1
echo "Creating server.pem as a Secret"
oc create secret generic postgresql-keys --from-file "${DOCKERKEYS}/postgresql/server.pem"

echo "Done."
