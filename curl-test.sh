#!/bin/bash

set -e

if [ "${DEBUG}" = 1 ]; then
    set -x
fi

# Usage:
#   curl ... | ENV_VAR=... sh -
#

# info logs the given argument at info log level.
info() {
    echo "[INFO] " "$@"
}

# warn logs the given argument at warn log level.
warn() {
    echo "[WARN] " "$@" >&2
}

# fatal logs the given argument at fatal log level.
fatal() {
    echo "[ERROR] " "$@" >&2
    if [ -n "${SUFFIX}" ]; then
        echo "[ALT] Please visit 'https://github.com/rancher/rke2/releases' directly and download the latest rke2.${SUFFIX}.tar.gz" >&2
    fi
    exit 1
}


# 루트 권한 확인
if [ "$EUID" -ne 0 ]
  then info "이 스크립트는 sudo 권한으로 실행해야 합니다."
  info "ex> $ curl -sSL url | sudo bash"
  exit -1
fi

info "sudo 로 실행 가능 합니다."

info "::: curl shell cript test-1 without dash(-)"
curl -sSL https://raw.githubusercontent.com/kubeops2/kubeops2/refs/heads/main/curl-test02.sh | sh

info "::: curl shell cript test-2 with dash(-)"
curl -sSL https://raw.githubusercontent.com/kubeops2/kubeops2/refs/heads/main/curl-test02.sh | sh -
