# uploading objects to s3
resource "aws_s3_object" "upload-glue-script-1" {
  bucket = aws_s3_bucket.scripts.id
  key    = "firstjob.py"
  source = "./firstjob.py"
}

resource "aws_s3_object" "upload-glue-script-2" {
  bucket = aws_s3_bucket.scripts.id
  key    = "secondjob.py"
  source = "./secondjob.py"
}


#-------------------------  GLUE JOB -----------------------------#
resource "aws_glue_job" "ingestion" {
  glue_version = "4.0" 
  max_retries = 0 
  name = "Ingestion_job-${random_id.random_id_generator.hex}" 
  description = "Ingesting data from s3" 
  role_arn = "arn:aws:iam::126751535369:role/LabRole"
  
  number_of_workers = 2 
  worker_type = "G.1X" 
  timeout = "60" 
  
  command {
    name="glueetl" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/firstjob.py" 
    python_version = "3"
  }

}

resource "aws_glue_job" "cleaning" {
  glue_version = "4.0"
  max_retries = 0 
  name = "Cleaning_job-${random_id.random_id_generator.hex}" 
  description = "Cleaning and preprocessing" 
  role_arn = "arn:aws:iam::126751535369:role/LabRole"
  
  number_of_workers = 2
  worker_type = "G.1X" 
  timeout = "60" 
 
  command {
    name="glueetl" 
    script_location = "s3://${aws_s3_bucket.scripts.id}/secondjob.py" 
    python_version = "3"
  }  
}


#---------- STEP FUNCTION TO TRIGGER GLUE JOB AND NOTIFY---------------#
resource "aws_sfn_state_machine" "glue_job_trigger" {
  name     = "group4stepfunction"
  role_arn = "arn:aws:iam::126751535369:role/LabRole"


  definition = <<EOF
{
  "Comment": "ingesting data from rds to s3",
  "StartAt": "GlueJob1",
  "States": {
    "GlueJob1": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${aws_glue_job.ingestion.name}"
      },
      "Next": "SNSPublish1"
    },
    "SNSPublish1": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.topic_arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Job 1 is completed successfully."
      },
      "Next": "GlueJob2"
    },
    "GlueJob2": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun.sync",
      "Parameters": {
        "JobName": "${aws_glue_job.cleaning.name}"
      },
      "Next": "SNSPublish2"
    },
    "SNSPublish2": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.topic_arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Job 2 is completed successfully."
      },
      "Next": "WaitForGlueJob2Completion"
    },
    "WaitForGlueJob2Completion": {
      "Type": "Wait",
      "Seconds": 60,
      "Next": "StartCrawler"
    },
    "StartCrawler": {
      "Type": "Task",
      "Next": "SNSPublish3",
      "Parameters": {
        "Name": "${aws_glue_crawler.rental_market_analysis.name}"
      },
      "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler"
    },
    "SNSPublish3": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "${var.topic_arn}",
        "Message": "Greetings Group 4,\n\nYour Glue Crawler is completed successfully."
      },
      "End": true
    }
  }
}
EOF
}

####--------------------------------------- EC2 Instance --------------------------------------------####

# resource "aws_instance" "ec2ingest"{
#   ami            = "ami-0cf10cdf9fcd62d37" 
#   instance_type  = "t2.micro"
#   key_name       = "chin124"
#   vpc_security_group_ids = [aws_security_group.main.id]

#   root_block_device {
#         volume_size = 30  # Set the root volume size to 30 GB
#   }
#    tags = {
#     Name = "Kaggle-EC2"
#   }
# }

# resource "aws_security_group" "main" {
  
#   ingress {
#     from_port   = 22
#     protocol    = "TCP"
#     to_port     = 22
#     cidr_blocks = ["0.0.0.0/0"]

#   }

#   egress {
#     from_port  = 0
#     protocol   = "-1"
#     to_port    = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# ####--------------------------------------- EMR --------------------------------------------####

# resource "aws_emr_cluster" "emr_cluster" {
#   name          = "emr-ingest-rds"
#   release_label = "emr-6.15.0"
#   applications  = ["Spark"]

#   termination_protection            = false
#   keep_job_flow_alive_when_no_steps = true

#   ec2_attributes {
#     emr_managed_master_security_group = aws_security_group.main.id
#     emr_managed_slave_security_group  = aws_security_group.main.id
#     instance_profile                  = "EMR_EC2_DefaultRole"
#   }

#   master_instance_group {
#     instance_type = "m5.xlarge"
#   }

#   ebs_root_volume_size = 30

#   tags = {
#     Name = "EMR-RDS-S3"
#     role = "rolename"
#     env  = "env"
#   }

#   service_role = "EMR_DefaultRole"
# }

# ####--------------------------------------- RDS --------------------------------------------####

# resource "aws_db_instance" "rds_ingest_instance" {
#   engine                   = "mysql"
#   db_name                  = "group4"
#   username                 = "admin"
#   password                 = "123456789"
#   skip_final_snapshot      = true
#   delete_automated_backups = true
#   multi_az                 = false
#   publicly_accessible      = true
#   instance_class           = "db.t3.micro"
#   allocated_storage        = 20
#   availability_zone        = "us-east-1c"
  
# }