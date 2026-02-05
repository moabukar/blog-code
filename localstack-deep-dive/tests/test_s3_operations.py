"""
S3 integration tests using LocalStack
"""

import pytest


def test_upload_and_download(s3_client, test_bucket):
    """Test basic S3 upload and download"""
    # Upload
    s3_client.put_object(
        Bucket=test_bucket,
        Key='test-file.txt',
        Body=b'Hello, LocalStack!'
    )
    
    # Download
    response = s3_client.get_object(Bucket=test_bucket, Key='test-file.txt')
    content = response['Body'].read().decode('utf-8')
    
    assert content == 'Hello, LocalStack!'


def test_list_objects(s3_client, test_bucket):
    """Test listing S3 objects"""
    # Create multiple objects
    for i in range(5):
        s3_client.put_object(
            Bucket=test_bucket,
            Key=f'file-{i}.txt',
            Body=f'Content {i}'.encode()
        )
    
    # List
    response = s3_client.list_objects_v2(Bucket=test_bucket)
    
    assert len(response['Contents']) == 5
    keys = [obj['Key'] for obj in response['Contents']]
    assert 'file-0.txt' in keys
    assert 'file-4.txt' in keys


def test_delete_object(s3_client, test_bucket):
    """Test deleting S3 objects"""
    # Create
    s3_client.put_object(
        Bucket=test_bucket,
        Key='to-delete.txt',
        Body=b'Delete me'
    )
    
    # Verify exists
    response = s3_client.list_objects_v2(Bucket=test_bucket)
    assert len(response.get('Contents', [])) == 1
    
    # Delete
    s3_client.delete_object(Bucket=test_bucket, Key='to-delete.txt')
    
    # Verify deleted
    response = s3_client.list_objects_v2(Bucket=test_bucket)
    assert 'Contents' not in response or len(response['Contents']) == 0


def test_metadata(s3_client, test_bucket):
    """Test S3 object metadata"""
    # Upload with metadata
    s3_client.put_object(
        Bucket=test_bucket,
        Key='with-metadata.txt',
        Body=b'Data',
        ContentType='text/plain',
        Metadata={
            'author': 'test',
            'version': '1.0'
        }
    )
    
    # Get metadata
    response = s3_client.head_object(Bucket=test_bucket, Key='with-metadata.txt')
    
    assert response['ContentType'] == 'text/plain'
    assert response['Metadata']['author'] == 'test'
    assert response['Metadata']['version'] == '1.0'


def test_presigned_url(s3_client, test_bucket):
    """Test generating presigned URLs"""
    # Upload object
    s3_client.put_object(
        Bucket=test_bucket,
        Key='presigned-test.txt',
        Body=b'Presigned content'
    )
    
    # Generate presigned URL
    url = s3_client.generate_presigned_url(
        'get_object',
        Params={'Bucket': test_bucket, 'Key': 'presigned-test.txt'},
        ExpiresIn=3600
    )
    
    assert 'presigned-test.txt' in url
    assert 'X-Amz-Signature' in url
