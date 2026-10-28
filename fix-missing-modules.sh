#!/usr/bin/env bash
# fix-missing-modules.sh
# Adds the firewall/VM/container/filesystem/USB modules that the driver-trimming
# step left out of an already-built -imac18 kernel, then rebuilds ONLY what
# changed (much faster than a full rebuild) and reinstalls it.
#
# Fixes: "Error starting network 'default' ... python-nftables failed ...
#         Could not process rule: No such file or directory"
#
# Usage: ./fix-missing-modules.sh            (run as your normal user, on the iMac)
# Needs kernel-extras.inc.sh in the same folder.

set -euo pipefail
trap 'rc=$?; printf "\n\033[1;31mERROR: script stopped at line %s (exit code %s).\033[0m\n" "$LINENO" "$rc" >&2' ERR

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() { printf '\n\033[1;31mERROR: %s\033[0m\n' "$*" >&2; exit 1; }

HERE="$(cd "$(dirname "$0")" && pwd)"
[[ -f "$HERE/kernel-extras.inc.sh" ]] || die "kernel-extras.inc.sh must be in the same folder as this script."
# shellcheck source=kernel-extras.inc.sh
source "$HERE/kernel-extras.inc.sh"

[[ $EUID -ne 0 ]] || die "Run as your normal user; the script calls sudo when it needs to."

# Find the build folder
SRC=""
for d in "$HOME"/imac-kernel/linux-*/; do
  [[ -f "$d/.config" ]] && grep -q 'CONFIG_LOCALVERSION="-imac18"' "$d/.config" && SRC="${d%/}"
done
[[ -n "$SRC" ]] || die "Couldn't find the -imac18 build folder under ~/imac-kernel."
cd "$SRC"
say "Using build folder: $SRC"

say "Your password is needed once now"
sudo -v
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
KEEPALIVE=$!
trap 'kill "$KEEPALIVE" 2>/dev/null || true' EXIT

say "Adding desktop modules (firewall/NAT, VMs, containers, filesystems, USB)"
cp .config .config.before-extras
apply_desktop_extras
make olddefconfig >/dev/null
echo "Config options changed: $(diff .config.before-extras .config | grep -c '^>' || true)"

say "Rebuilding only what changed"
make -j"$(nproc)"

KREL="$(make -s kernelrelease)"
say "Reinstalling $KREL"
sudo make modules_install
sudo make install
sudo depmod -a "$KREL"

say "Done"
cat <<EOF

Reboot into $KREL, then check:
  sudo virsh net-start default      # or just reopen virt-manager
  sudo firewall-cmd --state         # should print: running
EOF
