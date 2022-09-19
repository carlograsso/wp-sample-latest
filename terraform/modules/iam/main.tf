resource "aws_iam_role" "ecs_task" {
  name = "${var.project}-ecs-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:ecs:*:*:*" #TODO
          }
        }
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.efs_access.arn,
  aws_iam_policy.db_access.arn, aws_iam_policy.ecr_access.arn]
}

resource "aws_iam_policy" "efs_access" {
  name = "${var.project}-efs-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientMount"
        ],
        "Resource" : "arn:aws:elasticfilesystem:::file-system/*",
        "Condition" : {
          "Bool" : {
            "elasticfilesystem:AccessedViaMountTarget" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_access" {
  name = "${var.project}-ecr-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "secret_access" {
  name = "${var.project}-secret-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "${var.db_password_secret_arn}"
      }
    ]
  })
}


resource "aws_iam_policy" "db_access" {
  name = "${var.project}-db-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "rds:*",
        "Resource" : ["arn:aws:rds:*:*:*"]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_execution" {
  name = "${var.project}-ecs-execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [aws_iam_policy.ecs_execution.arn, aws_iam_policy.secret_access.arn]
}


resource "aws_iam_policy" "ecs_execution" {
  name = "${var.project}-ecs-execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "ECSTaskManagement",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:CreateNetworkInterfacePermission",
          "ec2:DeleteNetworkInterface",
          "ec2:DeleteNetworkInterfacePermission",
          "ec2:Describe*",
          "ec2:DetachNetworkInterface",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "route53:ChangeResourceRecordSets",
          "route53:CreateHealthCheck",
          "route53:DeleteHealthCheck",
          "route53:Get*",
          "route53:List*",
          "route53:UpdateHealthCheck",
          "servicediscovery:DeregisterInstance",
          "servicediscovery:Get*",
          "servicediscovery:List*",
          "servicediscovery:RegisterInstance",
          "servicediscovery:UpdateInstanceCustomHealthStatus"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AutoScaling",
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:Describe*"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "AutoScalingManagement",
        "Effect" : "Allow",
        "Action" : [
          "autoscaling:DeletePolicy",
          "autoscaling:PutScalingPolicy",
          "autoscaling:SetInstanceProtection",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        "Resource" : "*",
        "Condition" : {
          "Null" : {
            "autoscaling:ResourceTag/AmazonECSManaged" : "false"
          }
        }
      },
      {
        "Sid" : "AutoScalingPlanManagement",
        "Effect" : "Allow",
        "Action" : [
          "autoscaling-plans:CreateScalingPlan",
          "autoscaling-plans:DeleteScalingPlan",
          "autoscaling-plans:DescribeScalingPlans"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "CWAlarmManagement",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:DeleteAlarms",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm"
        ],
        "Resource" : "arn:aws:cloudwatch:*:*:alarm:*"
      },
      {
        "Sid" : "ECSTagging",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:network-interface/*"
      },
      {
        "Sid" : "CWLogGroupManagement",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : "arn:aws:logs:*:*:log-group:/aws/ecs/*"
      },
      {
        "Sid" : "CWLogStreamManagement",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:log-group:/aws/ecs/*:log-stream:*"
      },
      {
        "Sid" : "ExecuteCommandSessionManagement",
        "Effect" : "Allow",
        "Action" : [
          "ssm:DescribeSessions"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "ExecuteCommand",
        "Effect" : "Allow",
        "Action" : [
          "ssm:StartSession"
        ],
        "Resource" : [
          "arn:aws:ecs:*:*:task/*",
          "arn:aws:ssm:*:*:document/AmazonECS-ExecuteInteractiveCommand"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}