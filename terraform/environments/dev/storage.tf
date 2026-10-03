resource "aws_kms_key" "dev_s3" {
  description             = "KMS key for Development S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "dev-s3-kms-key"
  }
}

resource "aws_kms_alias" "dev_s3" {
  name          = "alias/dev-s3-storage"
  target_key_id = aws_kms_key.dev_s3.key_id
}

# checkov:skip=CKV_AWS_18:Access logging is intentionally skipped for this temporary development lab bucket.
# checkov:skip=CKV_AWS_144:Cross-region replication is intentionally skipped for this single-region lab bucket.
# checkov:skip=CKV2_AWS_62:Event notifications are enabled explicitly below for the bucket.
resource "aws_s3_bucket" "dev_app_files" {
  bucket        = "victor-dev-app-files-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  force_destroy = false

  tags = {
    Name = "dev-app-files"
  }
}

resource "aws_kms_key_policy" "dev_s3" {
  key_id = aws_kms_key.dev_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3UseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "dev_app_files" {
  bucket = aws_s3_bucket.dev_app_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "dev_app_files" {
  bucket = aws_s3_bucket.dev_app_files.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev_app_files" {
  bucket = aws_s3_bucket.dev_app_files.id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.dev_s3.arn
    }
  }
}

resource "aws_s3_bucket_notification" "dev_app_files" {
  bucket      = aws_s3_bucket.dev_app_files.id
  eventbridge = true
}

resource "aws_s3_bucket_lifecycle_configuration" "dev_app_files" {
  bucket = aws_s3_bucket.dev_app_files.id

  rule {
    id     = "development-storage-cleanup"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.dev_app_files]
}

# Deny requests that do not use HTTPS
data "aws_iam_policy_document" "dev_bucket_https_only" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.dev_app_files.arn,
      "${aws_s3_bucket.dev_app_files.arn}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "dev_https_only" {
  bucket = aws_s3_bucket.dev_app_files.id
  policy = data.aws_iam_policy_document.dev_bucket_https_only.json
}

# Least-privilege S3 permissions for the Development EC2 role
data "aws_iam_policy_document" "dev_ec2_s3_access" {
  statement {
    sid    = "ListDevelopmentBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.dev_app_files.arn
    ]
  }

  statement {
    sid    = "ReadAndUploadDevelopmentObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.dev_app_files.arn}/*"
    ]
  }

  statement {
    sid    = "UseDevelopmentS3KMSKey"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [aws_kms_key.dev_s3.arn]
  }
}

resource "aws_iam_role_policy" "dev_ec2_s3_access" {
  name   = "dev-ec2-s3-access"
  role   = aws_iam_role.dev_ec2_ssm_role.name
  policy = data.aws_iam_policy_document.dev_ec2_s3_access.json
}

# Allow private EC2 HTTPS traffic to the regional S3 prefix list
resource "aws_vpc_security_group_egress_rule" "dev_ec2_to_s3" {
  security_group_id = aws_security_group.dev_ec2.id
  prefix_list_id    = aws_vpc_endpoint.s3.prefix_list_id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  description = "Allow HTTPS from Development EC2 to S3 gateway endpoint"
}

# Identify the current AWS account for a globally unique bucket name
data "aws_caller_identity" "current" {}

locals {
  dev_bucket_name = "victor-dev-app-files-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}
