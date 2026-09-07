resource "aws_ecs_cluster" "warmup" {
  name = "demo-app-warmup"

  setting {
    name  = "containerInsights"
    value = "disabled"  # keep it off to avoid CloudWatch charges while learning
  }
}