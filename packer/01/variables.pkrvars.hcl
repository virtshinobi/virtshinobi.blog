
#    DESCRIPTION: 
#    This file defines VMaware vcenter variables used by the source blocks.

# vcenter Credentials
vcenter_server              = "vcenter01.virtshinobi.local"
vcenter_username            = "administrator@vcenter.local"
vcenter_password            = "Password@123"
vcenter_insecure_connection = true

# vcenter Settings
vcenter_datacenter = "Datacenter-01"
vcenter_cluster    = "Cluster-01"
vcenter_datastore  = "iSCSI_DS02"
vcenter_network    = "Management-VL11"
vcenter_folder     = "Templates/Packer"


# Virtual Machine Settings
vcenter_vm_version           = 19
vcenter_tools_upgrade_policy = true
vcenter_remove_cdrom         = true

// Removable Media Settings
# vcenter_iso_datastore = "sfo-w01-cl01-ds-nfs01"
# vcenter_iso_path      = "iso"
vcenter_iso_hash = "sha512"

// Boot and Provisioning Settings
vcenter_http_port_min    = 8000
vcenter_http_port_max    = 8099
vcenter_ip_wait_timeout  = "20m"
vcenter_shutdown_timeout = "15m"

// Template and Content Library Settings
vcenter_template_conversion = true
# vcenter_content_library_name    = "sfo-w01-lib01"
# vcenter_content_library_ovf     = true
# vcenter_content_library_destroy = true