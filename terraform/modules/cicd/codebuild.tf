resource "aws_codebuild_project" "this" {
  name          = var.name
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type = "CODEPIPELINE"

  }

  environment {
    image                       = var.codebuild_params.image
    type                        = var.codebuild_params.type
    compute_type                = var.codebuild_params.compute_type
    image_pull_credentials_type = var.codebuild_params.cred_type
    privileged_mode             = true

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}


resource "aws_ecr_repository" "this" {
  name                 = var.image_name
  image_tag_mutability = "MUTABLE"
}