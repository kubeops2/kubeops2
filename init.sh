#!/bin/bash

# 루트 권한 확인
if [ "$EUID" -ne 0 ]
  then echo "이 스크립트는 루트 권한으로 실행해야 합니다."
  exit
fi

echo "이 것은 루트로 실행 됩니다."

# /etc/security/limits.conf 파일 수정
# echo "시스템 전체의 파일 디스크립터 제한 설정 중..."
# if grep -q "nofile" /etc/security/limits.conf; then
#     sed -i '/nofile/d' /etc/security/limits.conf
# fi
# echo "*       soft    nofile  65535" >> /etc/security/limits.conf
# echo "*       hard    nofile  65535" >> /etc/security/limits.conf
# echo "완료: /etc/security/limits.conf 파일이 수정되었습니다."

# /etc/sysctl.conf 파일 수정
# echo "커널 파라미터 설정 중..."
# if grep -q "fs.inotify.max_user_watches" /etc/sysctl.conf; then
#     sed -i '/fs.inotify.max_user_watches/d' /etc/sysctl.conf
# fi
# if grep -q "fs.inotify.max_user_instances" /etc/sysctl.conf; then
#     sed -i '/fs.inotify.max_user_instances/d' /etc/sysctl.conf
# fi

# swap off 처리
# /etc/fstab 에 swap 라인 주석 처리 필요
# sed -i 's/\/swap/#swap/g' /etc/fstab
# sudo swapoff -a
