variable "cluster_name" {
  description = "Name of ECS cluster"
  default     = "awslab-cloud"
}
variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "n"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8000
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "app_tag" {
  description = "ECR Image Tag, defaults to latest"
  default     = "LATEST"
}

variable "force_update" {
  description = "Set to true to force a new deployment, helpful to roll docker images from task"
  default     = false
  type        = bool
}

variable "health_check_path" {
  default = "/health/good"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "sub_domain_name" {
  description = "Top level domain for ALB r53 record"
}
variable "env" {
}