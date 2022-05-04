packer {
  required_version = ">= 1.8.0"
  required_plugins {
    vsphere = {
      version = ">= v1.0.3"
          source  = "github.com/hashicorp/vsphere"
    }
  }
  required_plugins {
    windows-update = {
      version = ">= 0.14.0"
          source  = "github.com/rgl/windows-update"
    }
  }
}

source "vsphere-iso" "Utrecht" {
  vcenter_server          = "${var.vcenterNL}"
  username                = "${var.vcenterUser}"
  password                = "${var.vcenterPass}"
  insecure_connection     = true
  
  vm_name                 = "Windows 10 (21H2)"
  vm_version              = 15
  guest_os_type           = "windows9_64Guest"

  CPUs                    = 2
  RAM                     = 8192
  RAM_reserve_all         = true
  cluster                 = "${var.cluster}"
  
  datastore               = "${var.datastoreNL}"
  folder                  = "${var.folder}"
  disk_controller_type    = ["pvscsi"]
  storage {
    disk_size             = 51200
    disk_thin_provisioned = true
  }
  floppy_files            = ["${path.root}/files/"]
  iso_paths               = ["[${var.datastoreISO}] en-gb_windows_10_business_editions_version_21h2_x64_dvd_71e6101d.iso", "[${var.datastoreISO}] VMware-tools-windows-12.0.0-19345655.iso"]
  remove_cdrom            = true

  network_adapters {
    network               = "${var.network}"
    network_card          = "vmxnet3"
  }

  video_ram               = 131072

  notes                   = "Base OS, VMware Tools, patched up to ${legacy_isotime("20060102")}"

  boot_order              = "disk,cdrom"

  communicator            = "winrm"
  winrm_password          = "${local.winrmPass}"
  winrm_username          = "${local.winrmUser}"

  convert_to_template     = false
  create_snapshot         = true
}

source "vsphere-iso" "Southport" {
  vcenter_server          = "${var.vcenterUK}"
  username                = "${var.vcenterUser}"
  password                = "${var.vcenterPass}"
  insecure_connection     = true

  vm_name                 = "Windows 10 (21H2)"
  vm_version              = 15
  guest_os_type           = "windows9_64Guest"

  CPUs                    = 2
  RAM                     = 8192
  RAM_reserve_all         = true
  cluster                 = "${var.cluster}"

  datastore               = "${var.datastoreUK}"
  folder                  = "${var.folder}"
  disk_controller_type    = ["pvscsi"]
  storage {
    disk_size             = 51200
    disk_thin_provisioned = true
  }
  floppy_files            = ["${path.root}/files/"]
  iso_paths               = ["[${var.datastoreISO}] en-gb_windows_10_business_editions_version_21h2_x64_dvd_71e6101d.iso", "[${var.datastoreISO}] VMware-tools-windows-12.0.0-19345655.iso"]
  remove_cdrom            = true

  network_adapters {
    network               = "${var.network}"
    network_card          = "vmxnet3"
  }

  video_ram               = 131072

  notes                   = "Base OS, VMware Tools, patched up to ${legacy_isotime("20060102")}"

  boot_order              = "disk,cdrom"

  communicator            = "winrm"
  winrm_password          = "${local.winrmPass}"
  winrm_username          = "${local.winrmUser}"

  convert_to_template     = false
  create_snapshot         = true
}

build {
  sources                 = ["source.vsphere-iso.Southport", "source.vsphere-iso.Utrecht"]

  provisioner "powershell" {
    inline                = ["powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c", "Get-AppXPackage -AllUsers | Where {($_.name -notlike \"Photos\") -and ($_.Name -notlike \"Calculator\") -and ($_.Name -notlike \"Store\")} | Remove-AppXPackage -ErrorAction SilentlyContinue", "Get-AppXProvisionedPackage -Online | Where {($_.DisplayName -notlike \"Photos\") -and ($_.DisplayName -notlike \"Calculator\") -and ($_.DisplayName -notlike \"Store\")} | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue"]
  }

  provisioner "powershell" {
    elevated_password     = "${local.winrmPass}"
    elevated_user         = "${local.winrmUser}"
    inline                = ["Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online"]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    scripts               = ["${path.root}/files/certs.ps1", "${path.root}/files/bginfo.ps1", "${path.root}/files/agent.ps1", "${path.root}/files/appvolumes.ps1", "${path.root}/files/fslogix.ps1"]
  }

  provisioner "windows-restart" {}

  provisioner "windows-update" {
    filters               = ["exclude:$_.Title -like '*Preview*'", "include:$true"]
    search_criteria       = "IsInstalled=0"
  }

  provisioner "powershell" {
    scripts               = ["${path.root}/files/osot.ps1", "${path.root}/files/sdelete.ps1"]
  }

  provisioner "powershell" {
    inline                = ["Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"]
  }
}
