import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    # Get instance ID from environment variable
    instance_id = os.environ.get('EC2_INSTANCE_ID')

    if not instance_id:
        print("Error: EC2_INSTANCE_ID environment variable not set.")
        return {
            'statusCode': 400,
            'body': 'EC2_INSTANCE_ID not set'
        }

    print(f"Attempting to start instance: {instance_id}")
    try:
        ec2.start_instances(InstanceIds=[instance_id])
        print(f"Successfully started instance: {instance_id}")
        return {
            'statusCode': 200,
            'body': f'Started instance: {instance_id}'
        }
    except Exception as e:
        print(f"Error starting instance {instance_id}: {e}")
        return {
            'statusCode': 500,
            'body': f'Error starting instance: {e}'
        }
