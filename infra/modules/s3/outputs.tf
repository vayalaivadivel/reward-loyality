output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.this.name
}