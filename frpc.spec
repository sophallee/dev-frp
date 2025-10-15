Name:           frpc
Version:        %{version}
Release:        %{release}%{?dist}
Summary:        FRP Client (frpc)

License:        MIT
URL:            https://github.com/fatedier/frp
Source0:        %{name}-%{version}.tar.gz
BuildArch:      x86_64
BuildRequires:  golang, make

# Uncomment to disable automatic debuginfo generation
# %global debug_package %{nil}

%description
FRP Client (frpc) allows connecting to FRP server for reverse proxying.

%prep
%setup -q -n frp-src

%build
mkdir -p bin
GOOS=linux GOARCH=amd64 go build -gcflags="all=-N -l" -o bin/frpc ./cmd/frpc

%install
mkdir -p %{buildroot}/usr/local/bin
cp bin/frpc %{buildroot}/usr/local/bin/

mkdir -p %{buildroot}/usr/share/doc/%{name}
cp README.md %{buildroot}/usr/share/doc/%{name}/

%files
/usr/local/bin/frpc
/usr/share/doc/%{name}/README.md

%changelog
* Sun Oct 13 2025 Sophal Lee <sophal.lee@live.com> - %{version}-%{release}
- Initial frpc RPM