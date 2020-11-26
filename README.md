# Version Information
These assets are for IBM Security Verify Access v10.0.0

Assets for IBM Security Access Manager are available at https://ibm.biz/isamdocker

# Resources
## Cookbooks
### Deployment with Native Docker and Docker Compose
This cookbook describes deployment with Native Docker and Docker Compose.  It covers some docker concepts, deployment of Verify Access containers, and initial configuration of a simple Verify Access system.  An IBMid is required for access to the Security Learning Academy but you can sign-up free of charge.
Find it here: https://ibm.biz/Verify_Access_Docker_Cookbook

### Deployment on RedHat OpenShift
This cookbook describes deployment on RedHat Openshift 3.x.  It covers some OpenShift concepts, deployment of Verify Access templates, and initial configuration of a simple Verify Access System.  An IBMid is required for access to the Security Learning Academy but you can sign-up free of charge.
Find it here: https://ibm.biz/VerifyAccessOpenShiftCookbook

## Community assistance
If you have questions about deployment, or about IBM Security Verify, you can ask them on the IAM Group of the IBM Security Community:
https://ibm.biz/iamcommunity

# Common Requirements and Setup

These scripts expect to have write access to $HOME and /tmp.

The docker compose scripts will create a $HOME/dockershare directory.  If you want to use a different directory, you'll need to modify the common/env-config.sh file AND the docker-compose YAML file.

All passwords set by these scripts are `Passw0rd`.  Obviously this is not a secure password!

# Create Keystores
Before running any other scripts, run `container-deployment/common/create-ldap-and-postgres-keys.sh`

This will create the container-deployment/local/dockerkeys directory and populate it with keystores for PostgreSQL and OpenLDAP containers.

# Native Docker
To set up a native Docker environment, use the files in container-deployment/docker.

These scripts assume you have the following IP addresses available locally on your Docker system:
- 127.0.0.2 (lmi.iamlab.ibm.com)
- 127.0.0.3 (www.iamlab.ibm.com)

If you want to use other local IP addresses then you'll need to modify the common/env-config.sh file.

Run `./docker-setup.sh` script to create docker containers.

You can now connect to the Verify Access LMI at https://127.0.0.2

To clean up the docker resources created, run the `./cleanup.sh` script.

# Docker Compose
To set up an environment with docker-compose, use the files in container-deployment/compose.

These scripts will create the $HOME/dockershare directory.

These scripts assume you have the following IP addresses available locally on your Docker system:
- 127.0.0.2 (lmi.iamlab.ibm.com)
- 127.0.0.3 (www.iamlab.ibm.com)

If you want to use other local IP addresses then you'll need to modify the common/env-config.sh file and run `./update-env-file.sh`

Run `./create-keyshares.sh` to copy keys to $HOME/dockershare/composekeys directory

Change directory to the `iamlab` directory.

Run command `docker-compose up -d` to create containers.

You can now connect to the Verify Access LMI at https://127.0.0.2

To clean up the docker resources created, run `docker-compose down -v` command.

# Kubernetes
To set up an environment using Kubernetes, use the files in container-deployment/kubernetes.

These scripts assume that you have the `kubectl` utility installed and that it is configured to talk to your cluster.

First, run `./create-secrets.sh` command to create the secrets required for the environment.

Then, run `kubectl create -f <YAML file>` to define the resources required.

There are YAML files for the following environments:
- Minikube (isva-minikube.yaml)
   - Also works with Kubernetes included with Docker CE on Mac
- IBM Cloud Free Edition (isva-ibmcloud.yaml)
- IBM Cloud Paid Edition (isva-ibmcloud-pvc.yaml)
- Google (isva-google.yaml)

Once all pods are running, you can run the `./lmi-access.sh` script to start a port-forward session for access to the LMI.
With this running, you can access LMI using at https://localhost:9443

To access the Reverse Proxy you will need to determine an External IP for a Node in the cluster and then connnect to this using https on port 30443.

For Minikube an Ingress is defined.  This allows direct access to the Reverse Proxy when DNS points www.iamlab.ibm.com to the Minikube ingress controller IP address.

For Google, access to a NodePort requires the following filewall rule to be created:
`gcloud compute firewall-rules create isvawrp-node-port --allow tcp:30443`

# Helm 3.0
To set up an environment using Helm, use the files in container-deployment/helm.

These charts should work with Helm 2.0 but the scripts here are for Helm 3.0.

These scripts assume that you have the `kubectl` and `helm` utilities installed and that they are configured to talk to a cluster.

First, run `./create-secrets.sh` command to create the secrets required for the environment.

Then, run `helm-install.sh` to run the helm command to create a Security Verify release.

The output from this command includes the information you will need to connect to the LMI and Reverse Proxy services.

If you want to be able to restore a configuration archive created in other environments described here, you will need to allow the names used in the other deployments to resolve.  If your Kubernetes cluster uses CoreDNS, you can use command `kubectl create -f update-coredns.yaml` to add suitable rewrite rules.  Otherwise you will need to manually modify the configuration after deployment to replace hostnames wherever they appear.

NOTE: The Helm Charts included here are similar to those hosted at: https://github.com/ibm-security/helm-charts
You can add these as a Helm repo using this URL: https://raw.githubusercontent.com/IBM-Security/helm-charts/master/repo/stable

# OpenShift
To set up an environment using OpenShift, use the files in container-deployment/openshift.

These scripts assume that you have the `oc` utility installed and it is configured to talk to your OpenShift system.

Custom Security Constraints are required to run IBM Security Verify Access under OpenShift.  The Verify Access containers requires setuid and setgid permissions.
In addition, the openldap container requires permission to run as root.

You must be a cluster administrator to add security constraints and grant them to service accounts.  For example, login as system user:

```oc login -u system:admin -n <project>```

To set up the required security context constaints, run `./setup-security.sh` command.

Now login as your standard user:

```oc login -u developer -n <project>```

Next, run `./create-secrets.sh` command to create the secrets required for the environment.

You can use the provided template files in two ways

## Load templates and then use in console
Load the templates using the following commands:

```
oc create -f verify-access-openldap-template.yaml
oc create -f verify-access-postgresql-template.yaml
oc create -f verify-access-core-template.yaml
oc create -f verify-access-rp-template.yaml
```
Then open the OpenShift console (e.g. https://localhost:8443), login as your standard user, locate the templates in the Catalog (inside your project), and click to deploy.  You can update the default deploy parameters during this process.

## Deploy directly from templates on the command line
Use these commands to process the Verify Access templates and use the output to deploy.  Using this method will use the default deploy parameters in the template.  You can edit the template to change them or override on the command-line.

```
oc process -f verify-access-openldap-template.yaml | oc create -f -
oc process -f verify-access-postgresql-template.yaml | oc create -f -
oc process -f verify-access-core-template.yaml | oc create -f -
oc process -f verify-access-rp-template.yaml | oc create -f -
```

Once Verify Access is deployed, you can run the `./lmi-access.sh` script to start a port-forward session for access to the LMI.
With this running, you can access LMI using at https://localhost:9443.

OpenShift includes a web proxy which can route traffic to the Verify Access Reverse Proxy.  You will need to determine the IP address where this is listening and then point www.iamlab.ibm.com to it in your /etc/hosts file.

If the LMI port-forwarding isn't stable, you can also create a route using the provided `lmi-route.yaml` file (but this will open your LMI to the world).  You will need to determine the IP address where this is listening and then point lmi.iamlab.ibm.com to it in your /etc/hosts file.

# Backup and Restore

To backup the state of your environment, use the `./isva-backup....sh` script in the directory for the environment you're using.  The backup tar file created will contain:
- Content of the .../local/dockerkeys directory
- OpenLDAP directory content
- PostgreSQL database content
- Configuration snapshot from the Verify Access config container

To restore from a backup, perform these steps:

1. Delete the .../local/dockerkeys directory
1. Run `container-deployment/common/restore-keys.sh <archive tar file>`
1. Complete setup for the environment you want to create (until containers are running)
1. Run `./isva-restore....sh <archive tar file>` to restore configuration.

# License

The contents of this repository are open-source under the Apache 2.0 licence.

```
Copyright 2018-2020 International Business Machines

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
