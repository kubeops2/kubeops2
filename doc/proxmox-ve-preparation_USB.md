# Prepare Installation Media

> 이 문서는 Mac 에서 Proxmox-VE 설치 USB-Media 를 만드는 방법을 설명한다.  
> [Proxmox-VE 공식 문서](https://pve.proxmox.com/wiki/Prepare_Installation_Media)

<br>

## Requirements

<br>

1. Proxmox-VE ISO 이미지를 준비
    > 이 문서 작성 시 최신 버전은 **8.2-2** 버전  
    > [Proxmox-VE ISO Image Download](https://www.proxmox.com/en/downloads)

<br>

2. USB Flash drive
    > :floppy_disk: 가 필요함. 다이소에서 32GB 5,000원에 구입 가능  
    > 최소 2GB 정도의 용량이 필요함.

<br>

## Instructions for Apple MacOS

<br>

> 다음 MacOS 에서 설치 Media 구성 확인됨.  
> | OS version | Sonoma 14.6.1 |
> | ---------- | ------------- |
> | H/W | Apple M3 Pro |
  
<br>  

1. `Terminal` 창에서 다음 명령을 통해 iso 파일을 dmg 파일로 변환한다.  
   ```shell
   # hdiutil convert proxmox-ve_*.iso -format UDRW -o proxmox-ve_*.dmg
   ```
<br>

2. 이제 USB flash drive 를 장착하고, 장치를 확인한다.
   > `diskX` 에 X 는 숫자이며, usb-flash drive 는 다음과 같이 `External` 로 확인 할 수 있다. (맨 아래)

   ```shell
   $ diskutil list
   /dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.3 GB   disk0
   1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
   2:                 Apple_APFS Container disk3         494.4 GB   disk0s2
   3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3

   /dev/disk3 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +494.4 GB   disk3
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            10.3 GB    disk3s1
   2:              APFS Snapshot com.apple.os.update-... 10.3 GB    disk3s1s1
   3:                APFS Volume Preboot                 6.1 GB     disk3s2
   4:                APFS Volume Recovery                935.6 MB   disk3s3
   5:                APFS Volume Data                    95.6 GB    disk3s5
   6:                APFS Volume VM                      3.2 GB     disk3s6

   /dev/disk4 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *31.5 GB    disk4
   1:             Windows_FAT_32 NO NAME                 31.5 GB    disk4s1   ```

<br>

3. 해당 장치를 `Unmount` 한다.
   ```shell
   $ diskutil unmountDisk /dev/disk4
   ```

<br>

4. 이제 `proxmox-ve-<version>.dmg` 파일을 해당 flash drive 에 쓴다.
   ```shell
   $ sudo dd if=proxmox-ve_*.dmg bs=1M df=/dev/rdisk4
   ```

<br>

5. 설치 할 시스템 BIOS 에서 Boot Order 를 조정하여, 준비한 USB Flash drive 로 설치를 한다.

