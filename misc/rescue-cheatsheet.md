#  Linux Rescue Cheat Sheet

Just some quick hints for future-me  when a PC won't boot or a disk won't mount.

Boot any of these Live ISOs with **Ventoy** to start recovery:

| ISO              | Purpose           |
|------------------|-------------------|
| SystemRescue     | Linux recovery    |
| Hirens BootCD PE | Windows recovery  |
| GParted Live     | Partition editing |
| Rescuezilla      | Disk imaging      |

## List disks and partitions

```bash
lsblk -f                                   # Show block devices with mountpoints and filesystems
fdisk -l                                   # Show partition layout (MBR/GPT)
blkid                                      # Show UUIDs and filesystem info
parted -l                                  # Show disk info + partition table
lsblk -d -o name,rota                      # Check if disk is SSD (rota = 0)
lsblk -d -o name,serial,model              # Disk model and serial
lsblk -o NAME,FSTYPE,LABEL,UUID,MOUNTPOINT # List labels
```

## Label partitions

```bash
e2label /dev/sdXn mylabel                  # Label ext4
mlabel -i /dev/sdXn ::MYLABEL              # Label FAT32/exFAT
ntfslabel /dev/sdXn MYLABEL                # Label NTFS
btrfs filesystem label /mnt mylabel        # Label Brtfs (mounted)
btrfs label /dev/sdXn mylabel              # Label Brtfs (not mounted)
```

## Mount partitions

```bash
mount /dev/sdXn /mnt/rescue                # Mount a partition
mount -o ro /dev/sdXn /mnt/rescue          # Mount read-only
mount UUID=xxxx-xxxx /mnt/rescue           # Mount using UUID
mount -L mylabel /mnt/mylocation           # Mount using label
mount -t auto /dev/sdXn /mnt/rescue        # Let Linux auto-detect FS type
umount /mnt/rescue                         # Unmount
mkdir -p /mnt/rescue/mydisk && mount /dev/sdXn /mnt/rescue/mydisk
```

## Check and repair filesystems

```bash
fsck /dev/sdXn                             # Check and repair EXT/FAT filesystems
fsck.ext4 /dev/sdXn                        # For EXT4 specifically
ntfsfix /dev/sdXn                          # Basic NTFS fix
btrfs check /dev/sdXn                      # Btrfs check
xfs_repair /dev/sdXn                       # XFS check
```

## Copy or backup data

```bash
rsync -a /mnt/rescue/source/ /mnt/rescue/backup/      # Copy with permissions
rsync -aAXv /mnt/rescue/source/ /mnt/rescue/backup/   # Include ACLs, xattrs, symlinks
cp -av /mnt/rescue/source/* /mnt/rescue/backup/       # Alternative
dd if=/dev/sdX of=/mnt/rescue/backup/fulldisk.img bs=4M status=progress
dd if=/dev/sdXn of=/mnt/rescue/backup/part.img bs=1M status=progress
```

## Partitioning and disk tools

```bash
cfdisk /dev/sdX                              # Interactive TUI partitioner
parted /dev/sdX                              # CLI partitioner
wipefs -a /dev/sdX                           # Remove FS signatures
sgdisk --zap-all /dev/sdX                    # GPT-specific zap of partition table
dd if=/dev/zero of=/dev/sdX bs=1M count=100  # Wipe first part of disk (MBR/GPT, bootloader, signatures)
```

## Chroot

```bash
mkdir -p /mnt/rescue                  # Create the target directory to mount the system into
mount /dev/sdXn /mnt/rescue           # Mount the root partition of the installed system

mount --bind /dev  /mnt/rescue/dev    # Make device nodes (e.g. disks, USBs) accessible inside chroot
mount --bind /proc /mnt/rescue/proc   # Mount the process info filesystem (for tools like ps, top)
mount --bind /sys  /mnt/rescue/sys    # Mount system info (hardware, kernel interfaces)
mount --bind /run  /mnt/rescue/run    # Required by some modern services (e.g. networking, dbus)

chroot /mnt/rescue                    # Switch to the mounted system as if it's your root environment

# run the desired commands

# afterwards:
exit
umount /mnt/rescue/dev
umount /mnt/rescue/proc
umount /mnt/rescue/sys
umount /mnt/rescue/run
umount /mnt/rescue
```

## Show process file usage

```bash
lsof /mnt/target                 # Show open files under this mount
lsof /path/to/file               # Who is using a specific file?
lsof /dev/sdX                    # Who is using this block device?

fuser -vam /mnt/target           # Verbose process list using this mountpoint

fuser -k /mnt/target             # Kill all processes using this path
kill -9 <PID>                    # Manually kill a specific process

lsof | grep deleted              # Useful when disk space won't free up
```

## Recover GRUB (Linux boot issues)

```bash
# See Chroot commands above
grub-install /dev/sdX
update-grub
```

## Reset Linux password

```bash
# See Chroot commands above
passwd
```

## Network diagnostics

```bash
ip a                        # Show interfaces and IPs
ip r                        # Show routing table (default gateway?)
ip link                     # Show interfaces (UP/DOWN, MAC addr, etc.)
ip -s link                  # Interface stats (packets, errors, dropped)

ss -tulpen                  # Show listening ports (TCP/UDP + processes)
netstat -rn                 # Alternative routing table (ifconfig-style)
hostname -I                 # Show assigned IP(s)

ping 1.1.1.1                # Test internet by IP
ping google.com             # Test DNS + internet
resolvectl status           # Show DNS setup (on systemd-based systems)
dig google.com              # DNS lookup (needs `bind-utils` or `dnsutils`)
nslookup google.com         # DNS test (older tool)

nmcli device wifi list      # List WiFi networks
nmcli radio wifi            # Is WiFi enabled?
nmcli d wifi rescan         # Force WiFi scan
iw dev                      # Show wireless interfaces
iw dev wlan0 link           # Show current connection (SSID, signal)
iwlist wlan0 scan           # Full WiFi scan (older tool)

curl -I https://example.com # Test HTTP reachability
wget https://example.com    # Test download / connectivity
traceroute google.com       # Route tracing (install if needed)
mtr google.com              # Real-time traceroute (advanced)

arp -a                      # Show local ARP cache (devices on LAN)
nmap -sn 192.168.1.0/24     # Ping scan local network (needs `nmap`)
```

## Common rescue tools (e.g. with SystemRescue)

| Tool           | Purpose                             |
|----------------|-------------------------------------|
| testdisk       | Recover lost partitions             |
| photorec       | Recover deleted files               |
| gparted        | GUI partition editor                |
| disks          | GNOME Disks tool                    |
| smartctl       | Disk SMART diagnostics              |
| hdparm         | Disk benchmark                      |
| lshw           | Hardware information                |
| ncdu           | Disk usage analysis                 |
| htop           | Process monitor (TUI)               |
| mc             | Midnight Commander file manager     |
| filezilla      | Graphical SFTP/FTP client           |
| pcmanfm        | Lightweight file manager            |
| thunar         | XFCE file manager                   |
| xfce4-terminal | GUI terminal emulator               |
| firefox        | Browser (upload logs or search)     |
| baobab         | GNOME Disk Usage Analyzer (GUI)     |
| bleachbit      | Cleanup utility (GUI)               |

## NTFS/Windows recovery

```bash
lsblk -f                                           # Identify NTFS volumes
ntfs-3g /dev/sdXn /mnt/rescue                      # Mount with ntfs-3g
ntfs-3g -o ro /dev/sdXn /mnt/rescue                # Mount read-only
ntfsfix /dev/sdXn                                  # Basic NTFS repair
rsync -a /mnt/rescue/ntfs /mnt/rescue/backup       # Copy files
chntpw -i /mnt/rescue/Windows/System32/config/SAM  # Reset local Windows password
```

## Mount BitLocker (with recovery key)

```bash
dislocker -V /dev/sdXn -u -- /mnt/rescue/bitlocker
mount -o loop /mnt/rescue/bitlocker/dislocker-file /mnt/rescue/recovered
```

## Start GUI (if available)

```bash
startx
systemctl isolate graphical.target
```

## Log inspection & troubleshooting

```bash
dmesg | tail -20       # Kernel logs
journalctl -xb         # Boot logs
```

## Hardware identification

```bash
lspci                  # PCI devices (GPU/NIC/etc.)
lsusb                  # USB devices
inxi -Fxz              # Detailed hardware info
dmidecode -t memory    # RAM info
```

## USB detection

```bash
dmesg | grep -i usb
ls /dev/disk/by-label/
```

## Emergency CLI Tricks

```bash
mount -o remount,rw /                                # Remount root as writable
cat /proc/mdstat                                     # Check RAID array status
cryptsetup luksOpen /dev/sdXn myvault                # Unlock LUKS encrypted volume
mount /dev/mapper/myvault /mnt/rescue/secret         # Mount unlocked encrypted volume
rsync -av --exclude="*.iso" /mnt/rescue /mnt/rescue2 # Backup excluding ISOs
lsof | grep /mnt/rescue                              # See processes using /mnt/rescue
kill -9 PID                                          # Kill a stuck process
strace -p PID                                        # Trace what a process is doing
```

## Install missing tools (on-the-fly)

**Debian/Ubuntu-based Live system:**

```bash
apt update
apt install testdisk photorec smartmontools htop mc inxi
```

**Arch-based (e.g. SystemRescue):**

```bash
pacman -Sy
pacman -S testdisk gparted smartmontools htop mc inxi
```
