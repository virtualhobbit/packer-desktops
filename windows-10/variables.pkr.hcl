locals {  
    winrmUser = vault("credentials/users/misc/administrator", "Username")
    winrmPass = vault("credentials/users/misc/administrator", "Password")
}

variable "cluster" {
  type    = string
  default = "${env("packer_cluster")}"
}

variable "datastoreISO" {
  type    = string
  default = "${env("packer_datastoreISO")}"
}

variable "datastoreNL" {
  type    = string
  default = "${env("packer_datastoreNL")}"
}

variable "datastoreUK" {
  type    = string
  default = "${env("packer_datastoreUK")}"
}

variable "folder" {
  type    = string
  default = "${env("packer_folder")}"
}

variable "network" {
  type    = string
  default = "${env("packer_network")}"
}

variable "vcenterNL" {
  type    = string
  default = "${env("packer_vcenterNL")}"
}

variable "vcenterPass" {
  type    = string
  default = "${env("packer_vcenterPass")}"
}

variable "vcenterUK" {
  type    = string
  default = "${env("packer_vcenterUK")}"
}

variable "vcenterUser" {
  type    = string
  default = "${env("packer_vcenterUser")}"
}