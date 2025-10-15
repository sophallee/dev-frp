#!/bin/bash
export LC_ALL=C

# Load properties file
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
properties_file="$script_dir/frp.properties"

if [ ! -f "$properties_file" ]; then
    echo "Error: Properties file $properties_file not found!"
    exit 1
fi

source "$properties_file"

echo "Building FRP version: $frp_version Release: $frp_release"

# Install build dependencies
sudo dnf install -y rpm-build golang git make redhat-rpm-config

# Setup RPM build directories
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

# Copy spec files
cp frps.spec ~/rpmbuild/SPECS/
cp frpc.spec ~/rpmbuild/SPECS/

# Download FRP source
cd ~/rpmbuild/SOURCES
git clone https://github.com/fatedier/frp.git frp-src
cd frp-src
git checkout v${frp_version}   # Use version from properties

# Build binaries with debug symbols
mkdir -p bin
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frps ./cmd/frps
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frpc ./cmd/frpc

cd ..
# Create tarballs for RPMs
tar -czf frps-${frp_version}.tar.gz frp-src
cp frps-${frp_version}.tar.gz frpc-${frp_version}.tar.gz

# Build RPMs
cd ~/rpmbuild/SPECS

rpmbuild -ba --define "version ${frp_version}" --define "release ${frp_release}" frps.spec
rpmbuild -ba --define "version ${frp_version}" --define "release ${frp_release}" frpc.spec

echo "Build complete! RPMs located in: ~/rpmbuild/RPMS/x86_64/"