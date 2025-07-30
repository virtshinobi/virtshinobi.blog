packer {
  required_plugins {
    vsphere = {
      version = ">=1.0.0"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "ubuntu_template" {
  vcenter_server      = "vcenter01.virtshinobi.local"
  username            = "administrator@vsphere.local"
  password            = "your-password"
  datacenter          = "Datacenter-01"
  cluster             = "Cluster-01"
  datastore           = "NFS_ISO"
  iso_url             = "https://mirror.ajl.albony.in/ubuntu-releases/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"
  iso_checksum        = "SHA256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
  ssh_username        = "packer"
  ssh_password        = "secret"
  ssh_timeout         = "30m"
}

build {
  sources = ["source.vsphere-iso.ubuntu_template"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y open-vm-tools"
    ]
  }

  post-processor "vsphere-template" {
    template_name = "ubuntu-golden-template"
  }
}