# CTE for Kubernetes deployment files

Deployment files for CipherTrust Transparent Encryption for Kubernetes.

# About CTE for Kubernetes

Product Description:

[https://cpl.thalesgroup.com/encryption/ciphertrust-transparent-data-encryption-kubernetes](https://cpl.thalesgroup.com/encryption/ciphertrust-transparent-data-encryption-kubernetes)

More information can be found through Thales online documentation portal at:

[https://thalesdocs.com/ctp/cte-k8s/latest/](https://thalesdocs.com/ctp/cte-k8s/latest/)

# Quick installation guide
> **_NOTE:_**  Refer to the online docs for a detailed installation and configuration guide.

Install CTE for Kubernetes through the YAML files available in the
ciphertrust-transparent-encryption-kubernetes Git repository at:

`git clone https://github.com/thalescpl-io/ciphertrust-transparent-encryption-kubernetes.git`

The CTE for Kubernetes images are distributed though Docker Hub in the following
URL:

[https://hub.docker.com/r/thalesciphertrust/ciphertrust-transparent-encryption-kubernetes](https://hub.docker.com/r/thalesciphertrust/ciphertrust-transparent-encryption-kubernetes)

## Options for deploy.sh

|Option| Function| Description|
|------|---------|------------|
|-t|\--tag=| Tag of image on the server.  Default: latest|
|-r|\--remove=|Remove all the running pods, services and secrets|

## Deploy CTE for Kubernetes

Deploy using the following command:

``./deploy.sh``

## Uninstalling CTE for Kubernetes

Stop any pods that are using CTE-CSI volumes and run:

``./deploy.sh --remove``
