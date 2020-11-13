# What's new in verify-access v1.2.1 Chart
The following enhancements have been made:
* Ability to set timezone for containers
* Ability to set port for NodePorts
* Change to preferred antiAffinity to allow for in-place upgrade
* Mark PVCs as "keep" so not deleted with release
* Change to Reverse Proxy definition to allow per-instance settings

# Values migration
In previous versions the Reverse Proxy instances were defined with an array containing a list of instance names. e.g.
```
- rp1
- rp2
```

In this version, the array must now contain a list of instances with attributes defined for each instance.  The `name` attribute is required.  Other optional attributes are `nodePort` and `replicas` e.g.
```
- name: rp1
- name: rp2
  replicas: 2
  nodePort: 30443
```

# Documentation
For detailed documentation instructions go to [https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html](https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html).


# Version History

| Chart | Date | Kubernetes Required | Image(s) Supported | Breaking Changes | Details
| ----- | ---- | ------------------- | ------------------ | ---------------- | -------
| 1.2.0 | July 2020  | >= 1.11.x | ibmcom/verify-access:10.0.0.0; ibmcom/verify-access-postgresql:10.0.0.0; ibmcom/verify-access-openldap:10.0.0.0 | Verify Access | Based on ISAM v1.2.0 charts
| 1.2.1 | Nov 2020  | >= 1.11.x | ibmcom/verify-access:10.0.0.0; ibmcom/verify-access-postgresql:10.0.0.0; ibmcom/verify-access-openldap:10.0.0.0 | Verify Access | Add timezone support
