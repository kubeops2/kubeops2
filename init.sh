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
  then info "::: 이 스크립트는 sudo 권한으로 실행해야 합니다."
  info "::: ex> $ curl -sSL url | sudo bash"
  exit -1
fi

info "::: sudo 로 실행 가능 합니다."
sleep 1

# line breaker
echo;echo

# Check variables
# INSTALL_RKE2_VERSION 과 INSTALL_RKE2_TYPE 을 체크한다.
RKE2_VERSION=v1.30.5-rc3+rke2r1
RKE2_TYPE=server
RKE2_ADMIN=kubeops


# /etc/security/limits.conf 파일 수정
info "::: 시스템 전체의 파일 디스크립터 제한 설정 중..."
if grep -q "nofile" /etc/security/limits.conf; then
    sed -i '/nofile/d' /etc/security/limits.conf
fi
echo "*       soft    nofile  65535" >> /etc/security/limits.conf
echo "*       hard    nofile  65535" >> /etc/security/limits.conf
info "완료: /etc/security/limits.conf 파일이 수정되었습니다."

# /etc/sysctl.conf 파일 수정
info "::: Applying Kernel Parameters..."
if grep -q "fs.inotify.max_user_watches" /etc/sysctl.conf; then
    sed -i '/fs.inotify.max_user_watches/d' /etc/sysctl.conf
fi
if grep -q "fs.inotify.max_user_instances" /etc/sysctl.conf; then
    sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
fi

echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf
info "::: 완료: /etc/sysctl.conf 파일이 수정되었습니다."

sysctl -p

# swap off 처리
# /etc/fstab 에 swap 라인 주석 처리 필요
info "::: Deactivating Swap space..."
sed -i 's/\/swap/#swap/g' /etc/fstab
swapoff -a

# Install Tools
info "::: Installing yq and jq ..."
apt update
apt install iptables -y
snap install yq jq
# apt update

# Install RKE2 As a server
echo;echo
info "::: Install RKE2 with ${RKE2_VERSION} and ${RKE2_TYPE} mode ..."
sleep 1


curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${RKE2_VERSION} INSTSLL_RKE2_TYPE=${RKE2_TYPE} sh -

echo;echo
info "::: Enabling and Starting RKE2-Server service ..."
sleep 1
systemctl enable rke2-server.service
systemctl start rke2-server.service
# journalctl -u rke2-server -f

echo;echo
info "::: Done!!! - Enabling and Starting RKE2-Server service ... "
sleep 1

# install helm
info "::: Install Helm..."
snap install helm --classic

# Setting up User Environment
echo;echo
info "::: Setting User ${RKE2_ADMIN} Environment..."
sleep 1
mkdir -p ~/.kube
cp /etc/rancher/rke2/rke2.yaml ~${RKE2_ADMIN}/.kube/config
chown -R ${RKE2_ADMIN}:${RKE2_ADMIN} ~/.kube
chmod 600 /home/${RKE2_ADMIN}/.kube/config
export KUBECONFIG=~${RKE2_ADMIN}/.kube/config
PATH=$PATH:/var/lib/rancher/rke2/bin
echo "PATH=$PATH:/var/lib/rancher/rke2/bin" >> ~${RKE2_ADMIN}/.bashrc
export PATH=$PATH:/var/lib/rancher/rke2/bin

echo;echo
info "::: Finish ${RKE2_ADMIN} Environment..."
sleep 1


# Setting up k9s
echo;echo
info "::: Install k9s tool..."
curl -sS https://webi.sh/k9s | sh
source ~${RKE2_ADMIN}/.config/envman/PATH.env
echo "source <(kubectl completion bash)" >> ~${RKE2_ADMIN}/.bashrc

# Test
echo;echo
info "::: Running the below command for testing!!!"
info "::: kubectl get nodes"
sleep 1