
resource "aws_ecs_cluster" "website" {
  name = "ecs-static-website-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

