# Terraform module for AWS Application and Network Load Balancer (ALB & NLB) 

These resources are supported:

* [Load Balancer](https://www.terraform.io/docs/providers/aws/r/lb.html)
* [Load Balancer Listener](https://www.terraform.io/docs/providers/aws/r/lb_listener.html)
* [Target Group](https://www.terraform.io/docs/providers/aws/r/lb_target_group.html)

Not supported (yet):

* [Load Balancer Listener Certificate](https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html)
* [Load Balancer Listener default actions](https://www.terraform.io/docs/providers/aws/r/lb_listener.html) - All actions supported.
* [Load Balancer Listener Rule](https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html)
* [Target Group Attachment](https://www.terraform.io/docs/providers/aws/r/lb_target_group_attachment.html)

## Terraform versions

Terraform 0.12 and newer. Pin module version to `~> v5.0`. Submit pull-requests to `master` branch.

Terraform 0.11. Pin module version to `~> v3.0`. Submit pull-requests to `terraform011` branch.

## Usage

### Application Load Balancer

HTTP and HTTPS listeners with default actions:

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

HTTP to HTTPS redirect and HTTPS cognito authentication:

```hcl
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-abcde012"
  subnets            = ["subnet-abcde012", "subnet-bcde012a"]
  security_groups    = ["sg-edcd9784", "sg-edcd9785"]
  
  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]

  https_listeners = [
    {
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      action_type          = "authenticate-cognito"
      target_group_index   = 0
      authenticate_cognito = {
        user_pool_arn       = "arn:aws:cognito-idp::123456789012:userpool/test-pool"
        user_pool_client_id = "6oRmFiS0JHk="
        user_pool_domain    = "test-domain-com"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```

### Network Load Balancer (TCP_UDP, UDP, TCP and TLS listeners)

```hcl
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  
  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = "vpc-abcde012"
  subnets = ["subnet-abcde012", "subnet-bcde012a"]
  
  access_logs = {
    bucket = "my-nlb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
```
