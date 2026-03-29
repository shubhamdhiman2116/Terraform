terraform {
    backend "s3" {
        bucket = "your-terraform-state-bucket"
        key = "rds/project/terraform.tfstate"
        region = "eu-west-2"
        dynamodb_table = "terraform-lock"
    }
}
