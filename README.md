# Kaniko-builder

Kubernetes solution that utilizes Google's kaniko tool to build container images when its recipe is already defined in a docker file.

## Overview

Google's kaniko tool doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

kaniko is meant to be run as an image: `gcr.io/kaniko-project/executor`

Kaniko-builder is a tool to build container images from a Dockerfile, inside a container or Kubernetes cluster, without needing privileged root access. It allows for building container images in environments where Docker is not available, or where users require more control over the image creation process. Additionally, it pushes the built image to a set up docker registry.

Kaniko-builder executes first an init container to determine if the target image to build is already available in the specified docker registry to make decisions about building or not the target container image.

## Prerequisites

- Kubectl available in your machine
- Kubernetes cluster running
- Access to a Docker registry for storing container images

## Components
1. Init Container (name = kaniko-init)
The init container checks if the container image exists in the Docker registry. If the image exists, the pod's main container will not be created. The init container also checks search for a FORCE_BUILD parameter to force building the image regardless if it exists or not in the docker registry.

2. Main Container (name = image-builder)
The main container runs kaniko container to build the target image specified in the YAML manifest.

3. Push to Docker Registry
Once the target image is built with the Kaniko main container, it is pushed to a set up Docker registry.

## Configuration
The `kaniko-builder.yaml` file expects the target docker file and the dependencies to be mounted in the machine running the Kubernetes cluster at the folder `/workspace` which is the default folder configured as context for the Google's kaniko tool builder. 

The `kaniko-builder.yaml` does not require any change to achieve its purpose. The configurations are done using secret and configmap Kubernetes resources.

All the resources are created under the namespace `kaniko`, so create the namespace:

```bash
kubectl create ns kaniko
```

To specify to kaniko-builder how to access the docker registry a secret is mounted in the kaniko container:

```bash
kubectl create secret docker-registry docker-config-secret \
  --docker-server=<server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email> \
  --namespace=kaniko
```

To specify to kaniko-builder what is the name of the docker file to use to build the image and the output image name, is described with a configmap:

```bash
kubectl create configmap my-kaniko-builder-configmap \
  --from-literal=DOCKER_FILENAME=example.dockerfile \
  --from-literal=DOCKER_IMAGENAME=example \
  --from-literal=DOCKER_IMAGETAG=v1.0.0 \
  --from-literal=FORCE_BUILD=Y \
  --namespace=kaniko
```

The flag `FORCE_BUILD=Y` is used to force the build of the target image regardless if the image is available or not in the docker registry.

## Usage

To start the kaniko-builder, apply the kaniko Kubernetes manifest:

```bash
kubectl apply -f kaniko-builder.yaml
```

