#!/bin/bash
# Get docker container ID for isvaconfig container
ISVACONFIG="$(kubectl get --no-headers=true pods -l app=isvaconfig -o custom-columns=:metadata.name)"

echo "Setting up tunnel to LMI on isvaconfig pod."
echo "Access LMI at https://localhost:9443"
echo "Quit this process to close tunnel."
kubectl port-forward ${ISVACONFIG} 9443
