resource "aws_codepipeline" "codepipeline" {
  name     = "${var.name}-codepipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.this.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner = "carlograsso"
        Repo = "wp-sample-final"
        Branch = "main"
        OAuthToken = "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"
       }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["DefinitionArtifact", "ImageArtifact"]
      version          = "1"

      configuration = {
        ProjectName = var.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["DefinitionArtifact", "ImageArtifact"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.this.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.this.deployment_group_name
        AppSpecTemplateArtifact        = "DefinitionArtifact"
        AppSpecTemplatePath            = "appspec.yaml"
        TaskDefinitionTemplateArtifact = "DefinitionArtifact"
        TaskDefinitionTemplatePath     = "taskdef.json"
        Image1ArtifactName             = "ImageArtifact"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "this" {
  name          = var.name
  provider_type = "GitHub"
}

resource "random_integer" "this" {
  min = 100000
  max = 999999

}

resource "aws_s3_bucket" "this" {
  bucket = "${var.name}-cicd-${random_integer.this.result}"
  lifecycle {
    ignore_changes = [bucket]
  }
}


resource "aws_s3_bucket_acl" "codepipeline" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

#############################

resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = var.name
}


resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_config_name = var.deployment_config_name
  deployment_group_name  = var.ecs_service_name
  service_role_arn       = aws_iam_role.codedeploy.arn
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = var.termination_wait_time_in_minutes
    }
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
        var.main_listener]
      }

      target_group {
        name = var.main_target_group
      }

      target_group {
        name = var.dev_target_group
      }

      test_traffic_route {
        listener_arns = [
        var.dev_listener]
      }
    }
  }

}

