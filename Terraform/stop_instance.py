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

    print(f"Attempting to stop instance: {instance_id}")
    try:
        ec2.stop_instances(InstanceIds=[instance_id])
        print(f"Successfully stopped instance: {instance_id}")
        return {
            'statusCode': 200,
            'body': f'Stopped instance: {instance_id}'
        }
    except Exception as e:
        print(f"Error stopping instance {instance_id}: {e}")
        return {
            'statusCode': 500,
            'body': f'Error stopping instance: {e}'
        }
