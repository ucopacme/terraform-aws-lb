resource "aws_lb" "this" {
  count                            = var.enabled ? 1 : 0
  drop_invalid_header_fields       = var.drop_invalid_header_fields
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  internal                         = var.internal
  load_balancer_type               = var.load_balancer_type
  name                             = var.name
  security_groups                  = var.security_groups
  subnets                  = var.subnets
  tags                             = merge(var.tags, map("Name", var.name))
  timeouts {
    create = var.timeout_create
    delete = var.timeout_delete
    update = var.timeout_update
  }

  dynamic "access_logs" {
    for_each = length(keys(var.access_logs)) == 0 ? [] : [var.access_logs]

    content {
      bucket  = lookup(access_logs.value, "bucket", null)
      enabled = lookup(access_logs.value, "enabled", lookup(access_logs.value, "bucket", null) != null)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings

    content {
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
      #private_ipv4_address = lookup(subnet_mapping.value, "private_ipv4_address", null)
      subnet_id = subnet_mapping.value.subnet_id
    }
  }
}

resource "aws_lb_listener" "listener_http_tcp" {
  count             = var.enabled ? length(var.listeners_http_tcp) : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = var.listeners_http_tcp[count.index]["port"]
  protocol          = var.listeners_http_tcp[count.index]["protocol"]

  dynamic "default_action" {
    for_each = length(keys(var.listeners_http_tcp[count.index])) == 0 ? [] : [var.listeners_http_tcp[count.index]]

    # Defaults to forward action if action_type not specified
    content {
      target_group_arn = contains([null, "", "forward"], lookup(default_action.value, "action_type", "")) ? aws_lb_target_group.this[lookup(default_action.value, "target_group_index", count.index)].id : null
      type             = lookup(default_action.value, "action_type", "forward")

      dynamic "fixed_response" {
        for_each = length(keys(lookup(default_action.value, "fixed_response", {}))) == 0 ? [] : [lookup(default_action.value, "fixed_response", {})]

        content {
          content_type = fixed_response.value["content_type"]
          message_body = lookup(fixed_response.value, "message_body", null)
          status_code  = lookup(fixed_response.value, "status_code", null)
        }
      }

      dynamic "redirect" {
        for_each = length(keys(lookup(default_action.value, "redirect", {}))) == 0 ? [] : [lookup(default_action.value, "redirect", {})]

        content {
          path        = lookup(redirect.value, "path", null)
          host        = lookup(redirect.value, "host", null)
          port        = lookup(redirect.value, "port", null)
          protocol    = lookup(redirect.value, "protocol", null)
          query       = lookup(redirect.value, "query", null)
          status_code = redirect.value["status_code"]
        }
      }
    }
  }
}

resource "aws_lb_target_group" "this" {
  count                              = var.enabled ? length(var.target_groups) : 0
  deregistration_delay               = lookup(var.target_groups[count.index], "deregistration_delay", null)
  lambda_multi_value_headers_enabled = lookup(var.target_groups[count.index], "lambda_multi_value_headers_enabled", false)
  load_balancing_algorithm_type      = lookup(var.target_groups[count.index], "load_balancing_algorithm_type", null)
  name                               = lookup(var.target_groups[count.index], "name", null)
  name_prefix                        = lookup(var.target_groups[count.index], "name_prefix", null)
  port                               = lookup(var.target_groups[count.index], "backend_port", null)
  protocol                           = lookup(var.target_groups[count.index], "backend_protocol", null) != null ? upper(lookup(var.target_groups[count.index], "backend_protocol")) : null
  proxy_protocol_v2                  = lookup(var.target_groups[count.index], "proxy_protocol_v2", false)
  slow_start                         = lookup(var.target_groups[count.index], "slow_start", null)
  target_type                        = lookup(var.target_groups[count.index], "target_type", null)
  tags                               = merge(var.tags, map("Name", var.name))
  vpc_id                             = var.vpc_id

  dynamic "health_check" {
    for_each = length(keys(lookup(var.target_groups[count.index], "health_check", {}))) == 0 ? [] : [lookup(var.target_groups[count.index], "health_check", {})]

    content {
      enabled             = lookup(health_check.value, "enabled", null)
      interval            = lookup(health_check.value, "interval", null)
      path                = lookup(health_check.value, "path", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      timeout             = lookup(health_check.value, "timeout", null)
      protocol            = lookup(health_check.value, "protocol", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  dynamic "stickiness" {
    for_each = length(keys(lookup(var.target_groups[count.index], "stickiness", {}))) == 0 ? [] : [lookup(var.target_groups[count.index], "stickiness", {})]

    content {
      enabled         = lookup(stickiness.value, "enabled", null)
      cookie_duration = lookup(stickiness.value, "cookie_duration", null)
      type            = lookup(stickiness.value, "type", null)
    }
  }


  depends_on = [aws_lb.this]

  lifecycle {
    create_before_destroy = true
  }
}
