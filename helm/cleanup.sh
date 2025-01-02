helm delete iamlab
kubectl delete pvc iamlab-pvc-cfg
kubectl delete pvc iamlab-pvc-db
kubectl delete pvc iamlab-pvc-ldp
kubectl delete secret helm-iviaadmin
kubectl delete secret dockerlogin
kubectl delete secret openldap-keys
kubectl delete secret postgresql-keys
kubectl delete ingress iamlab-iviawrp-rp1
kubectl delete ingress iamlab-iviaconfig
