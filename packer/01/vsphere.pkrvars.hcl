
#    DESCRIPTION: 
#    This file defines VMaware vcenter variables used by the source blocks.

# vcenter Credentials
vcenter_server              = "vcenter01.virtshinobi.local"
vcenter_username            = "administrator@vsphere.local"
vcenter_password            = "Password@123"
vcenter_insecure_connection = true

# vcenter Settings
vcenter_datacenter = "Datacenter-01"
vcenter_cluster    = "Cluster-01"
vcenter_datastore  = "iSCSI_DS02"
vcenter_network    = "VM Network"
vcenter_folder     = "Templates/Packer"

# ISO Paths
vcenter_iso_path   = "[NFS_ISO] ubuntu-24.04.2-live-server-amd64.iso"]


# Virtual Machine Settings
#vcenter_vm_version           = 19
#vcenter_tools_upgrade_policy = true
#vcenter_remove_cdrom         = true


// Boot and Provisioning Settings
##vcenter_http_port_min    = 8000
#vcenter_http_port_max    = 8099
#vcenter_ip_wait_timeout  = "20m"
#vcenter_shutdown_timeout = "15m"

// Template and Content Library Settings
#vcenter_template_conversion = true
# vcenter_content_library_name    = "sfo-w01-lib01"
# vcenter_content_library_ovf     = true
# vcenter_content_library_destroy = true