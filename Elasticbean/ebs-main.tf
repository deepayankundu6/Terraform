provider "aws" {
  region = "ap-south-1"
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "my-jnode-eb-lg"
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
  tier                = "WebServer"
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = true
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }
  setting {
    namespace = "aws:elb:listener:listener_port"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }
  
  depends_on = [aws_elastic_beanstalk_application_version.example]
}
