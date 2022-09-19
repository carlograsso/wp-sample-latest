[{
  "name"        : "${name}",
  "image"       : "${image_url}",
  "essential"   : true,
  "portMappings" : [
    {
      "protocol"      : "tcp",
      "containerPort" : ${container_port},
      "hostPort"      : ${container_port}
    }
  ],
  "mountPoints" : [
    {
      "containerPath" : "${container_path}",
      "sourceVolume" : "${source_volume}",
      "readOnly" : false
    }
  ],
  "logConfiguration" : {
    "logdriver" : "awslogs",
    "options" : {
      "awslogs-group"         : "/ecs/${name}",
      "awslogs-region"        : "eu-west-1",
      "awslogs-stream-prefix" : "stdout"
      }
  },
  "environment" : [
    {
      "name"  : "WORDPRESS_DATABASE_HOST",
      "value" : "${db_host}"
    },
    {
      "name"  : "WORDPRESS_DATABASE_USER",
      "value" : "${db_username}"
    },
    {
      "name"  : "WORDPRESS_DATABASE_NAME",
      "value" : "${db_name}"
    },
    {
      "name"  : "enabled",
      "value" : "yes"
    },
    {
      "name"  : "ALLOW_EMPTY_PASSWORD",
      "value" : "no" 
    }
  ],
  "secrets": [
    {
      "name": "WORDPRESS_DATABASE_PASSWORD",
      "valueFrom": "${db_password_secret_arn}"
    }
  ]  

}
]