# kernel-extras.inc.sh -- sourced by build-imac-kernel.sh and fix-missing-modules.sh
#
# localmodconfig only keeps drivers that were loaded at build time. These are
# features a Fedora desktop needs on demand (VMs, containers, firewall NAT,
# USB drives in other formats), so they are always forced back in.
# Must be run from inside the kernel source tree. Unknown symbols are harmless:
# `make olddefconfig` drops anything that doesn't exist in this kernel version.

apply_desktop_extras() {
  local C=scripts/config

  # --- Firewall / nftables (firewalld, libvirt 'default' network, podman, docker)
  $C --enable NETFILTER --enable NETFILTER_ADVANCED --enable NETFILTER_INGRESS
  $C --module NETFILTER_NETLINK --module NETFILTER_NETLINK_QUEUE --module NETFILTER_NETLINK_LOG
  $C --module NF_CONNTRACK --enable NF_CONNTRACK_MARK --enable NF_CONNTRACK_ZONES \
     --enable NF_CONNTRACK_EVENTS --module NF_CT_NETLINK
  $C --module NF_NAT --enable NF_NAT_MASQUERADE --enable NF_NAT_REDIRECT
  $C --module NF_TABLES --enable NF_TABLES_INET --enable NF_TABLES_NETDEV \
     --enable NF_TABLES_IPV4 --enable NF_TABLES_IPV6 --enable NF_TABLES_ARP \
     --module NF_TABLES_BRIDGE
  for m in NFT_CT NFT_NAT NFT_MASQ NFT_REDIR NFT_REJECT NFT_REJECT_INET \
           NFT_REJECT_IPV4 NFT_REJECT_IPV6 NFT_FIB NFT_FIB_INET NFT_FIB_IPV4 \
           NFT_FIB_IPV6 NFT_COMPAT NFT_LOG NFT_LIMIT NFT_QUOTA NFT_CONNLIMIT \
           NFT_NUMGEN NFT_HASH NFT_TPROXY NFT_SOCKET NFT_FLOW_OFFLOAD \
           NFT_BRIDGE_META NFT_BRIDGE_REJECT NF_FLOW_TABLE NF_FLOW_TABLE_INET \
           NF_REJECT_IPV4 NF_REJECT_IPV6 NF_DUP_IPV4 NF_DUP_IPV6; do
    $C --module "$m"
  done
  # iptables-nft compatibility (docker, older tools)
  $C --module NETFILTER_XTABLES --module IP_NF_IPTABLES --module IP_NF_FILTER \
     --module IP_NF_NAT --module IP_NF_TARGET_MASQUERADE --module IP_NF_MANGLE \
     --module IP6_NF_IPTABLES --module IP6_NF_FILTER --module IP6_NF_NAT \
     --module IP6_NF_TARGET_MASQUERADE --module IP6_NF_MANGLE
  for m in NETFILTER_XT_MARK NETFILTER_XT_CONNMARK NETFILTER_XT_TARGET_MASQUERADE \
           NETFILTER_XT_TARGET_CHECKSUM NETFILTER_XT_TARGET_REDIRECT \
           NETFILTER_XT_TARGET_LOG NETFILTER_XT_MATCH_ADDRTYPE \
           NETFILTER_XT_MATCH_CONNTRACK NETFILTER_XT_MATCH_COMMENT \
           NETFILTER_XT_MATCH_MULTIPORT NETFILTER_XT_MATCH_STATE \
           NETFILTER_XT_MATCH_MARK NETFILTER_XT_MATCH_LIMIT \
           NETFILTER_XT_MATCH_IPVS NETFILTER_XT_MATCH_STATISTIC; do
    $C --module "$m"
  done

  # --- Virtual machines (KVM / libvirt / GNOME Boxes)
  $C --module KVM --module KVM_INTEL
  $C --module VHOST_NET --module VHOST_VSOCK --module VSOCKETS
  $C --module TUN --module BRIDGE --module BRIDGE_NETFILTER --module VETH \
     --module MACVLAN --module MACVTAP --module DUMMY --module WIREGUARD
  $C --module VFIO --module VFIO_PCI

  # --- Containers (podman / toolbox / distrobox)
  $C --module OVERLAY_FS --enable USER_NS --enable CGROUP_BPF

  # --- Filesystems for USB drives, ISOs, network shares, other OSes
  $C --module VFAT_FS --module EXFAT_FS --module NTFS3_FS --module FAT_FS \
     --module HFSPLUS_FS --module HFS_FS --module ISO9660_FS --enable JOLIET \
     --module UDF_FS --module FUSE_FS --module CUSE --module CIFS --module NFS_FS \
     --module SQUASHFS --module BLK_DEV_LOOP --module BTRFS_FS --module XFS_FS
  $C --set-str FAT_DEFAULT_IOCHARSET "ascii" --module NLS_UTF8 \
     --module NLS_CODEPAGE_437 --module NLS_ISO8859_1

  # --- Common USB devices that are often unplugged at build time
  $C --module USB_STORAGE --module USB_UAS --module USB_VIDEO_CLASS \
     --module SND_USB_AUDIO --module USB_PRINTER --module USB_SERIAL \
     --module USB_SERIAL_FTDI_SIO --module USB_SERIAL_PL2303 \
     --module USB_SERIAL_CH341 --module USB_SERIAL_CP210X --module USB_ACM \
     --module USB_NET_DRIVERS --module USB_USBNET --module USB_NET_CDCETHER \
     --module USB_RTL8152 --module USB_NET_AX88179_178A --module HID_GENERIC \
     --module USB_HID --module HID_MULTITOUCH --module JOYSTICK_XPAD \
     --module HID_SONY --module HID_NINTENDO --module HID_LOGITECH \
     --module HID_LOGITECH_DJ --module HID_LOGITECH_HIDPP
}
