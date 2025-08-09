###############################################################################
# PACKER CONFIGURATION
###############################################################################
# This block configures Packer itself, including required plugins
# The vSphere plugin is needed to build VMs on vSphere infrastructure
###############################################################################
123packer {
  required_plugins {
    vsphere = {
      version = ">= v1.2.0"                    # Minimum required version of the vSphere plugin
      source  = "github.com/hashicorp/vsphere" # Source location of the plugin
    }
  }
}

###############################################################################
# LOCALS CONFIGURATION
###############################################################################
# Local variables used within the template
###############################################################################

locals {
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp()) # Format current timestamp for template notes
}

###############################################################################
# SOURCE DEFINITION
###############################################################################
# This block defines the source VM configuration for vSphere
# It includes all the settings for the VM that will be created
###############################################################################

source "vsphere-iso" "ubuntu-2404" {
  # vCenter connection settings
  vcenter_server      = "vcenter01.virtshinobi.local" # vCenter server address
  username            = "administrator@vsphere.local"
  password            = "Password@123"             # vCenter password
  datacenter          = "Datacenter-01"            # vCenter datacenter
  datastore           = "Packer_DS01"              # Datastore for VM files
  host                = "10.100.1.23"              # ESXi host
  cluster             = "Cluster-01"               # Cluster name
  folder              = "Templates/Packer"         # VM folder
  insecure_connection = "true"                     # Skip SSL verification

  # VM conversion settings
  tools_upgrade_policy = true       # Upgrade VMware tools during customization
  remove_cdrom         = true       # Remove CD-ROM after build
  convert_to_template  = true       # Convert to template after build

  # VM hardware settings
  guest_os_type        = "ubuntu64Guest"                                               # Guest OS type
  vm_version           = "21"                                                          # VM hardware version
  notes                = "Ubuntu 24.04 Template built by Packer on ${local.buildtime}" # VM notes
  vm_name              = "Ubuntu-2204-Packer"                                          # VM name
  firmware             = "efi"                                                         # VM firmware type
  CPUs                 = "1"                                                           # CPU sockets
  cpu_cores            = "2"                                                           # CPU cores per socket
  CPU_hot_plug         = false                                                         # Disable CPU hot-plug
  RAM                  = "2048"                                                        # VM memory
  RAM_hot_plug         = false                                                         # Disable memory hot-plug
  cdrom_type           = "sata"                                                        # CD-ROM type
  disk_controller_type = ["pvscsi"]                                                    # Disk controller type

  # Disk configuration
  storage {
    disk_size             = "32768"         # Disk size
    disk_controller_index = 0               # Controller index
    disk_thin_provisioned = "true"          # Thin provisioning
    disk_eagerly_scrub    = "false"         # Eager zero scrubbing
  }

  # Network configuration
  network_adapters {
    network      = "VM Network"     # Network name
    network_card = "vmxnet3"        # Network card type
  }

  # Installation media
  #iso_url      = var.iso_url                                    # ISO URL
  #iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}" # ISO checksum
  iso_paths = ["[NFS_ISO] ubuntu-24.04.2-live-server-amd64.iso"]

  # Cloud-init configuration via CD-ROM
  # This creates a secondary CD-ROM with cloud-init data
  cd_files = [
    "./httpd/meta-data",     # Cloud-init metadata
    "./httpd/user-data"      # Cloud-init user data
  ]
  cd_label = "cidata"        # Label for cloud-init CD-ROM

  # Boot configuration
  boot_order = "disk,cdrom"  # Boot order
  boot_wait  = "10s"         # Wait time before boot commands

  # Boot commands for Ubuntu 24.04 automated installation
  # These commands trigger the automated installation process
  boot_command = [
    "<esc><wait>",                                                     # Press ESC to access GRUB menu
    "c<wait>",                                                         # Enter GRUB command line
    "linux /casper/vmlinuz quiet autoinstall ds=nocloud<enter><wait>", # Load Linux kernel with autoinstall
    "initrd /casper/initrd<enter><wait>",                              # Load initial ramdisk
    "boot<enter>"                                                      # Boot the system
  ]

  # SSH and timeout settings
  ip_wait_timeout        = "40m"                                              # Time to wait for IP assignment
  ssh_password           = "Password@123"                                     # SSH password
  ssh_username           = "ubuntu"                                           # SSH username
  ssh_port               = 22                                                 # SSH port
  ssh_timeout            = "50m"                                              # SSH connection timeout
  ssh_handshake_attempts = "1000"                                             # SSH handshake attempts
  shutdown_command       = "echo 'Password@123' | sudo -S -E shutdown -P now" # Shutdown command
  shutdown_timeout       = "50m"                                              # Shutdown timeout
}

###############################################################################
# BUILD CONFIGURATION
###############################################################################
# This block defines the build process, including the source VM
# and provisioners that run scripts to configure the VM
###############################################################################

build {
  # Use the ubuntu-2404 source defined above
  sources = ["source.vsphere-iso.ubuntu-2404"]

  ###############################################################################
  # STAGE 1: POST-INSTALLATION VM TOOLS CONFIGURATION
  ###############################################################################
  # This provisioner waits for cloud-init to finish and configures VMware tools
  provisioner "shell" {
    inline = [
      # Wait for cloud-init to complete
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "echo 'Cloud-init finished...'",

      # Configure VMware tools
      "sudo systemctl enable open-vm-tools", # Enable VMware tools on boot
      "sudo systemctl start open-vm-tools",  # Start VMware tools

      # Clean up cloud-init
      "sudo cloud-init clean", # Clean cloud-init

      # Remove networking configs that might interfere with template
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",

      # Add custom issue message
      "echo 'Ubuntu 24.04 Template by Packer - Creation Date: $(date)' | sudo tee /etc/issue"
    ]
  }

  ###############################################################################
  # SYSTEM CLEANUP
  ###############################################################################
  # This provisioner cleans up the system to reduce template size
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up...'",

      # Remove unnecessary packages
      "sudo apt-get autoremove -y",

      # Clean package cache
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -f /var/cache/apt/archives/*.deb",
      "sudo rm -f /var/cache/apt/archives/partial/*.deb",
      "sudo rm -f /var/cache/apt/*.bin",

      # Clean cloud-init
      "sudo cloud-init clean"
    ]
  }

  ###############################################################################
  # TEMPLATE PREPARATION
  ###############################################################################
  # This provisioner prepares the VM for conversion to a template
  provisioner "shell" {
    inline = [
      "echo 'Preparing for template conversion...'",

      # Reset machine-id to ensure unique ID on clone
      "sudo rm -f /etc/machine-id",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo rm -f /var/lib/dbus/machine-id",
      "sudo ln -s /etc/machine-id /var/lib/dbus/machine-id",

      # Remove SSH host keys so they're regenerated on first boot
      "sudo rm -f /etc/ssh/ssh_host_*",

      # Configure SSH to regenerate host keys on first boot
      "sudo mkdir -p /etc/systemd/system/ssh.service.d/",
      "echo '[Service]' | sudo tee /etc/systemd/system/ssh.service.d/regenerate_ssh_host_keys.conf",
      "echo 'ExecStartPre=/bin/sh -c \"if [ -e /dev/zero ]; then rm -f /etc/ssh/ssh_host_* && ssh-keygen -A; fi\"' | sudo tee -a /etc/systemd/system/ssh.service.d/regenerate_ssh_host_keys.conf",

      # Configure faster boot
      "echo 'Setting disk as boot device...'",
      "sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub",
      "sudo update-grub",

      # Final cloud-init cleanup for fresh start
      "echo 'Clearing cloud-init status to ensure fresh start on first boot...'",
      "sudo cloud-init clean --logs",

      "echo 'Installation and cleanup completed successfully!'"
    ]
  }
}