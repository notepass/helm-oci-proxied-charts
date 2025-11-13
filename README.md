# Helm chart proxy for OCI only artifacts
This repo is a manually updated mirror of OCI-Only helm charts with the added metadata
for using it as a proper helm repository.  
I created it, as the OCI integration in helm is still very poor and breaks a lot of workflows.

## Currently deployed
- gha-runner-scale-set-controller from the [ghcr.io](oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller) Repository
- n8n from the [8gears.container-registry.com](oci://8gears.container-registry.com/library/n8n) Repository
- paperless-ngx from the [wrenix](https://git.chaos.fyi/wrenix/helm-charts/src/branch/main/paperless-ngx) Repository
