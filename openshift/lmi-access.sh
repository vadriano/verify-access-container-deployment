#!/bin/bash
# Get docker container ID for iviaconfig container
ISVACONFIG="$(oc get --no-headers=true pods -l name=verifyaccess-config -o custom-columns=:metadata.name)"

echo "Setting up tunnel to LMI on iviaconfig pod."
echo "Access LMI at https://localhost:9443"
echo "Quit this process to close tunnel."
oc port-forward ${ISVACONFIG} 9443:9443
