provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_eip" "this" {
  count = length(data.aws_subnet_ids.all.ids)

  vpc = true
}

module "nlb" {
  internal           = true
  load_balancer_type = "network"
  name               = "ucopacme-network-load-balancer"
  source             = "./../.."
  //  Use `subnets` if you don't want to attach EIPs
  subnets = tolist(data.aws_subnet_ids.all.ids)
  //  Use `subnet_mapping` to attach EIPs
  // subnet_mappings = [for i, eip in aws_eip.this : { allocation_id : eip.id, subnet_id : tolist(data.aws_subnet_ids.all.ids)[i] }]
  vpc_id = data.aws_vpc.default.id



  //  # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  //  access_logs = {
  //    bucket = module.log_bucket.this_s3_bucket_id
  //  }


  // TCP_UDP, UDP, TCP
  listeners_http_tcp = [
    {
      port               = 25
      protocol           = "TCP"
      target_group_index = 0
    },
    {
      port               = 587
      protocol           = "TCP"
      target_group_index = 1
    },
  ]


  target_groups = [
    {
      name_prefix      = "smtp-"
      backend_protocol = "TCP"
      backend_port     = 25
      target_type      = "instance"
    },
    {
      name_prefix      = "smtps-"
      backend_protocol = "TCP"
      backed_port      = 587
      target_type      = "instance"
    },
  ]
}
