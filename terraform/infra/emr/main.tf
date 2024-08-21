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
resource "aws_emr_cluster" "cluster-emr" {
  name = "${var.project}-emr-cluster-${var.environment}"
  release_label = "emr-7.2.0"
  applications = ["Spark", "hadoop", "hive", "jupyterHub"]

  ec2_attributes  {
    #subnet_ids       = ["subnet-0b1218f2848b7b037", "subnet-05d265f800e07a765", "subnet-04d87d79fc6dfed3d"]
    subnet_id       = "subnet-0e68ead312622f327"
    instance_profile = "arn:aws:iam::994304508204:instance-profile/EMR_EC2_DefaultRole" # Correct format
    emr_managed_master_security_group = module.emr_sg.security_group_id
    emr_managed_slave_security_group = module.emr_sg.security_group_id
  }
   master_instance_fleet {
    name                      = "${var.project}-master-${var.environment}"
    target_on_demand_capacity = 1
    instance_type_configs {
        instance_type = var.master_instance_type
      }
  }

    core_instance_fleet {
    name                      = "${var.project}-principal-${var.environment}"
    target_on_demand_capacity = 1
    instance_type_configs{
        instance_type     = var.principal_instance_type
        weighted_capacity = 1
      }
  }
    configurations_json = <<EOF
  [
    {
      "Classification": "hadoop-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    },
    {
      "Classification": "spark-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    }
  ]
EOF
  log_uri  = "s3://${var.project}-emr-logs-${var.environment}"
  ebs_root_volume_size = 64
  list_steps_states = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
  service_role = "arn:aws:iam::994304508204:role/EMR_DefaultRole"
}


# module "emr" {


  

#   create_autoscaling_iam_role    = false
#   create_iam_instance_profile    = false
#   create_service_iam_role        = false
#   create_security_configuration  = false
#   create_managed_security_groups = false

#   service_iam_role_arn = var.iam_role_arn

#   # bootstrap_action = {
#   #   example = {
#   #     path = "file:/bin/echo",
#   #     name = "Just an example",
#   #     args = ["Hello World!"]
#   #   }
#   # }

#   configurations_json = jsonencode([
#     {
#       "Classification" : "spark-env",
#       "Configurations" : [
#         {
#           "Classification" : "export",
#           "Properties" : {
#             "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
#           }
#         }
#       ],
#       "Properties" : {}
#     }
#   ])

#   master_instance_fleet = {
#     name                      = "${var.project}-master-${var.environment}"
#     target_on_demand_capacity = 1
#     instance_type_configs = [
#       {
#         instance_type = var.master_instance_type
#       }
#     ]
#   }

#   core_instance_fleet = {
#     name                      = "${var.project}-principal-${var.environment}"
#     target_on_demand_capacity = 1
#     instance_type_configs = [
#       {
#         instance_type     = var.principal_instance_type
#         weighted_capacity = 1
#       }
#     ]
#   }

#   task_instance_fleet = {
#     name                      = "${var.project}-task-${var.environment}"
#     target_on_demand_capacity = 1
#     instance_type_configs = [
#       {
#         instance_type     = var.task_instance_type
#         weighted_capacity = 1
#       }
#     ]
#   }

#   ebs_root_volume_size = 64




#   vpc_id = "vpc-048dbe45304895ff2"

#   list_steps_states = ["PENDING", "RUNNING", "FAILED", "INTERRUPTED"]
#   log_uri           = "s3://${var.project}-emr-logs-${var.environment}"

#   scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
#   step_concurrency_level = 3
#   termination_protection = false
#   visible_to_all_users   = true
# }

################################################################################
# - Sg
# security group for emr
################################################################################
module "emr_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  name        = "${var.project}-emr-${var.environment}-sg"
  description = "Security Group for emr cluster"
  vpc_id = "vpc-048dbe45304895ff2"
  computed_ingress_with_cidr_blocks = [
    {
      description = "Allow connections 80 vpc"
      rule        = "http-80-tcp"
      cidr_blocks = var.vpc_cidr
    },
    {
      description = "Access From Internet"
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0"
    },
    {
      description = "Access From ssh port"
      rule        = "ssh-22-tcp"
      from_port   = "22"
      to_port     = "22"
      cidr_blocks = "0.0.0.0"
    }
  ]
  egress_rules = ["all-all"]
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