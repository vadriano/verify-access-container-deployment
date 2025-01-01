# IBM Verify Identity Access

## Introduction

In a world of highly fragmented access management environments, IBM Verify Identity Access helps you simplify your users' access while more securely adopting web, mobile and cloud technologies. This solution helps you strike a balance between usability and security through the use of risk-based access, single sign-on, integrated access management control, identity federation and its mobile multi-factor authentication capability. Take back control of your access management with IBM Verify Identity Access.


## Chart Details

This chart will deploy an IBM Verify Identity Access environment.  This environment will consist of a number of different containers, namely:

| Container  | Purpose
| ---------  | -------------------
| iviaconfig | This container provides the Web console which can be used to configure the environment.
| iviawrp    | This container provides a secure Web Reverse Proxy.  This should serve as the network entry point into the environment.
| iviart     | This container provides the runtime services of the Advanced Access Control and Federation offerings.  This is an optional part of the environment and is only required if AAC or Federation capabilities are required.
| iviadsc    | This container provides the distributed session cache server.  It is an optional component and is only required if user sessions need to be shared across multiple containers.
| iviapostgresql | This container provides a sample database which can be used by IBM Verify Identity Access.  It is not designed to be used in production and should only ever be used in development or proof of concept environments.
| iviaopenldap | This container provides a sample LDAP directory which can be used by IBM Verify Identity Access.  It is not designed to be used in production and should only ever be used in development or proof of concept environments.

The chart makes use of the verify identity access docker images, which are available on Verify Docs: 
* [icr.io/ivia/verify-identiy-access](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#configuration-container)
* [icr.io/ivia/ivia-wrp](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#web-reverse-proxy)
* [icr.io/ivia/ivia-runtime](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#aac-and-federation-runtime)
* [icr.io/ivia/ivia-dsc](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#distributed-session-cache)
* [icr.io/ivia/ivia-openldap](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#distributed-session-cache)
* [icr.io/ivia/ivia-postgresql](https://docs.verify.ibm.com/ibm-security-verify-access/docs/containers#postgresql)

## Prerequisites

### Administrator Password
The administrator password will reside within a Kubernetes secret, with a secret key of 'adminPassword'.  If no secret is supplied to the chart via the global.container.imageSecret configuration parameter a new secret will be automatically generated which contains a randomly generated password.

The simplest way to create the secret is to use the kubectl command:

```
kubectl create secret generic <secret-name> --from-literal=adminPassword=<password>
```

### PersistentVolumeClaim Requirements

A Persistent Volume Claim is required if persistence is enabled and no dynamic provisioning has been set up. You can create a persistent volume claim through a yaml file. For example:

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <persistent volume claim name>
spec:
  storageClassName: <storage class name>
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```



To create the persistent volume claim using a file called `pvc.yaml`:

```bash
$ kubectl create -f pvc.yaml
```

### PodSecurityPolicy Requirements

This chart requires a PodSecurityPolicy to be bound to the target namespace prior to installation.  Choose either a predefined PodSecurityPolicy or have your cluster administrator setup a custom PodSecurityPolicy for you:

* Predefined PodSecurityPolicy name: [`ibm-anyuid-psp`](https://ibm.biz/cpkspec-psp)
* Custom PodSecurityPolicy definition:

```
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
  annotations:
    kubernetes.io/description: "This policy allows pods to run with
      any UID and GID, but preventing access to the host."
  name: verify-identity-access-nonroot-psp
spec:
  allowPrivilegeEscalation: true
  fsGroup:
    rule: RunAsAny
  requiredDropCapabilities:
  - ALL
  allowedCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - FOWNER
  - KILL
  - NET_BIND_SERVICE
  - SETFCAP
  - SETGID
  - SETUID
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  volumes:
  - configMap
  - emptyDir
  - projected
  - secret
  - downwardAPI
  - persistentVolumeClaim
  forbiddenSysctls:
  - '*'
```

To create a security policy using a file called `sec_policy.yaml`:

```bash
$ kubectl create -f sec_policy.yaml
```

* Custom ClusterRole for the custom PodSecurityPolicy:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
  name: verify-identity-access-nonroot-clusterrole
rules:
- apiGroups:
  - extensions
  resourceNames:
  - verify-identity-access-nonroot-psp
  resources:
  - podsecuritypolicies
  verbs:
  - use
```

To create a cluster role using a file called `cluster_role.yaml`:

```bash
$ kubectl create -f cluster_role.yaml
```

* Custom ClusterRoleBinding for the custom ClusterRole:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: verify-identity-access-nonroot-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: verify-identity-access-nonroot-clusterrole
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: system:serviceaccounts:{{ NAMESPACE }}
```

The '{{ NAMESPACE }}' string in the cluster role should be replaced with the namespace of the target environment.

To create a cluster role binding using a file called `cluster_role_binding.yaml`:

```bash
$ kubectl create -f cluster_role_binding.yaml
```

## Resources Required

The minimum resources required for each of the container types are:

|Container       | Minimum Memory | Minimum CPU
|---------       | -------------- | -----------
| iviaconfig     | 1Gi            | 1000m
| iviawrp        | 512Mi          | 500m
| iviart         | 1Gi            | 1000m
| iviadsc        | 512Mi          | 500m
| iviapostgresql | 512Mi          | 500m
| iviaopenldap   | 512Mi          | 500m

The 1Gi and 1000m minimum values can be reduced to allow installation to a minimal development or test environment.

## Installing the Chart (Helm 2)

To install the chart with the release name `my-release`:

```bash
$ helm install --tls --name my-release verify-identity-access
```

This command deploys the Verify Identity Access image on the Kubernetes cluster using the default configuration. The configuration section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list --tls`

## Installing the Chart (Helm 3)

To install the chart with the release name `my-release`:

```bash
$ helm install my-release verify-identity-access
```

This command deploys the Verify Identity Access image on the Kubernetes cluster using the default configuration. The configuration section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Verifying the Chart (Helm 3)

See the instruction after the helm installation completes for chart verification. The instruction can also be displayed by viewing the installed helm release under Menu -> Workloads -> Helm Releases or by running the command: `helm status <release>`.

## Uninstalling the Chart (Helm 3)

To uninstall/delete the `my-release` deployment:

```bash
$ helm delete my-release
```

The command removes all of the Kubernetes components associated with the chart and deletes the release.

When deleting a release with stateful sets the associated persistent volume will need to be deleted.  Execute the following command after deleting the chart release to clean up orphaned Persistent Volumes.

```console
$ kubectl delete pvc -l release=my-release
```

## Configuration
The following tables list the configurable parameters of the Verify Identity Access chart, along with their default values.

### Global

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `global.image.configrepository` | The config container image repository. | `icr.io/ivia/ivia:11.0.0.0` |
| `global.image.wrprepository` | The web reverse proxy image repository. | `icr.io/ivia/ivia-wrp:11.0.0.0` |
| `global.image.runtimerepository` | The runtime repository. | `icr.io/ivia/ivia-runtime:11.0.0.0` |
| `global.image.dscrepository` | The dsc repository. | `icr.io/ivia/ivia-dsc:11.0.0.0` |
| `global.image.dbrepository` | The image repository for the postgresql server. | `icr.io/ivia/ivia-postgresql:11.0.0.0` |
| `global.image.ldaprepository` | The image repository for the openldap server. | `icr.io/isva/verify-access-openldap:10.0.6.0` |
| `global.image.pullPolicy` | The image pull policy. | `IfNotPresent` |
| `global.imageCredentials.dockerSecret` | The name of an existing secret which contains the Docker Store credentials. | (none) |
| `global.container.snapshot` | The name of the configuration data snapshot that is to be used when starting the container. This will default to the latest published configuration.| latest published snapshot
| `global.container.fixpacks` | A space-separated, ordered list of fix packs to be applied when starting the container. If this environment variable is not present, any fix packs present in the fixpacks directory of the configuration volume will be applied in alphanumeric order. | all available fix packs
| `global.container.adminSecret` | The name of an existing secret which contains the administrator password (key: adminPassword). If no secret is supplied a new secret will be created with a randomly generated password.| (none) |
| `global.container.timezone` | The timezone that will be used when writing log messages.  If not set, timezone is set by host environment | Etc/UTC
| `global.persistence.enabled` | Whether to use a PVC to persist data. | `true` |
| `global.persistence.useDynamicProvisioning` | Whether the requested volume will be automatically provisioned if dynamic provisioning is available. | `true` |
| `global.configservicename` | Set a specific service name for the config service.  | `<release>-iviaconfig` |

### Configuration Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviaconfig.resources.requests.memory` | The amount of memory to be allocated to the configuration service. | `1Gi` |
| `iviaconfig.resources.requests.cpu` | The amount of CPU to be allocated to the configuration service. | `1000m` |
| `iviaconfig.resources.limits.memory` | The maximum amount of memory to be used by the configuration service. | `2Gi` |
| `iviaconfig.resources.limits.cpu` | The maximum amount of CPU to be used by the configuration service. | `2000m` |
| `iviaconfig.service.type` | The service type for the configuration service. | `NodePort` |
| `iviaconfig.service.nodePort` | The nodePort to use for the configuration service (when service type is NodePort). | empty |
| `iviaconfig.dataVolume.existingClaimName` | The name of an existing PersistentVolumeClaim to be used.| empty |
| `iviaconfig.dataVolume.storageClassName` | The storage class of the backing PVC. | empty |
| `iviaconfig.dataVolume.size` | The size of the data volume. | `20Gi` |

### Web Reverse Proxy Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviawrp.container.instances` | An array of instances to be created. | See Below |
| `iviawrp.container.instances.name` | The name of the instance | `default` |
| `iviawrp.container.instances.servicename` | Service name of the instance | `<release>wrp-<instance>` |
| `iviawrp.container.instances.servicetype` | ClusterIP or NodePort | `ClusterIP` |
| `iviawrp.container.instances.nodePort` | The nodePort (if service type is NodePort). | empty |
| `iviawrp.container.instances.replicas` | The number of replicas to start for the instance. | `1` |
| `iviawrp.resources.requests.memory` | The amount of memory to be allocated to each Web Reverse Proxy instance. | `512Mi` |
| `iviawrp.resources.requests.cpu` | The amount of CPU to be allocated to each replica of each Web Reverse Proxy instance. | `500m` |
| `iviawrp.resources.limits.memory` | The maximum amount of memory to be used by each replica of each Web Reverse Proxy instance. | `1Gi` |
| `iviawrp.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of each Web Reverse Proxy instance. | `1000m` |

### Runtime Service

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviaruntime.container.enabled` | Whether the federation and advanced access control runtime is required. | `false`
| `iviaruntime.container.replicas` | The number of replicas to start of the runtime service. | `1` |
| `iviaruntime.resources.requests.memory` | The amount of memory to be allocated to the runtime service. | `1Gi` |
| `iviaruntime.resources.requests.cpu` | The amount of CPU to be allocated to each replica of the runtime service. | `1000m` |
| `iviaruntime.resources.limits.memory` | The maximum amount of memory to be used by each replica of the runtime service. | `2Gi` |
| `iviaruntime.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of the runtime service. | `2000m` |
| `iviaruntime.service.servicename` | Service name for the runtime | `<release>-iviaruntime` |

### Distributed Session Cache

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviadsc.container.enabled` | Whether the distributed session cache service is required. | `false` |
| `iviadsc.container.useReplica` | Whether the distributed session cache service should be replicated for HA. | `true` |
| `iviadsc.resources.requests.memory` | The amount of memory to be allocated to the distributed session cache service. | `512Mi` |
| `iviadsc.resources.requests.cpu` | The amount of CPU to be allocated to each replica of the distributed session cache service. | `500m` |
| `iviadsc.resources.limits.memory` | The maximum amount of memory to be used by each replica of the distributed session cache service. | `1Gi` |
| `iviadsc.resources.limits.cpu` | The maximum amount of CPU to be used by each replica of the distributed session cache service. | `1000m` |
| `iviadsc.service.servicename` | Service name for the DSC. Replica has 2 appended | `<release>-iviadsc-<primary|secondary>` |

### Database

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviapostgresql.container.enabled` | Whether the demonstration PostgreSQL service is required. | `false` |
| `iviapostgresql.container.keySecretName` | An existing secret which contains the server.pem to be used by the server.  If no secret is supplied the server will only support 'unsecure' communication. The certificate file can be added as a secret using the following command: `kubectl create secret generic <secret-name> --from-file server.pem`.| empty |
| `iviapostgresql.resources.requests.memory` | The amount of memory to be allocated to the demonstration PostgreSQL service. | `512Mi` |
| `iviapostgresql.resources.requests.cpu` | The amount of CPU to be allocated to the demonstration PostgreSQL service. | `500m` |
| `iviapostgresql.resources.limits.memory` | The maximum amount of memory to be used by the demonstration PostgreSQL service. | `1Gi` |
| `iviapostgresql.resources.limits.cpu` | The maximum amount of CPU to be used by the demonstration PostgreSQL service. | `1000m` |
| `iviapostgresql.dataVolume.existingClaimName` | The name of an existing PersistentVolumeClaim to be used.| empty |
| `iviapostgresql.dataVolume.storageClassName` | The storage class of the backing PVC. | empty |
| `iviapostgresql.dataVolume.size` | The size of the data volume. | `20Gi` |
| `iviapostgresql.service.servicename` | Service name for postgreSQL. | `<release>-iviapostgresql` |

### Directory

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `iviaopenldap.container.enabled` | Whether the demonstration OpenLDAP service is required. | `false` |
| `iviaopenldap.container.keySecretName` | An existing secret containing cert and key for secure communication | empty |
| `iviaopenldap.resources.requests.memory` | The amount of memory to be allocated to the demonstration OpenLDAP service. | `512Mi` |
| `iviaopenldap.resources.requests.cpu` | The amount of CPU to be allocated to the demonstration OpenLDAP service. | `500m` |
| `iviaopenldap.resources.limits.memory` | The maximum amount of memory to be used by the demonstration OpenLDAP service. | `1Gi` |
| `iviaopenldap.resources.limits.cpu` | The maximum amount of CPU to be used by the demonstration OpenLDAP service. | `1000m` |
| `iviaopenldap.dataVolume.existingClaimName` | The name of an existing PersistentVolumeClaim to be used.| empty |
| `iviaopenldap.dataVolume.storageClassName` | The storage class of the backing PVC. | empty |
| `iviaopenldap.dataVolume.size` | The size of the data volume. | `20Gi` |
| `iviaopenldap.service.servicename` | Service name for postgreSQL. | `<release>-iviaopenldap` |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.  For example:

```bash
$ helm install my-release --set "iviaruntime.container.enabled=true" verify-identity-access
```

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart.  For example:

```bash
$ helm install my-release -f values.yaml verify-identity-access
```

## Storage

Different types of persistent storage are supported by this chart:

- Persistent storage using Kubernetes dynamic provisioning. Uses the default storage class defined by the Kubernetes admin or by using a custom storage class which will override the default.
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: true
  - Specify a custom storageClassName per volume or leave the value empty to use the default storage class.


- Persistent storage using a predefined PersistentVolumeClaim or PersistentVolume setup prior to the deployment of this chart.
  - Set global values to:
    - persistence.enabled: true
    - persistence.useDynamicProvisioning: false (default)
  - Specify an existingClaimName per volume or leave the value empty and let the Kubernetes binding process select a pre-existing volume based on the access mode and size.


- No persistent storage. This mode will use emptyPath for any volumes referenced in the deployment.
  - enable this mode by setting the global values to:
    - persistence.enabled: false
    - persistence.useDynamicProvisioning: false


The chart mounts a [Persistent Volume](http://kubernetes.io/docs/user-guide/persistent-volumes/). The volume is created using dynamic volume provisioning. If the PersistentVolumeClaim should not be managed by the chart, define the `iviaconfig.dataVolume.existingClaimName`, 'iviapostgresql.dataVolume.existingClaimName', and 'iviaopenldap.dataVolume.existingClaimName' parameters.

### Existing PersistentVolumeClaims

1. Create the PersistentVolume
1. Create the PersistentVolumeClaim
1. Install the chart
```bash
$ helm install --set "iviaconfig.dataVolume.existingClaimName=PVC_NAME" ...
```

All containers within the chart will share the same persistent volume claim.

## Limitations

* This helm chart is only supported on the amd64 architecture;
* The Verify Identity Access product does not encrypt the configuration data which is stored on disk and as such access to the disk should be restricted.

## Documentation
The official Verify Identity Access documentation can be located in the IBM knowledge centre: [https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html](https://www.ibm.com/support/knowledgecenter/en/SSPREK/welcome.html).
