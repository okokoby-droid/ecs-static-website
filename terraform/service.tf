
resource "aws_ecs_service" "website" {
  name            = "ecs-static-website-service"
  cluster         = aws_ecs_cluster.website.id
  task_definition = aws_ecs_task_definition.website.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.website.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_execution,
    aws_route_table_association.public
  ]
}

