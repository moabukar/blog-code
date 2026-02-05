"""
pytest fixtures for LocalStack integration tests
"""

import pytest
import boto3
import os

@pytest.fixture(scope='session')
def localstack_endpoint():
    """Get LocalStack endpoint URL"""
    return os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566')


@pytest.fixture(scope='session')
def aws_credentials():
    """Fake AWS credentials for LocalStack"""
    return {
        'aws_access_key_id': 'test',
        'aws_secret_access_key': 'test',
        'region_name': 'us-east-1'
    }


@pytest.fixture(scope='session')
def s3_client(localstack_endpoint, aws_credentials):
    """Create S3 client for LocalStack"""
    return boto3.client(
        's3',
        endpoint_url=localstack_endpoint,
        **aws_credentials
    )


@pytest.fixture(scope='session')
def dynamodb_resource(localstack_endpoint, aws_credentials):
    """Create DynamoDB resource for LocalStack"""
    return boto3.resource(
        'dynamodb',
        endpoint_url=localstack_endpoint,
        **aws_credentials
    )


@pytest.fixture(scope='session')
def sqs_client(localstack_endpoint, aws_credentials):
    """Create SQS client for LocalStack"""
    return boto3.client(
        'sqs',
        endpoint_url=localstack_endpoint,
        **aws_credentials
    )


@pytest.fixture(scope='session')
def sns_client(localstack_endpoint, aws_credentials):
    """Create SNS client for LocalStack"""
    return boto3.client(
        'sns',
        endpoint_url=localstack_endpoint,
        **aws_credentials
    )


@pytest.fixture(scope='function')
def test_bucket(s3_client):
    """Create a test S3 bucket, clean up after test"""
    bucket_name = 'test-bucket'
    s3_client.create_bucket(Bucket=bucket_name)
    yield bucket_name
    
    # Cleanup
    try:
        objects = s3_client.list_objects_v2(Bucket=bucket_name).get('Contents', [])
        for obj in objects:
            s3_client.delete_object(Bucket=bucket_name, Key=obj['Key'])
        s3_client.delete_bucket(Bucket=bucket_name)
    except Exception:
        pass


@pytest.fixture(scope='function')
def test_table(dynamodb_resource):
    """Create a test DynamoDB table, clean up after test"""
    table_name = 'test-table'
    table = dynamodb_resource.create_table(
        TableName=table_name,
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    table.wait_until_exists()
    yield table
    
    # Cleanup
    table.delete()


@pytest.fixture(scope='function')
def test_queue(sqs_client):
    """Create a test SQS queue, clean up after test"""
    queue_name = 'test-queue'
    response = sqs_client.create_queue(QueueName=queue_name)
    queue_url = response['QueueUrl']
    yield queue_url
    
    # Cleanup
    sqs_client.delete_queue(QueueUrl=queue_url)
