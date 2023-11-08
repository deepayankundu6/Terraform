provider "aws" {
  region     = "ap-south-1"
}

resource "aws_elastic_beanstalk_application" "example" { 
 name = "my-nodejs-app" 
}
 
resource "aws_elastic_beanstalk_environment" "example" { 
 name = "deeps-nodejs-environment"
 application = aws_elastic_beanstalk_application.example.name 
 solution_stack_name = "64bit Amazon Linux 2 v5.4.1 running Node.js 18" 
} 

data "archive_file" "example" { 
 type = "zip" 
 source_dir = "example-app/" 
 output_path = "example-app.zip" 
} 

resource "aws_elastic_beanstalk_application_version" "example" {
 name = "example-app-version" 
 bucket = ""
 key = ""
 application = aws_elastic_beanstalk_application.example.name 
 description = "Example Node.js Application"
 source_bundle = "example-app.zip" 
}
 
resource "aws_elastic_beanstalk_environment" "example" {
 name = "example-nodejs-environment"
 application = aws_elastic_beanstalk_application.example.name
 solution_stack_name = "64bit Amazon Linux 2 v5.4.1 running Node.js 18"
 setting { 
    namespace = "aws:elasticbeanstalk:container:nodejs"
    name = "NodeCommand" value = "npm start"
 } 
 setting { 
     namespace = "aws:elasticbeanstalk:environment" 
     name = "PORT" value = "3000" 
 } 
 setting {
     namespace = "aws:elasticbeanstalk:application:environment" 
     name = "NODE_ENV" value = "production" 
 } 
 setting {
     namespace = "aws:elasticbeanstalk:application:environment" 
     name = "EXAMPLE_APP_DB_URI" 
     value = "mongodb://example-user:example-password@example-db.example-region.rds.amazonaws.com:27017/example-db" 
} 
depends_on = [ aws_elastic_beanstalk_application_version.example ] 
} 