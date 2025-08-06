packer {
  required_plugins {
    vsphere = {
      version = "~> 1"
      source  = "github.com/hashicorp/vsphere"
    }
  }
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
  guest_os_type        = "ubuntuGuest"
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