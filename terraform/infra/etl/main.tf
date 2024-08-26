################################################################################
# Glue
# Glue table 
# Glue database
# crowler
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
# Glue job
################################################################################

resource "aws_glue_job" "my_python_glue_job" {
  name     = "${var.project}-etl-${var.environment}"
  role_arn = var.lab_role

  command {
    script_location = "s3://aws-glue-assets-994304508204-us-east-1/scripts/etl.py"
  }
}