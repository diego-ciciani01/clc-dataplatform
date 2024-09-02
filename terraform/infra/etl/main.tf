################################################################################
# Glue
# Glue table 
# Glue database
# crowler
# S3
################################################################################

################################################################################
# Glue database
# - databese for catalogs
# - table for catalogs
#
################################################################################

resource "aws_glue_catalog_database" "my_catalogs" {
  name = "${var.project}-database-catalogs-${var.environment}"

  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
  name          = "${var.project}-table-catalogs-${var.environment}"
  database_name = aws_glue_catalog_database.my_catalogs.name
}

resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.my_catalogs.name
  name          = "${var.project}-craeler-${var.environment}"
  role          = var.lab_role

  s3_target {
    path = "s3://${var.project}-datalake-bronze-${var.environment}"
  }
}

################################################################################
# S3 bucket 
# for host code
# uppload code 
################################################################################
module "host_code" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project}-glue-code-${var.environment}"

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

data "aws_iam_policy_document" "bucket_host_code_policy" {

  statement {
    sid    = "allowGetAndPut"
    effect = "Allow"

    actions = ["s3:PutObject",
      "s3:GetObject",
    "s3:ListBucket"]

    resources = [
      "arn:aws:s3:::${var.project}-glue-code-${var.environment}",
      "arn:aws:s3:::${var.project}-glue-code-${var.environment}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "glue_code_policy_bronze" {
  bucket = module.host_code.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_host_code_policy.json
}

#  upload the scrit on the bucket s3
resource "aws_s3_bucket_object" "etl_code" {
  bucket = "${var.project}-glue-code-${var.environment}"
  key    = "etl.py"
  source = "resources/etl.py"
}


################################################################################
# Glue job
################################################################################

resource "aws_glue_job" "my_python_glue_job" {
  name         = "${var.project}-etl-${var.environment}"
  role_arn     = var.lab_role
  glue_version = "4.0"

  command {
    python_version  = "3.9"
    script_location = "s3://${var.project}-glue-code-${var.environment}/etl.py"
  }
}