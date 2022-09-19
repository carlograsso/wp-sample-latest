data "template_file" "task_definition" {
  template = file("./wp_container.tpl")

  vars = {
    name                   = var.task.name
    image_url              = var.task.image_url
    container_port         = var.task.container_port
    container_path         = var.task.container_path
    source_volume          = var.task.source_volume
    db_password_secret_arn = var.task.db_password_secret_arn
    db_username            = var.task.environment.db_username
    db_host                = var.task.environment.db_host
    db_name                = var.task.environment.db_name

  }
}

