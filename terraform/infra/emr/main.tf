################################################################################
# Summary: 
# - EMR 
# - S3 
# - Sg
################################################################################

################################################################################ 
# - EMR
# Cluster for EMR
################################################################################
module "emr" {
  source  = "terraform-aws-modules/emr/aws"
  version = "1.1.2"

  name = "${var.project}-emr-cluster-${var.environment}"

  release_label = "emr-7.2.0"

  applications = ["spark", "hadoop", "hive", "jupyterHub"]

  create_autoscaling_iam_role    = false
  create_iam_instance_profile    = false
  create_service_iam_role        = false
  create_security_configuration  = false
  create_managed_security_groups = false

  service_iam_role_arn = var.iam_role_arn

  # bootstrap_action = {
  #   example = {
  #     path = "file:/bin/echo",
  #     name = "Just an example",
  #     args = ["Hello World!"]
  #   }
  # }

  configurations_json = jsonencode([
    {
      "Classification" : "spark-env",
      "Configurations" : [
        {
          "Classification" : "export",
          "Properties" : {
            "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties" : {}
    }
  ])

  master_instance_fleet = {
    name                      = "${var.project}-master-${var.environment}"
    target_on_demand_capacity = 1
    instance_type_configs = [
      {
        instance_type = var.master_instance_type
      }
    ]
  }

  core_instance_fleet = {
    name                      = "${var.project}-principal-${var.environment}"
    target_on_demand_capacity = 1
    instance_type_configs = [
      {
        instance_type     = var.principal_instance_type
        weighted_capacity = 1
      }
    ]
  }

  task_instance_fleet = {
    name                      = "${var.project}-task-${var.environment}"
    target_on_demand_capacity = 1
    instance_type_configs = [
      {
        instance_type     = var.task_instance_type
        weighted_capacity = 1
      }
    ]
  }

  ebs_root_volume_size = 64

  ec2_attributes = {
    #subnet_ids       = ["subnet-0b1218f2848b7b037", "subnet-05d265f800e07a765", "subnet-04d87d79fc6dfed3d"]
    subnet_ids       = ["subnet-0e68ead312622f327"]
    instance_profile = "arn:aws:iam::994304508204:instance-profile/EMR_EC2_DefaultRole" # Correct format
  }


  vpc_id = "vpc-048dbe45304895ff2"

  list_steps_states = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
  log_uri           = "s3://${var.project}-emr-logs-${var.environment}"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true
}



################################################################################ 
# - S3
# Bucker s3 for emr backup
################################################################################
module "emr_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project}-emr-logs-${var.environment}"

  versioning = {
    enabled = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {

  statement {
    sid    = "allowGetAndPutBronze"
    effect = "Allow"

    actions = ["s3:PutObject",
      "s3:GetObject",
    "s3:ListBucket"]

    resources = [
      "arn:aws:s3:::${var.project}-emr-logs-${var.environment}",
      "arn:aws:s3:::${var.project}-emr-logs-${var.environment}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::994304508204:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_bronze" {
  bucket = module.emr_logs.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_policy.json
}