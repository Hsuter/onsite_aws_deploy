variable "instance_type" {
  default = "t3.micro" # free tier eligible
}

variable "disk_size" {
  default = 8 # GB
}


variable "repo_url" {
  type        = string
  description = "Git repo URL to clone on the instance"
  default     = ""
}

variable "repo_branch" {
  type        = string
  description = "Git branch to checkout"
  default     = "main"
}


variable "project_name" {
  description = "Project name used for tagging and naming resources"
  type        = string
  default     = "remake"
}
