output "public_ip" {
  value = aws_instance.minecraft_server.public_ip
}

output "minecraft_server_address" {
  value = "${aws_instance.minecraft_server.public_ip}:25565"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.minecraft_backup.bucket
}

output "ecr_repo_url" {
  value = aws_ecr_repository.minecraft_repo.repository_url
}
