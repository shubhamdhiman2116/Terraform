terraform {
    backend "s3" {
        bucket = "your-terraform-state-bucket-4"
        key = "rds/project/terraform.tfstate"
        region = "ap-south-1"
        dynamodb_table = "terraform-lock"
    }
}
