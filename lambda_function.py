import boto3
import os

ec2 = boto3.client("ec2")
sns = boto3.client("sns")

INSTANCE_ID = os.environ["INSTANCE_ID"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    ec2.reboot_instances(InstanceIds=[INSTANCE_ID])

    message = f"EC2 instance {INSTANCE_ID} rebooted by Lambda"
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject="EC2 Restart Triggered",
        Message=message
    )

    return {
        "statusCode": 200,
        "body": message
    }
