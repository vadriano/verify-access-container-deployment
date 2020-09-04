#!/bin/bash

# Set file locations
KEYS=${HOME}/dockerkeys

# Create a temporary working directory
TMPDIR=/tmp/backup-$RANDOM$RANDOM
mkdir $TMPDIR

# Get docker container ID for isvaconfig container
ISVACONFIG="$(oc get --no-headers=true pods -l name=verifyaccess-config -o custom-columns=:metadata.name)"

# Copy the current snapshots from isvaconfig container
SNAPSHOTS=`oc exec ${ISVACONFIG} ls /var/shared/snapshots`
for SNAPSHOT in $SNAPSHOTS; do
oc cp ${ISVACONFIG}:/var/shared/snapshots/$SNAPSHOT $TMPDIR/$SNAPSHOT
done

# Get docker container ID for openldap container
OPENLDAP="$(oc get --no-headers=true pods -l app=openldap -o custom-columns=:metadata.name)"

# Extract LDAP Data from OpenLDAP
oc exec ${OPENLDAP} -- ldapsearch -H "ldaps://localhost:636" -L -D "cn=root,secAuthority=Default" -w "Passw0rd" -b "secAuthority=Default" -s sub "(objectclass=*)" > $TMPDIR/secauthority.ldif
oc exec ${OPENLDAP} -- ldapsearch -H "ldaps://localhost:636" -L -D "cn=root,secAuthority=Default" -w "Passw0rd" -b "dc=ibm,dc=com" -s sub "(objectclass=*)" > $TMPDIR/ibmcom.ldif

# Get docker container ID for postgresql container
POSTGRESQL="$(oc get --no-headers=true pods -l app=postgresql -o custom-columns=:metadata.name)"
oc exec ${POSTGRESQL} -- /usr/local/bin/pg_dump isva > $TMPDIR/isva.db

cp -R ${KEYS} ${TMPDIR}

tar -cf isva-backup-$RANDOM.tar -C ${TMPDIR} .
rm -rf ${TMPDIR}
echo Done.
