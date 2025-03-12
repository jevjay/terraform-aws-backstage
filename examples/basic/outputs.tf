output "bucket_id" {
  value = aws_s3_bucket.example.id
}

output "backstage_url" {
  description = "URL to access Backstage"
  value       = module.backstage.backstage_url
}

output "techdocs_bucket_name" {
  description = "Name of the S3 bucket for tech docs"
  value       = module.backstage.techdocs_bucket_name
}
