echo "Creating Service Accounts"
oc create serviceaccount verifyaccess
oc create serviceaccount openldap

echo "Creating isva Security Context Constraint"
oc create -f isva-security-constraint.yaml

echo "Adding service accounts to Security Constraints"
oc adm policy add-scc-to-user verifyaccess -z verifyaccess
oc adm policy add-scc-to-user anyuid -z openldap
echo "Done."
