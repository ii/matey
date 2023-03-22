#!/usr/bin/env bash
set -x
set -e

case $(uname -o) in
  GNU/Linux)
    sudo apt-get update
    sudo apt-get install -y ttyd tmux wireguard-tools curl
    export OS=linux
  ;;
  Darwin)
    brew install ttyd tmux wireguard-tools curl
    export OS=darwin
  ;;
esac
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

# ## TODO: publish tunnel client binaries
# Othewise we need to build tunnel... we will download go into /tmp, compile, and delete go
# WARNING WE WILL OVER WRITE THE VERSION OF GO in /usr/local/go
GO_VERSION=1.20.2

export GO_TMP_DIR=$(mktemp -d)
# Ensure tunnel binary exists
curl -sSL https://dl.google.com/go/go${GO_VERSION}.${OS}-${ARCH}.tar.gz \
    | gunzip -d \
    | tar --directory $GO_TMP_DIR --extract

# GO
export PATH=$GO_TMP_DIR/go/bin:$PATH
go install github.com/coder/wgtunnel/cmd/tunnel@v0.1.5
# Move generated tunnel go binary to /usr/local/bin
# Not sure where we should put it, for now to /usr/local/bin/tunnel
sudo mv $HOME/go/bin/tunnel /usr/local/bin/tunnel
rm -rf $GO_TMP_DIR

# WHAT WE NEED
tmux -V
ttyd --version
wg version
/usr/local/bin/tunnel --version
echo $PATH | grep /usr/local/bin > /dev/null || echo "You may want to add /usr/local/bin to your PATH"

sudo curl -o /usr/local/bin/iimatey -L https://raw.githubusercontent.com/ii/matey/canon/iimatey
sudo chmod +x /usr/local/bin/iimatey
