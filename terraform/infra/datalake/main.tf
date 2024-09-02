################################################################################
# Datalake
################################################################################
module "bronze_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project}-datalake-bronze-${var.environment}"

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

  lifecycle_rule = [
    {
      id      = "transition_to_ia"
      enabled = lookup(var.days_after_transition_to_ia, "bronze", -1) > -1

      transition = [
        {
          days          = lookup(var.days_after_transition_to_ia, "bronze")
          storage_class = "ONEZONE_IA"
        }
      ]
    }
  ]
}

module "silver_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project}-datalake-silver-${var.environment}"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule = [
    {
      id      = "transition_to_ia"
      enabled = lookup(var.days_after_transition_to_ia, "silver", -1) > -1

      transition = [
        {
          days          = lookup(var.days_after_transition_to_ia, "bronze")
          storage_class = "ONEZONE_IA"
        }
      ]
    }
  ]
}

data "aws_iam_policy_document" "bucket_bronze_policy" {

  statement {
    sid    = "allowGetAndPutBronze"
    effect = "Allow"

    actions = ["s3:PutObject",
      "s3:GetObject",
    "s3:ListBucket"]

    resources = [
      "arn:aws:s3:::${var.project}-datalake-bronze-${var.environment}",
      "arn:aws:s3:::${var.project}-datalake-bronze-${var.environment}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_bronze" {
  bucket = module.bronze_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_bronze_policy.json
}



data "aws_iam_policy_document" "bucket_silver_policy" {

  statement {
    sid    = "allowGetAndPutSilver"
    effect = "Allow"

    actions = ["s3:PutObject",
      "s3:GetObject",
    "s3:ListBucket"]

    resources = [
      "arn:aws:s3:::${var.project}-datalake-silver-${var.environment}",
      "arn:aws:s3:::${var.project}-datalake-silver-${var.environment}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy_silver" {
  bucket = module.silver_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.bucket_silver_policy.json
}

