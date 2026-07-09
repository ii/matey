#!/usr/bin/env bash
set -x
set -e

# What Architecture
case $(uname -m) in
  arm64)
    export ARCH=arm64
    ;;
  amd64)
    export ARCH=amd64
    ;;
  x86_64)
    export ARCH=amd64
    ;;
esac

case $(uname -o) in
  GNU/Linux)
    export OS=linux
    case $(lsb-release -i) in
      Bluefin)
        brew install ttyd tmux curl
      ;;
      Ubuntu)
        sudo apt-get update
        sudo apt-get install -y ttyd tmux curl
      ;;
      Debian)
        sudo apt-get update
        sudo apt-get install -y ttyd tmux curl
      ;;
    esac
    ;;
  Darwin)
    brew install ttyd tmux curl
    export OS=darwin
    ;;
esac

# Install tunnel from github release
TUNNEL_RELEASE=v0.1.19-sharing
TUNNEL_URL=https://github.com/ii/wgtunnel/releases/download/$TUNNEL_RELEASE/tunnel-$OS-$ARCH
sudo curl -L -o /usr/local/bin/tunnel $TUNNEL_URL
sudo chmod 0755 /usr/local/bin/tunnel # make executeable

# WHAT WE NEED
tmux -V
ttyd --version
/usr/local/bin/tunnel -V
echo $PATH | grep /usr/local/bin >/dev/null || echo "You may want to add /usr/local/bin to your PATH"

# Install iimatey script from github
sudo curl -o /usr/local/bin/iimatey -L https://raw.githubusercontent.com/ii/matey/canon/iimatey
sudo chmod +x /usr/local/bin/iimatey
