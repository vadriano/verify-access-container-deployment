echo "Deleting Service Accounts"
oc delete serviceaccount verifyaccess
oc delete serviceaccount openldap

echo "Deleting Security Context Constraint"
oc delete -f isva-security-constraint.yaml

echo "Done."
