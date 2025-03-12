resource "aws_ecr_repository" "backstage" {
  count = var.use_existing_ecr ? 0 : 1
  
  name                 = var.existing_ecr_repository_name != null ? var.existing_ecr_repository_name : "${local.name_prefix}-repository"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "backstage" {
  count      = var.use_existing_ecr ? 0 : 1
  repository = aws_ecr_repository.backstage[0].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
    }]
  })
}
