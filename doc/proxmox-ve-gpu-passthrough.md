# Proxmox-VE GPU-PassThrough 구성

<br>

_Proxmox-VE 에서 GPU 를 VM 및 Container 로 PCI-PassThrough 를 통해 GPU Resource 를 직접 사용 할 수 있는 Configuration 을 확인, 테스트한 결과를 정리 하였다._  

<br>

> 다음 공식 문서 및 레딧을 참고하여 테스트 하였음.  
> [ProxmoxVE PCI PassThrough](https://pve.proxmox.com/wiki/PCI_Passthrough)  
> [ProxmoxVE PCIe PassThrough](https://pve.proxmox.com/wiki/PCI(e)_Passthrough)  
> [ProxmoxVE Forum](https://forum.proxmox.com/threads/pci-gpu-passthrough-on-proxmox-ve-8-installation-and-configuration.130218/)  
> [Reddit - Ultimate Beginner's Guide to GPU Passthrough](https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/)

<br><br>

## Introduction

> PCI Passthrough 는 Physical PCI 장치(그래픽 카드, 네트워크 카드 등) 들을 VM 안에서 사용할 수 있도록 허용하는 기술이다.  

> [!NOTE]허나 PCI Passthrough 를 사용한 PCI 장치는 VM 에서 사용할 수 있게 되지만, Host 에서는 더 이상 쓸 수 없게 되며, GPU 에 모니터를 연결한 경우, 모니터로 Host Booting 및 Host BIOS 등도 쓸 수 없게 된다.  

<br>

## TL;NR

<ins>Proxmox-VE 에서 GPU Passthrough 구성을 통한 Linux VM 구성 실패 </ins>

<br>

1. PC 용 메인보드, CPU, Graphic 카드는 제조 벤더, 오버클럭 구성 및 Profile, BIOS 조합과 상성 등이 다양함.

2. Proxmox-VE 에서는 PC 장비들과 제조사들에 대한 H/W Compatible list 가 없으며, 이를 통한 GPU-Passthrough 구성을 Guarantee 하지 않음.

3. 오로지 Proxmox-VE 와 Reddit Forum 을 이용한 User Case 로 트러블 슈팅 및 셋업을 시도해야 하며, 확인된 케이스들로 테스트를 진행.

4. GPU-Passthrough 구성을 위한 GPU ROM 초기화 및 별도 ROM 구성의 방법은 리스크가 있으며, GPU 손상 및 A/S 불가 상황을 만들수 있으므로, 시도하기 부담 스러움.


<br>

## Requirements

<br>

**CPU requirements**  
* CPU 는 hardware virtualization 과 IOMMU 를 지원해야 한다.
* Motherboard
  * Motherboard 의 칩셋이 IOMMU 를 지원해야 한다.
* GPU 의 ROM 이 UEFI 를 지원하는 것이 필요하지 않지만, 대부분의 GPU 가 지원하며, 만약 GPU ROM 이 UEFI 를 지원하면, <ins>**SeaBIOS 대신 OVMF(UEFI) 를 사용**</ins> 해야 한다.

<br>
<br>


## Specifications for H/W and ProxmoxVE

<br>

> ProxmoxVE 가 설치된 장비의 스펙.

| Kind | Model |
| - | - |
| Motherboard | MSI PRO Z790-A WIFI |
| CPU | 13th Gen Intel Core i7-13700K - 16 Core - 24 HT |
| GPU | Nvidia GeForce RTX 4090 |
| MEM | 128GiB = 32GiB * 4 Bank |
| SSD | 2TB SSD NVME M2 |
| DISK | 4TB Spinning DISK |
| NIC | wired NIC 1GB |
| NIC2 | wireless NIC |

<br>

> ProxmoxVE Hypervisor Configuration

| Kind | Version |
| - | - |
| ProxmoxVE | 8.2-2 |
| BIOS Setting1 | VT-d Enabled |
| BIOS Setting2 | IOMMU Enabled |
| SDN | Flat Network with Linux Bridge |

<br>

## GPU ROM Check

> Graphic Card 가 UEFI(OVMF) 호환성을 가졌는지 확인한다.  

```bash
root@dev01:~/github/rom-parser# ./rom-parser /tmp/image.rom 
Valid ROM signature found @0h, PCIR offset 170h
        PCIR: type 0 (x86 PC-AT), vendor: 10de, device: 2684, class: 030000
        PCIR: revision 0, vendor revision: 1
Valid ROM signature found @fc00h, PCIR offset 1ch
        PCIR: type 3 (EFI), vendor: 10de, device: 2684, class: 000000
        PCIR: revision 3, vendor revision: 0
                EFI: Signature Valid, Subsystem: Boot, Machine: X64
        Last image
root@dev01:~/github/rom-parser#
```

`type 3` 이 결과에서 확인 되며, 이는 UEFI compatible 의 의미이다.

<br>
<br>

## H/W 설정

<br>

| 구성 순서 | Action | 상세 | 결과 |
| - | - | - | - |
| CPU | CPU 의 가상화 및 IOMMU 지원 확인 | CPU 스펙 확인 | 지원 확인 |
| MotherBoard | BIOS 구성 확인 | CPU Overclocking Menu 에서 IOMMU 옵션 확인 | 활성화 |
| MotherBoard Firmware | BIOS 확인 | 2022.08.14 버전 | 2024.9 버전 업글 완료 |

<br>

## Proxmox-VE Debian OS 설정

<br>

1. GRUB 에 커널 파라메터 적용
```bash
$ nano /etc/default/grub 
  GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction nofb nomodeset video=vesafb:off,efifb:off"

```

<br>

2. GRUB 재 생성
```bash
$ update-grub
```

<br>

3. module 추가
```bash
# vfio 는 vertual Function I/O 로 VM 에서 PCI 에 직접 접근하는데 필요한 모듈
$ nano /etc/modules 
   vfio
   vfio_iommu_type1
   vfio_pci
   vfio_virqfd
```

<br>

4. IOMMU Remapping
```bash
$ nano /etc/modprobe.d/iommu_unsafe_interrupts.conf 
   options vfio_iommu_type1 allow_unsafe_interrupts=1

$ nano /etc/modprobe.d/kvm.conf 
   options kvm ignore_msrs=1
```

<br>

5. Host(Proxmox-VE) 에서 GPU 를 쓰지 않도록 Blacklist module 로 등록

```bash
$ nano /etc/modprobe.d/blacklist.conf 
   blacklist radeon
   blacklist nouveau
   blacklist nvidia
   blacklist nvidiafb
```

<br>

6. GPU 를 VFIO 로 추가하기

```bash
$ lspci -v 
# GPU 장치의 device number 를 확인

$ lspci -n -s (PCI card address)
# 확인된 GPU PCI Card 의 Address 를 확인

$ nano /etc/modprobe.d/vfio.conf 
   options vfio-pci ids=xxxxxxxxx disable_vga=1
# 확인한 장치를 vfio-pci 에서 쓸 수 있도록 구성
```

<br>

7. 업데이트한 커널 모듈들이 포함된 initramfs 를 새로 생성
```bash
$ update-initramfs -u 
```

<br>

8. 재부팅


> [!NOTE]
   PCI-Passthrough 는 `i440fx` 과 `q35` 칩셋을 모두 지원하지만, PCIe passthrough 는 오직 `q35` 만 가능함.  

<br>
