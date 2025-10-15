Name:           frps
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        FRP Server (frps)

License:        MIT
URL:            https://github.com/fatedier/frp
Source0:        %{name}-%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  golang, make

# Uncomment the following line if you want to skip debuginfo
# %global debug_package %{nil}

%description
FRP Server (frps) allows exposing local services behind NAT/firewall.

%prep
%setup -q -n frp-src

%build
mkdir -p bin
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frps ./cmd/frps

%install
mkdir -p %{buildroot}/usr/local/bin
cp bin/frps %{buildroot}/usr/local/bin/

mkdir -p %{buildroot}/usr/share/doc/%{name}
cp README.md %{buildroot}/usr/share/doc/%{name}/

%files
/usr/local/bin/frps
/usr/share/doc/%{name}/README.md

%changelog
* Sun Oct 13 2025 Sophal Lee <sophal.lee@live.com> - %{version}-%{release}
- Initial frps RPM