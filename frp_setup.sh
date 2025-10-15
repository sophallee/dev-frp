#!/bin/bash
script_file=$(basename "$0")
script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")
script_name=$(echo $script_file | cut -d. -f 1)
cd $script_dir

software_dir="$script_dir/software"

software_dir="$script_dir/software"

# Function to detect OS version
detect_os_version() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$VERSION_ID" == 10* ]]; then
            echo "el10"
        elif [[ "$VERSION_ID" == 9* ]]; then
            echo "el9"
        elif [[ "$VERSION_ID" == 8* ]]; then
            echo "el8"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

# Function to install FRP
install_frp() {
    local role=$1
    local os_version=$(detect_os_version)
    
    if [ "$os_version" = "unknown" ]; then
        echo "Error: Unsupported OS version. Only EL8, EL9, and EL10 are supported."
        exit 1
    fi
    
    local package_file=""
    
    if [ "$role" = "server" ]; then
        package_file="frps-0.60.0-1.${os_version}.x86_64.rpm"
    elif [ "$role" = "client" ]; then
        package_file="frpc-0.60.0-1.${os_version}.x86_64.rpm"
    else
        echo "Error: Invalid role. Use 'server' or 'client'"
        exit 1
    fi
    
    local package_path="$software_dir/$package_file"
    
    if [ ! -f "$package_path" ]; then
        echo "Error: Package file $package_file not found in $software_dir"
        echo "Available packages:"
        ls -1 "$software_dir/"*.rpm 2>/dev/null || echo "No RPM packages found"
        
        exit 1
    fi
    
    echo "Installing FRP $role for $os_version..."
    
    # Check if already installed
    if [ "$role" = "server" ]; then
        if rpm -q frps &>/dev/null; then
            echo "FRP server is already installed. Updating..."
            sudo rpm -Uvh "$package_path"
        else
            sudo rpm -ivh "$package_path"
        fi
    else
        if rpm -q frpc &>/dev/null; then
            echo "FRP client is already installed. Updating..."
            sudo rpm -Uvh "$package_path"
        else
            sudo rpm -ivh "$package_path"
        fi
    fi
    
    if [ $? -eq 0 ]; then
        echo "FRP $role installed successfully!"
        
        # Show service status if available
        if [ "$role" = "server" ]; then
            if systemctl is-active --quiet frps 2>/dev/null; then
                echo "FRP server service is running"
            elif systemctl is-enabled --quiet frps 2>/dev/null; then
                echo "FRP server service is installed but not running"
            fi
        else
            if systemctl is-active --quiet frpc 2>/dev/null; then
                echo "FRP client service is running"
            elif systemctl is-enabled --quiet frpc 2>/dev/null; then
                echo "FRP client service is installed but not running"
            fi
        fi
    else
        echo "Error: Failed to install FRP $role"
        exit 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [--install-server | --install-client | --help]"
    echo ""
    echo "Options:"
    echo "  --install-server    Install FRP server"
    echo "  --install-client    Install FRP client"
    echo "  --help             Show this help message"
    echo ""
    local current_os=$(detect_os_version)
    echo "Detected OS version: $current_os"
    echo "Supported OS versions: EL8, EL9, EL10"
    echo ""
    echo "Available packages in software directory:"
    ls -1 "$software_dir/"*.rpm 2>/dev/null || echo "No RPM packages found"
    
    # Show expected package names for current OS
    if [ "$current_os" != "unknown" ]; then
        echo ""
        echo "Expected package names for $current_os:"
        echo "  Server: frps-0.60.0-1.${current_os}.x86_64.rpm"
        echo "  Client: frpc-0.60.0-1.${current_os}.x86_64.rpm"
    fi
}

# Main script logic
case "${1:-}" in
    --install-server)
        install_frp "server"
        ;;
    --install-client)
        install_frp "client"
        ;;
    --help|-h|"")
        show_usage
        ;;
    *)
        echo "Error: Unknown option '$1'"
        show_usage
        exit 1
        ;;
esac