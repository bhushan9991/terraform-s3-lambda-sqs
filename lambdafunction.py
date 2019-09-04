import json
import os
import boto3

def lambda_handler(event, context):
    s3_resource = boto3.resource("s3")

    if event['Records'][0]['eventName'] == 'ObjectCreated:Put':
            file_record = event["Records"][0]
            file_name = file_record["s3"]["object"]["key"]
            file_record, file_extension = os.path.splitext(file_name)
            print (file_name)
            # Send file name to SQS queue
            put_messages(file_name)
            
    return "Oops.. Somthing is wrong"

# Initialize sqs queue
def put_messages(lines):
    sqs_resource = boto3.resource("sqs")
    sqs_queue_url = sqs_resource.meta.client.get_queue_url(QueueName="SqsQueue")['QueueUrl']

    sqs_resource.meta.client.send_message(
        QueueUrl=sqs_queue_url,
        MessageBody=lines
    )