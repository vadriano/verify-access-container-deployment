# Get docker container ID for iviaconfig container
ISVACONFIG="$(oc get --no-headers=true pods -l name=ivia-config -o custom-columns=:metadata.name)"

# Copy the current snapshots from iviaconfig container
SNAPSHOTS=`oc exec ${ISVACONFIG} ls /var/shared/snapshots`
for SNAPSHOT in $SNAPSHOTS; do
oc cp ${ISVACONFIG}:/var/shared/snapshots/$SNAPSHOT .
done

