variable "instance_name" {
    default = "Monitoring_server"  # Names of the instance
}

variable "key_name" {
  default = "pathnext-ec2-key"                  # Names of key in aws
}


variable "access_key" {
  default = "insert"                # aws access key
  type = "string"
}

variable "secret_key" {
  default = "insert"         # aws secret key
  type = "string"
}

