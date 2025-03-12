resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "techdocs" {
  bucket = var.techdocs_bucket_name != null ? var.techdocs_bucket_name : "${local.name_prefix}-techdocs-${random_string.bucket_suffix.result}"

  tags = local.tags
}

resource "aws_s3_bucket_ownership_controls" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "techdocs" {
  depends_on = [aws_s3_bucket_ownership_controls.techdocs]
  bucket     = aws_s3_bucket.techdocs.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id
  
  versioning_configuration {
    status = var.techdocs_bucket_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "techdocs" {
  bucket = aws_s3_bucket.techdocs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
