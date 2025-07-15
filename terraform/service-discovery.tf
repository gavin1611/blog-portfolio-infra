# Service Discovery Configuration

################################################################################
# Service Discovery
################################################################################

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${local.name_prefix}.local"
  description = "Private DNS namespace for ${local.name_prefix}"
  vpc         = module.vpc.vpc_id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-service-discovery"
    Type = "service-discovery-namespace"
  })
}

resource "aws_service_discovery_service" "backend" {
  name = "backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  # Health check configuration is handled by ECS service, not here

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-service-discovery"
    Type = "service-discovery-service"
  })
}