packer {
  required_version = ">= 1.9.1"
  required_plugins {
    vsphere = {
      version = ">= 1.2.0"
          source  = "github.com/hashicorp/vsphere"
    }
  }
}
  
source "vsphere-iso" "Utrecht" {
  vcenter_server          = "${var.vcenterNL}"  
  username                = "${var.vcenterUser}"  
  password                = "${var.vcenterPass}"  
  insecure_connection     = true  

  vm_name                 = "Ubuntu 22.04 Desktop (BETA)"
  vm_version              = 20
  guest_os_type           = "ubuntu64Guest"

  CPUs                    = 2
  RAM                     = 16384
  cluster                 = "${var.cluster}"

  datastore               = "${var.datastore}"
  folder                  = "${var.folder}"
  disk_controller_type    = ["pvscsi"]
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }
  iso_paths               = ["[${var.datastoreISO}] ubuntu-mate-22.04.2-desktop-amd64.iso"]
  remove_cdrom            = true

  network_adapters {
    network               = "${var.network}"
    network_card          = "vmxnet3"
  }

  notes                   = "Base OS, VMware Tools, patched up to ${legacy_isotime("20060102")}"

  boot_order              = "disk,cdrom"
  boot_command            = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall quiet 'ds=nocloud-net;s=http://intranet.mdb-lab.com/'",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  http_content = {
    "/meta-data" = file("http/meta-data")
    "/user-data" = file("http/user-data")
  }
  shutdown_command        = "echo '${local.sshPass}' | sudo -S -E shutdown -P now"

  communicator            = "ssh"
  ssh_username            = "${local.sshUser}"
  ssh_password            = "${local.sshPass}"

  convert_to_template     = true
  create_snapshot         = false
}

source "vsphere-iso" "Southport" {
  vcenter_server          = "${var.vcenterUK}"
  username                = "${var.vcenterUser}"
  password                = "${var.vcenterPass}"
  insecure_connection     = true

  vm_name                 = "Ubuntu 22.04 Desktop (BETA)"
  vm_version              = 20
  guest_os_type           = "ubuntu64Guest"

  CPUs                    = 2
  RAM                     = 16384
  cluster                 = "${var.cluster}"

  datastore               = "${var.datastore}"
  folder                  = "${var.folder}"
  disk_controller_type    = ["pvscsi"]
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }
  iso_paths               = ["[${var.datastoreISO}] ubuntu-mate-22.04.2-desktop-amd64.iso"]
  remove_cdrom            = true

  network_adapters {
    network               = "${var.network}"
    network_card          = "vmxnet3"
  }

  notes                   = "Base OS, VMware Tools, patched up to ${legacy_isotime("20060102")}"

  boot_order              = "disk,cdrom"
  boot_command            = [
    "c<wait>",
    "autoinstall 'ds=nocloud-net;seedfrom=http://intranet.mdb-lab.com/'",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  shutdown_command        = "echo '${local.sshPass}' | sudo -S -E shutdown -P now"

  communicator            = "ssh"
  ssh_username            = "${local.sshUser}"
  ssh_password            = "${local.sshPass}"

  convert_to_template     = true
  create_snapshot         = false
}

build {
  sources                 = ["source.vsphere-iso.Utrecht", "source.vsphere-iso.Southport"]

  provisioner "shell" {
    inline                = ["apt update", "apt upgrade -y"]
  }

  provisioner "shell" {
    execute_command       = "echo '${local.sshPass}' | sudo -S -E bash '{{ .Path }}'"
    scripts               = ["setup/certs.sh", "setup/ansible.sh"]
  }

}
