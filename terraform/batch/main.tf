
# ===============================
# Compute Environment
resource "aws_batch_compute_environment" "cert_env" {
  compute_environment_name = "${var.environment}-cert-env"

  compute_resources {
    max_vcpus = 4

    security_group_ids = [
      data.terraform_remote_state.efs.outputs.efs_sg_id
    ]

    subnets = [
      var.public_subnet_id
    ]

    type = "FARGATE"
  }

  service_role = "arn:aws:iam::AWS_ACC_ID:role/aws-service-role/batch.amazonaws.com/AWSServiceRoleForBatch"
  type         = "MANAGED"
}

# ===============================
# Job Queue
resource "aws_batch_job_queue" "cert_queue" {
  name     = "${var.environment}-cert-job-queue"
  state    = "ENABLED"
  priority = 200
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.cert_env.arn
  }
}

# ===============================
# Job Definitions
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.environment}-certbot-fargate-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "route53_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
}

resource "aws_iam_role_policy_attachment" "aws_batch_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "aws_ssm_read_only_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "template_file" "list_certs_job_template" {
  template = "${file("list_certs_job.json")}"

  vars = {
    "JOB_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EXECUTION_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EFS_NAME" = "PROD-CERT-EFS"
  }

}

resource "aws_batch_job_definition" "list_certs_job" {
  name = "list_certs_job_definition"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  timeout {
    attempt_duration_seconds = 120
  }
  container_properties   = "${data.template_file.list_certs_job_template.rendered}"
}

data "template_file" "renew_certs_job_template" {
  template = "${file("renew_certs_job.json")}"

  vars = {
    "JOB_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EXECUTION_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EFS_NAME" = "PROD-CERT-EFS"
  }

}

resource "aws_batch_job_definition" "renew_certs_job" {
  name = "renew_certs_job_definition"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  timeout {
    attempt_duration_seconds = 1800
  }
  container_properties   = "${data.template_file.renew_certs_job_template.rendered}"
}

data "template_file" "create_certs_job_template" {
  template = "${file("create_certs_job.json")}"

  vars = {
    "JOB_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EXECUTION_ROLE" = "${aws_iam_role.ecs_task_execution_role.arn}"
    "EFS_NAME" = "PROD-CERT-EFS"
  }

}

resource "aws_batch_job_definition" "create_certs_job" {
  name = "create_certs_job_definition"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  timeout {
    attempt_duration_seconds = 120
  }
  container_properties   = "${data.template_file.create_certs_job_template.rendered}"
}
