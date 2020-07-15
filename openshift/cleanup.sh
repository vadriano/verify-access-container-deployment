oc delete all -l app=verifyaccess-core
oc delete all -l app=verifyaccess-rp1
oc delete all -l app=openldap
oc delete all -l app=postgresql
oc delete secret -l app=verifyaccess-core
oc delete secret -l app=openldap
oc delete secret -l app=postgresql
oc delete secret openldap-keys
oc delete secret postgresql-keys
oc delete pvc -l app=verifyaccess-core
oc delete pvc -l app=openldap
oc delete pvc -l app=postgresql

