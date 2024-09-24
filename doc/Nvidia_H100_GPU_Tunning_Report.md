# NVIDIA H100 GPU Tunning Report  
<br>

## 개요
이 문서는 NVIDIA H100 GPU 성능 최적화를 하기 위한 다양한 방법과 실질적인 예시를 다룬 시스템 레벨 가이드이다.

---
<br><br>

## 1. 전력 관리 최적화  
<br>

### 튜닝 포인트
<br>

a) **현재 전력 사용 모니터링**: `nvidia-smi` 명령어를 사용하여 GPU 의 현재 전력 사용량을 모니터링 합니다.

b) **전력 한계 설정**: `nvidia-smi -pl 600` 명령어로 전력 한계를 600W 로 설정한다.

c) **Persistence Mode 활성화**: GPU 초기화 시간을 단축하기 위해 `nvidia-smi -pm 1` 명령어로 Persistence Mode 를 활성화 합니다.
<br>

### 예시
```bash
# check current power consumming
$ nvidia-smi --query-gpu=power.draw --format=csv

# or
$ nvidia-smi -q -d POWER
Attached GPUs                             : 8
GPU 00000000:18:00.0
    GPU Power Readings
        Power Draw                        : 111.38 W
        Current Power Limit               : 700.00 W
        Requested Power Limit             : 700.00 W
        Default Power Limit               : 700.00 W
        Min Power Limit                   : 200.00 W
        Max Power Limit                   : 700.00 W
...

# setup power limitation as 600W
$ nvidia-smi -i 0 -pl 600

# Enabling Persistence Mode, it means across power limit after reboot
$ nvidia-smi -pm 1
```
<br><br>

## 2. PCIe 및 NVLink 최적화
<br>

### 배경
<br>

H100은 PCIe Gen5 를 지원하며, NVLink 4.0 을 통해 GPU간 고속 통신이 가능하다.
<br>

### 튜닝 포인트
<br>

a) **PCIe Gen5 모드 활성화**: BIOS 에서 PCIe Gen5 모드가 활성화 되었는지 확인.

b) 