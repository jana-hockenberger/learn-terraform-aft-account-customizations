data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "immutable_bucket" {
  bucket = "backup-${data.aws_caller_identity.current.account_id}"
}


resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.immutable_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_object_lock_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 30
    }
  }
}