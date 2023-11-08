provider "aws" {
  region = "ap-south-1"
}

data "archive_file" "example" {
  type        = "zip"
  source_dir  = "express-app/"
  output_path = "express-app.zip"
}
resource "aws_s3_bucket" "default" {
  bucket = "deep-241196-node-app"
}

resource "aws_s3_object" "default" {
  bucket = aws_s3_bucket.default.id
  key    = "beanstalk/express-app.zip"
  source = "express-app.zip"
}

resource "aws_elastic_beanstalk_application" "example" {
  name = "my-nodejs-app"
}

resource "aws_elastic_beanstalk_application_version" "example" {
  name        = aws_elastic_beanstalk_application.example.name
  bucket      = aws_s3_bucket.default.id
  key         = aws_s3_object.default.id
  application = aws_elastic_beanstalk_application.example.name
  description = "Example Node.js Application"
}

resource "aws_elastic_beanstalk_environment" "example" {
  name                = "deeps-nodejs-environment"
  application         = aws_elastic_beanstalk_application.example.name
  solution_stack_name = "64bit Amazon Linux 2023 v6.0.2 running Node.js 18"
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }
  depends_on = [aws_elastic_beanstalk_application_version.example]
} 
