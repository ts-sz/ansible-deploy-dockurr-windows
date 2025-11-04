# Dockurr Windows Deployment

Automated Ansible playbook for deploying [Dockurr Windows](https://github.com/dockur/windows) - Windows inside a Docker container with KVM acceleration.

## 📋 Overview

This project provides an interactive Ansible playbook that deploys a Windows container using Docker Compose with macvlan networking. The playbook automatically configures networking, creates necessary directories, and deploys the container with customizable settings.

## 🎯 Features

- **Interactive Configuration**: Prompts for all configuration options with sensible defaults
- **Automatic Network Detection**: Extracts subnet and gateway from the target host's network interface
- **Macvlan Networking**: Provides the container with its own IP address on your network
- **Customizable Resources**: Configure CPU cores, RAM, disk size, and more
- **Localization Support**: Set timezone, language, region, and keyboard layout
- **USB Device Passthrough**: Optional QEMU arguments for USB device passthrough
- **Auto-generated Password**: Secure password generation for Windows user
- **OEM Customization**: Run custom scripts after Windows installation
- **Manual Installation**: Optional manual Windows installation mode

## 📦 Prerequisites

### On Control Node (where you run Ansible)

- Ansible 2.9 or higher
- Required Ansible collections:
  ```bash
  ansible-galaxy collection install community.docker
  ansible-galaxy collection install ansible.utils
  ```

### On Target Host

- Docker Engine with Compose v2
- KVM support (`/dev/kvm` device)
- Network interface for macvlan networking
- SSH access with root privileges or sudo

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dockurr_windows
   ```

2. **Run the playbook**
   ```bash
   ansible-playbook ansible-playbook.yml
   ```

3. **Follow the interactive prompts**
   - Enter target host IP/hostname
   - Configure network settings
   - Set Windows version (10 or 11)
   - Configure hardware resources
   - Set localization preferences

4. **Access Windows**
   - Web interface: `http://<container-ip>:8006`
   - RDP: `<container-ip>:3389`

## 🤖 Non-Interactive Deployment

For automated deployments without interactive prompts, use the answers file:

1. **Create or edit the answers file**
   ```bash
   cp ansible-answers.yml.example ansible-answers.yml
   # Edit ansible-answers.yml with your configuration
   ```

2. **Run the playbook with the answers file**
   ```bash
   ansible-playbook ansible-playbook.yml -e @ansible-answers.yml
   ```

3. **Example answers file** (`ansible-answers.yml`):
   ```yaml
   ---
   working_host: "192.168.1.100"
   dockurr_windows_network_interface: "eth0"
   dockurr_windows_ip: "192.168.1.199"
   dockurr_windows_version: "11"
   dockurr_windows_stop_grace_period: "2m"
   dockurr_windows_disk_size: "64G"
   dockurr_windows_ram_size: "8G"
   dockurr_windows_cpu_cores: "4"
   dockurr_windows_username: "sysadmin"
   dockurr_windows_timezone: "Europe/Paris"
   dockurr_windows_language: "English"
   dockurr_windows_region: "en-US"
   dockurr_windows_keyboard: "en-US"
   ```

**Note**: When using the answers file, all `vars_prompt` values are provided via the `-e` flag, bypassing interactive prompts. See the included `ansible-answers.yml.example` for all available options.

## ⚙️ Configuration Options

### Network Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| Network Interface | Host network interface for macvlan | `eth0` |
| Container IP | Static IP address for the container | `192.168.1.199` |
| Subnet | Auto-detected from host interface | - |
| Gateway | Auto-detected from host default gateway | - |

### System Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| Windows Version | Windows version (10, 11) | `11` |
| Stop Grace Period | Time to wait before force-stopping | `2m` |

### Hardware Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| Disk Size | Virtual disk size | `64G` |
| RAM Size | Memory allocation | `8G` |
| CPU Cores | Number of CPU cores | `4` |

### User Credentials

| Parameter | Description | Default |
|-----------|-------------|---------|
| Username | Windows username | `sysadmin` |
| Password | Auto-generated and stored in `/tmp/dockurr_windows_password.txt` | - |

### Localization Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| Timezone | System timezone | `Europe/Paris` |
| Language | Display language | `English` |
| Region | Regional format | `en-US` |
| Keyboard | Keyboard layout | `en-US` |

### Advanced Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| QEMU Arguments | Additional QEMU arguments (e.g., USB passthrough) | `null` |
| Manual Installation | Set to `Y` to perform manual Windows installation | Not set (automatic) |

## 📁 Project Structure

```
.
├── ansible-playbook.yml       # Main Ansible playbook
├── ansible-answers.yml.example # Example answers file for non-interactive deployment
├── compose.yml.j2             # Docker Compose template
├── dot_env.tmpl               # Example .env file
├── oem/                       # OEM customization scripts
│   ├── install.bat            # Main installation script
│   ├── chocopacks.ps1         # Chocolatey package installer
│   ├── packages-default.choco.config # Chocolatey packages list
│   └── *.ps1                  # Various Windows customization scripts
├── README.md                  # This file
└── .gitignore                # Git ignore rules
```

## 🔧 Customization

### Modifying Default Values

Edit the `vars_prompt` section in `ansible-playbook.yml` to change default values:

```yaml
vars_prompt:
  - name: dockurr_windows_ram_size
    prompt: "Enter RAM size (e.g., 4G, 8G, 16G)"
    private: false
    default: 8G  # Change this
```

### Changing Deployment Location

Modify the `dockurr_windows_remote_dst` variable in the playbook:

```yaml
vars:
  dockurr_windows_remote_dst: /srv/dockers/web/dockurr_windows  # Change this path
```

### Custom SSH Port

The playbook uses SSH port `34522` by default. Change it in the `vars` section:

```yaml
vars:
  ansible_port: 34522  # Change this
```

### Manual Installation

By default, Windows installation is automatic. To perform a manual installation, set the `MANUAL` environment variable:

```yaml
environment:
  MANUAL: "Y"
```

**Note**: It's recommended to stick to the automatic installation, as it adjusts various settings to prevent common issues when running Windows inside a virtual environment. Use manual installation at your own risk.

### OEM Customization Scripts

The `oem/` folder contains scripts that run after Windows installation completes. The playbook automatically copies this folder to the container, where it will be mounted at `C:\OEM`.

**How it works:**

1. The `oem/` folder is copied to the container during deployment
2. During Windows installation, the folder is mounted at `C:\OEM`
3. The `install.bat` script is executed automatically after installation completes
4. `install.bat` runs all PowerShell scripts in sequence to customize Windows

**Included customization scripts:**

- `remove-default-apps-v2.ps1` - Removes unwanted Windows apps
- `disable-telemetry.ps1` - Disables Windows telemetry
- `disable-cortana.ps1` - Disables Cortana
- `disable-xbox.ps1` - Disables Xbox features
- `chocopacks.ps1` - Installs Chocolatey packages from `.choco.config` files
- And many more customization scripts...

**Adding your own scripts:**

1. Place your custom scripts in the `oem/` folder
2. Edit `oem/install.bat` to include your script in the execution sequence
3. Redeploy the playbook to copy the updated folder

**Example - Adding software installation:**

Create a file `oem/packages-custom.choco.config`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="googlechrome" />
  <package id="vscode" />
  <package id="git" />
</packages>
```

The `chocopacks.ps1` script will automatically detect and install packages from all `.choco.config` files in the folder.

## 🌐 Networking

This deployment uses **macvlan** networking, which gives the container its own IP address on your network. This allows:

- Direct network access to the Windows container
- No port mapping conflicts
- Better performance compared to bridge networking

**Important**: The host machine cannot directly communicate with macvlan containers. Use another machine on the network to access the container.

## 🔒 Security Notes

- The Windows password is auto-generated and stored in `/tmp/dockurr_windows_password.txt` on the control node
- Change the default username and password after first login
- Consider using Ansible Vault for sensitive variables in production
- The container has access to `/dev/kvm` and USB devices - ensure proper host security

## 📊 Deployment Process

The playbook performs the following steps:

1. Prompts for target host and configuration
2. Gathers network facts from the target host
3. Creates deployment directories (`/srv/dockers/web/dockurr_windows<version>/`)
4. Copies OEM customization folder to the deployment directory
5. Creates example files in the shared folder
6. Generates `.env` file with configuration
7. Deploys `compose.yml` from template
8. Starts the Windows container with Docker Compose
9. Windows installs automatically and runs OEM scripts at the end

## 📚 Additional Resources

- [Dockurr Windows GitHub](https://github.com/dockur/windows)
- [Docker Macvlan Documentation](https://docs.docker.com/network/macvlan/)
- [Ansible Documentation](https://docs.ansible.com/)

## 📝 License

This project is provided as-is for deploying Dockurr Windows. Refer to the [Dockurr Windows license](https://github.com/dockur/windows/blob/master/LICENSE) for the container image licensing.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## ⚠️ Disclaimer

This project deploys Windows in a container. Ensure you have proper licensing for Windows. This tool is for educational and development purposes.
