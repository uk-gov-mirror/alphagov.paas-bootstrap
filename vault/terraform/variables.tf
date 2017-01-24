//-------------------------------------------------------------------
// Vault settings
//-------------------------------------------------------------------

variable "download-url" {
    default = "https://releases.hashicorp.com/vault/0.6.4/vault_0.6.4_linux_amd64.zip"
    description = "URL to download Vault"
}

variable "config" {
    description = "Configuration (text) for Vault"
}

variable "extra-install" {
    default = ""
    description = "Extra commands to run in the install script"
}

//-------------------------------------------------------------------
// AWS settings
//-------------------------------------------------------------------

variable "ami" {
    default = "ami-b17a12c6"
    description = "AMI for Vault instances"
}

variable "availability-zones" {
    default = "eu-west-1a,eu-west-1b"
    description = "Availability zones for launching the Vault instances"
}

variable "elb-health-check" {
    default = "HTTP:8200/v1/sys/health"
    description = "Health check for Vault servers"
}

variable "instance_type" {
    default = "m3.medium"
    description = "Instance type for Vault instances"
}

variable "key-name" {
    default = "default"
    description = "SSH key name for Vault instances"
}

variable "nodes" {
    default = "2"
    description = "number of Vault instances"
}

variable "env" {
  description = "Environment name"
}

variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default     = "10.0.0.0/16"
}

variable "zones" {
  description = "AWS availability zones"

  default = {
    zone0 = "eu-west-1a"
    zone1 = "eu-west-1b"
  }
}

variable "zone_index" {
  description = "AWS availability zone indices"

  default = {
    eu-west-1a = "0"
    eu-west-1b = "1"
  }
}

variable "zone_labels" {
  description = "AWS availability zone labels as used in BOSH manifests (z1-z3)"

  default = {
    eu-west-1a = "z1"
    eu-west-1b = "z2"
  }
}

variable "zone_count" {
  description = "Number of zones to use"
  default     = 2
}

variable "infra_cidrs" {
  description = "CIDR for infrastructure subnet indexed by AZ"

  default = {
    zone0 = "10.0.0.0/24"
    zone1 = "10.0.1.0/24"
  }
}

variable "infra_gws" {
  description = "GW per CIDR"

  default = {
    "10.0.0.0/24" = "10.0.0.1"
    "10.0.1.0/24" = "10.0.1.1"
  }
}

variable "vagrant_cidr" {
  description = "IP address of the AWS Vagrant bootstrap concourse"
  default     = ""
}

/* Operators will mainly be from the office. See https://sites.google.com/a/digital.cabinet-office.gov.uk/gds-internal-it/news/aviationhouse-sourceipaddresses for details. */
variable "admin_cidrs" {
  description = "CSV of CIDR addresses with access to operator/admin endpoints"

  default = [
    "80.194.77.90/32",
    "80.194.77.100/32",
    "85.133.67.244/32",
  ]
}

/* See https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html */
variable "default_elb_security_policy" {
  description = "Which Security policy to use for ELBs. This controls things like available SSL protocols/ciphers."
  default     = "ELBSecurityPolicy-2016-08"
}
