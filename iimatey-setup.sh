#!/usr/bin/env bash
set -x
set -e

# What Architecture (Go release-asset convention: amd64/arm64, regardless
# of host OS — Linux reports aarch64 for what Go/GitHub releases call arm64)
case $(uname -m) in
  arm64|aarch64)
    export ARCH=arm64
    ;;
  amd64|x86_64)
    export ARCH=amd64
    ;;
  *)
    echo "ERROR: unrecognized architecture '$(uname -m)' — don't know which release asset to fetch" >&2
    exit 1
    ;;
esac

# uname -s is portable (Linux/Darwin both support it); uname -o is a
# GNU/Linux-only extension and doesn't exist on macOS, so it can never
# detect Darwin.
case $(uname -s) in
  Linux)
    export OS=linux
    # lsb_release -is (short, ID-only) if present, else fall back to
    # /etc/os-release's ID. Plain `lsb_release -i` prints "Distributor ID:
    # <name>", which never matches a bare-word case pattern.
    if command -v lsb_release >/dev/null 2>&1; then
      DISTRO=$(lsb_release -is)
    elif [[ -f /etc/os-release ]]; then
      DISTRO=$(. /etc/os-release && echo "$ID")
    else
      DISTRO=""
    fi
    case $DISTRO in
      Bluefin|bluefin)
        brew install ttyd tmux curl
      ;;
      Ubuntu|ubuntu)
        sudo apt-get update
        sudo apt-get install -y ttyd tmux curl
      ;;
      Debian|debian)
        sudo apt-get update
        sudo apt-get install -y ttyd tmux curl
      ;;
      *)
        echo "NOTE: unrecognized distro '$DISTRO' — install ttyd, tmux, and curl yourself if they're missing" >&2
      ;;
    esac
    ;;
  Darwin)
    brew install ttyd tmux curl
    export OS=darwin
    ;;
  *)
    echo "ERROR: unrecognized OS '$(uname -s)'" >&2
    exit 1
    ;;
esac

# Install tunnel from github release
TUNNEL_RELEASE=v0.1.19-sharing
TUNNEL_URL=https://github.com/ii/wgtunnel/releases/download/$TUNNEL_RELEASE/tunnel-$OS-$ARCH
sudo curl -fL -o /usr/local/bin/tunnel $TUNNEL_URL
sudo chmod 0755 /usr/local/bin/tunnel # make executeable

# Install ttyc (depau/ttyc, GPLv3) from github release — the terminal CLIENT
# for connecting to a ttyd/iimatey URL without a browser. Used by
# `iimatey https://...` (see iimatey script). Prebuilt binary, no build step
# needed on our end.
TTYC_RELEASE=ttyc-v0.4
TTYC_URL=https://github.com/depau/ttyc/releases/download/$TTYC_RELEASE/$TTYC_RELEASE-$OS-$ARCH
sudo curl -fL -o /usr/local/bin/ttyc $TTYC_URL
sudo chmod 0755 /usr/local/bin/ttyc # make executeable

# WHAT WE NEED
tmux -V
ttyd --version
/usr/local/bin/tunnel -V
/usr/local/bin/ttyc --version
echo $PATH | grep /usr/local/bin >/dev/null || echo "You may want to add /usr/local/bin to your PATH"

# Install iimatey script from github
sudo curl -fo /usr/local/bin/iimatey -L https://raw.githubusercontent.com/ii/matey/canon/iimatey
sudo chmod +x /usr/local/bin/iimatey
