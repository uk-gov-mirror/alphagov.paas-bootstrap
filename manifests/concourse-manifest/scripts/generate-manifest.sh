#!/bin/sh

set -eu

PAAS_BOOTSTRAP_DIR=${PAAS_BOOTSTRAP_DIR:-paas-bootstrap}
WORKDIR=${WORKDIR:-.}

ruby "${PAAS_BOOTSTRAP_DIR}/manifest/concourse-manifest/scripts/generate-auth-config.rb" "paas-trusted-people/users.yml" \
  > "${WORKDIR}/concourse-auth-config.yml"

# shellcheck disable=SC2086
spruce merge \
  --prune meta \
  --prune secrets \
  --prune terraform_outputs \
  "${PAAS_BOOTSTRAP_DIR}/manifests/concourse-manifest/concourse-base.yml" \
  "${PAAS_BOOTSTRAP_DIR}/manifests/concourse-manifest/operations.d/010-x-frame-options.yml" \
  "${WORKDIR}/bosh-secrets/bosh-secrets.yml" \
  "${WORKDIR}/terraform-outputs/concourse-terraform-outputs.yml" \
  "${WORKDIR}/terraform-outputs/vpc-terraform-outputs.yml" \
  "${WORKDIR}/terraform-outputs/bosh-terraform-outputs.yml" \
  "${WORKDIR}/concourse-auth-config.yml"
