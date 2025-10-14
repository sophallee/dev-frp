#!/bin/bash
export LC_ALL=C
# Install build dependencies
sudo dnf install -y rpm-build golang git make redhat-rpm-config

# Setup RPM build directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# Copy spec files
cp frps.spec ~/rpmbuild/SPECS
cp frpc.spec ~/rpmbuild/SPECS

# Download FRP source
cd ~/rpmbuild/SOURCES
git clone https://github.com/fatedier/frp.git frp-src
cd frp-src
git checkout v0.60.0   # latest stable release

# Build binaries with debug symbols
mkdir -p bin
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frps ./cmd/frps
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frpc ./cmd/frpc

cd ..
# Create tarballs for RPMs
tar -czf frps-0.60.0.tar.gz frp-src
cp frps-0.60.0.tar.gz frpc-0.60.0.tar.gz

# Build RPMs
cd ~/rpmbuild/SPECS

rpmbuild -ba frps.spec
rpmbuild -ba frpc.spec