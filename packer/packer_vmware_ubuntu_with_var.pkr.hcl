packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

# variables

variable "vcenter_username" {
  type    = string
  description = "The username for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "vcenter_password" {
  type    = string
  description = "The plaintext password for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "ssh_username" {
  type    = string
  description = "The username to use to authenticate over SSH."
  default = ""
  sensitive = true
}

variable "ssh_password" {
  type    = string
  description = "The plaintext password to use to authenticate over SSH."
  default = ""
  sensitive = true
}

# vSphere Objects

variable "vcenter_insecure_connection" {
  type    = bool
  description = "If true, does not validate the vCenter server's TLS certificate."
  default = true
}

variable "vcenter_server" {
  type    = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default = ""
}

variable "vcenter_datacenter" {
  type    = string
  description = "Required if there is more than one datacenter in vCenter."
  default = ""
}

variable "vcenter_host" {
  type = string
  description = "The ESXi host where target VM is created."
  default = ""
}

variable "vcenter_cluster" {
  type = string
  description = "The cluster where target VM is created."
  default = ""
}

variable "vcenter_datastore" {
  type    = string
  description = "Required for clusters, or if the target host has multiple datastores."
  default = ""
}

variable "vcenter_network" {
  type    = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default = ""
}

variable "vcenter_folder" {
  type    = string
  description = "The VM folder in which the VM template will be created."
  default = ""
}

# ISO Objects

variable "iso_path" {
  type    = string
  description = "The path on the source vSphere datastore for ISO images."
  default = ""
  }

#variable "iso_url" {
#  type    = string
#  description = "The url to retrieve the iso image"
#  default = ""
# }

variable "iso_file" {
  type = string
  description = "The file name of the guest operating system ISO image installation media."
  default = ""
}

variable "iso_checksum" {
  type    = string
  description = "The checksum of the ISO image."
  default = ""
}

variable "iso_checksum_type" {
  type    = string
  description = "The checksum type of the ISO image. Ex: sha256"
  default = ""
}

source "vsphere-iso" "ubuntu_24-04" {
  vcenter_server      = "vcenter01.virtshinobi.local"
  username            = "administrator@vsphere.local"
  password            = "Password@123"
  cluster             = "Cluster-01"
  datacenter          = "Datacenter-01"
  folder              = "Templates"
  datastore           = "iSCSI_DS02"
  host                = "esxi01.virtshinobi.local"
  insecure_connection = "true"

  vm_name              = "ubunty_tmpl_Packer"
  ssh_password         = "Password@123"
  ssh_username       = "ubuntu"
  CPUs                 = "2"
  RAM                  = "2048"
  RAM_reserve_all      = true
  communicator         = "ssh"
  disk_controller_type = ["lsilogic-sas"]
  firmware             = "bios"
  #floppy_files         = ["setup/w2k19/autounattend.xml", "setup/setup.ps1", "setup/winrmConfig.bat", "setup/vmtools.cmd"]
  guest_os_type        = "ubuntu64Guest"
  iso_paths            = ["[NFS_ISO] ubuntu-24.04.2-live-server-amd64.iso"]
  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }

  storage {
    disk_size             = "32768"
    disk_thin_provisioned = true
  }

  convert_to_template = "true"
}

build {
  sources = ["source.vsphere-iso.ubuntu_24-04"]

  provisioner "shell" {
    inline = ["sudo apt update && sudo apt upgrade -y && sudo apt install openvmware-tools"]
  }
}