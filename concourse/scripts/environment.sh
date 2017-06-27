#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/../.." && pwd)

hashed_password() {
  echo "$1" | shasum -a 256 | base64 | head -c 32
}

DEPLOY_ENV=${DEPLOY_ENV:-}
if [ -z "${DEPLOY_ENV}" ]; then
  echo "Must specify DEPLOY_ENV environment variable" 1>&2
  exit 1
fi

AWS_ACCOUNT=${AWS_ACCOUNT:-dev}

CONCOURSE_ATC_USER=${CONCOURSE_ATC_USER:-admin}
case "${TARGET_CONCOURSE}" in
  bootstrap)
    CONCOURSE_URL="${CONCOURSE_URL:-http://localhost:8080}"
    FLY_TARGET="${FLY_TARGET:-${DEPLOY_ENV}-bootstrap}"
    FLY_CMD="${PROJECT_DIR}/bin/fly-bootstrap"

    if [ -z "${CONCOURSE_ATC_PASSWORD:-}" ]; then
        user_id=$(aws sts get-caller-identity | awk '$1 ~ /UserId/ {print $2}')
        CONCOURSE_ATC_PASSWORD=$(hashed_password "${user_id}")
    fi
    ;;
  deployer-concourse|build-concourse)
    if [ "$TARGET_CONCOURSE" == 'deployer-concourse' ]; then
      CONCOURSE_URL="${CONCOURSE_URL:-"https://deployer.${SYSTEM_DNS_ZONE_NAME}"}"
    else
      CONCOURSE_URL="${CONCOURSE_URL:-"https://concourse.${SYSTEM_DNS_ZONE_NAME}"}"
    fi
    FLY_TARGET="${FLY_TARGET:-$DEPLOY_ENV}"
    FLY_CMD="${PROJECT_DIR}/bin/fly"

    if [ -z "${CONCOURSE_ATC_PASSWORD:-}" ]; then
      CONCOURSE_ATC_PASSWORD=$(concourse/scripts/val_from_yaml.rb secrets.concourse_atc_password <(aws s3 cp "s3://gds-paas-${DEPLOY_ENV}-state/concourse-secrets.yml" -))
    fi
    ;;
  *)
    echo "Unrecognized TARGET_CONCOURSE: '${TARGET_CONCOURSE}'. Must be (bootstrap|deployer-concourse|build-concourse)" 1>&2
    exit 1
    ;;
esac

CONCOURSE_DATABASE_NAME="concourse"
CONCOURSE_DATABASE_USER="$(openssl rand -hex 10)"
CONCOURSE_DATABASE_PASS="$(openssl rand -hex 32)"

cat <<EOF
export AWS_ACCOUNT=${AWS_ACCOUNT}
export DEPLOY_ENV=${DEPLOY_ENV}
export CONCOURSE_ATC_USER=${CONCOURSE_ATC_USER}
export CONCOURSE_ATC_PASSWORD=${CONCOURSE_ATC_PASSWORD}
export CONCOURSE_URL=${CONCOURSE_URL}
export CONCOURSE_DATABASE_NAME=${CONCOURSE_DATABASE_NAME}
export CONCOURSE_DATABASE_USER=${CONCOURSE_DATABASE_USER}
export CONCOURSE_DATABASE_PASS=${CONCOURSE_DATABASE_PASS}
export VAGRANT_SSH_KEY=${PROJECT_DIR}/${DEPLOY_ENV}-vagrant-bootstrap-concourse
export FLY_CMD=${FLY_CMD}
export FLY_TARGET=${FLY_TARGET}
EOF
