# CTE for Kubernetes deployment files[^1]

[^1]: *NOTE: Product not yet released**

Deployment files for CipherTrust Transparent Encryption for Kubernetes.

# About CTE for Kubernetes

CTE for Kubernetes is an implementation of the CipherTrust Transparent
Encryption with native support for Kubernetes through the implementation of a
CSI driver. Unlike traditional CTE, proCobnutsllation and GuardPoint
management, is done through Kubernetes. This means that as the cluster scales up
with more nodes, CTE for Kubernetes scales with it. CTE for Kubernetes is
designed to protect Kubernetes Persistent Storage Claims that are backed by
storage with filesystem semantics.

Protection for raw devices is not supported at this time. In order to support
customers with diverse workloads, registration to CipherTrust Manager has been
decentralized from the cluster nodes/ hosts operating system. Registration now
happens through the use of Storage Classes which allows for a single cluster,
and even a single node, to register different CTE for Kubernetes groups, each
with a different set off policies and keys.

# Install CTE for Kubernetes

Install CTE for Kubernetes through the YAML files available in the
cte-csi-deploy Git repository at:

`git clone https://github.com/thalescpl-io/cte-csi-deploy.git`

The CTE for Kubernetes images are distributed though Docker Hub in the following
URL:

[https://hub.docker.com/repository/docker/thalesgroup/ciphertrust-transparent-encryption](https://hub.docker.com/repository/docker/thalesgroup/ciphertrust-transparent-encryption) [^1]

## Options for deploy.sh

|Option| Function| Description|
|------|---------|------------|
|-s=|--server=|Container registry server from where the CTE-CSI containers must be pulled|
|-u=|--user=|Container registry user name used by Kubernetes to login while pulling the image|
|-p=|--pass=|Container registry password used by Kubernetes to login while pulling the image|
|-r|--remove|Remove all the running pods, services and secrets|

## Deploy CTE for Kubernetes

Deploy using the following command:

``./deploy.sh -u=thalesctecsi -p=<token-string>``

## Uninstalling CTE for Kubernetes

Stop any pods that are using CTE-CSI volumes and run:

``./deploy.sh --remove``

