packer {
  required_version = ">= 1.7.4"
  required_plugins {
    vsphere = {
      version = ">= v1.0.2"
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

  vm_name                 = "Windows 10 (20H2) (PACKAGING)"
  vm_version              = 15
  guest_os_type           = "windows9_64Guest"

  CPUs                    = 2
  RAM                     = 8192
  RAM_reserve_all         = true
  cluster                 = "${var.cluster}"

  datastore               = "${var.datastoreNL}"
  folder                  = "${var.folder}"
  disk_controller_type    = "pvscsi"
  storage {
    disk_size             = 51200
    disk_thin_provisioned = true
  }
  floppy_files            = ["${path.root}/files/"]
  iso_paths               = ["[${var.datastoreISO}] en-gb_windows_10_business_editions_version_20h2_updated_feb_2021_x64_dvd_0d450cea.iso", "[${var.datastoreISO}] VMware-tools-windows-11.3.0-18090558.iso"]
  remove_cdrom            = true

  network_adapters {
    network               = "${var.network}"
    network_card          = "vmxnet3"
  }

  video_ram               = 131072

  notes                   = "Base OS, VMware Tools, patched up to ${legacy_isotime("20060102")}"

  boot_order              = "disk,cdrom"

  communicator            = "winrm"
  winrm_password          = "${var.winrmPass}"
  winrm_username          = "${var.winrmUser}"

  convert_to_template     = false
  create_snapshot         = true
}

build {
  sources                 = ["source.vsphere-iso.Utrecht"]

  provisioner "powershell" {
    inline                = ["powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c", "Get-AppXPackage -AllUsers | Where {($_.name -notlike \"Photos\") -and ($_.Name -notlike \"Calculator\") -and ($_.Name -notlike \"Store\")} | Remove-AppXPackage -ErrorAction SilentlyContinue", "Get-AppXProvisionedPackage -Online | Where {($_.DisplayName -notlike \"Photos\") -and ($_.DisplayName -notlike \"Calculator\") -and ($_.DisplayName -notlike \"Store\")} | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue"]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    scripts               = ["${path.root}/setup/certs.ps1", "${path.root}/setup/appvolumes.ps1"]
  }

  provisioner "powershell" {
    inline                = ["Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }"]
  }
}
