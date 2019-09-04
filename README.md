#Terraform project
#Author: Bhushan Patil (bhushan9991@gmail.com)

Description: Terraform project which will create an AWS Lambda function, SQS Queue, and s3 Event trigger. Lambda will get triggered when a new file is uploaded to an existing S3 bucket and it will send a notification to SQS queue too.

#---------------------------------------------------------------------------------
Requisites: 
1. Terraform
  - You can find the download and install details in this link: https://askubuntu.com/a/983352

2. aws configure
  - awscli need to be configured on the machine because this terraform uses user's access key and secret key to create things on aws.
  - Refer link: https://docs.aws.amazon.com/cli/latest/userguide/install-linux-al2017.html

3. s3 Bucket with input-data folder in it.

#---------------------------------------------------------------------------------
Steps to Run the project on Linux based platform:

- clone git repository on local.

- cd s3-lambda-sqs/

- run below commands under s3-lambda-sqs folder(in sequence)

1. terraform init
(terraform init command is used to initialize a working directory containing Terraform configuration files. This is the first command that should be run after writing a new Terraform configuration or cloning an existing one from version control)

2. terraform apply
(terraform apply command is used to apply the changes on aws)

- When you hit terraform apply, it will ask you a bucket name(in your case it's 'pipelines'), then it will ask you region in which you want to create Lambda and SQS.

- Boom!!!! Your s3 event is set! Lambda is created! Sqs Queue is created!

- Now goto aws console and upload any file in the bucket under input-data folder. you will find the file name with the folder name in SQS. (You can change the name of Lambda and SQS as per your convenience, just you will have to update them in "terraform.tfvars" file)
