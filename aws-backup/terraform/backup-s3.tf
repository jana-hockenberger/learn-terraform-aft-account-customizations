data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "immutable_bucket" {
  bucket = "veeam-backup-capacity-pool-${data.aws_caller_identity.current.account_id}"
  tags = {
    Description = "S3 bucket for storing Veeam backup data"
  }
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.immutable_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "object_lock" {
  bucket = aws_s3_bucket.immutable_bucket.id

  depends_on = [aws_s3_bucket_versioning.versioning]

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 30
    }
  }
}

# Enable encryption on the bucket as Best Practice even though it is default by now
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.immutable_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Create IAM user for Veeam
resource "aws_iam_user" "veeam_backup_user" {
  name = "veeam-backup-user"
  path = "/"
}

# Create access key for the user
resource "aws_iam_access_key" "veeam_user_key" {
  user = aws_iam_user.veeam_backup_user.name
}

# Create the S3 policy
resource "aws_iam_policy" "s3_access_policy" {
  name        = "veeam-s3-access-policy"
  description = "Policy for Veeam S3 bucket access with versioning and object lock capabilities"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:ListBucketVersions",
          "s3:ListBucket",
          "s3:PutObjectLegalHold",
          "s3:GetBucketVersioning",
          "s3:GetObjectLegalHold",
          "s3:GetBucketObjectLockConfiguration",
          "s3:PutObject*",
          "s3:GetObject*",
          "s3:GetEncryptionConfiguration",
          "s3:PutObjectRetention",
          "s3:PutBucketObjectLockConfiguration",
          "s3:DeleteObject*",
          "s3:DeleteObjectVersion",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.immutable_bucket.id}/*",
          "arn:aws:s3:::${aws_s3_bucket.immutable_bucket.id}"        ]
      },
      {
        Sid    = "VisualEditor1"
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the user
resource "aws_iam_user_policy_attachment" "veeam_user_policy" {
  user       = aws_iam_user.veeam_backup_user.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "veeam_credentials" {
  name = "veeam-backup-credentials"
  description = "Access credentials for Veeam backup user"
}

resource "aws_secretsmanager_secret_version" "veeam_credentials" {
  secret_id = aws_secretsmanager_secret.veeam_credentials.id
  secret_string = jsonencode({
    access_key = aws_iam_access_key.veeam_user_key.id
    secret_key = aws_iam_access_key.veeam_user_key.secret
    username   = aws_iam_user.veeam_backup_user.name
  })
}

# Output the name of the secret (but not the actual credentials)
output "secrets_manager_secret_name" {
  value = aws_secretsmanager_secret.veeam_credentials.name
}