"""
S3 operations with LocalStack
"""
import boto3
import os

def get_s3_client():
    """Create S3 client pointing to LocalStack"""
    return boto3.client(
        's3',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566'),
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID', 'test'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY', 'test'),
        region_name=os.getenv('AWS_DEFAULT_REGION', 'us-east-1')
    )

def create_bucket(bucket_name: str):
    """Create an S3 bucket"""
    s3 = get_s3_client()
    s3.create_bucket(Bucket=bucket_name)
    print(f"Created bucket: {bucket_name}")

def upload_file(bucket_name: str, file_path: str, key: str = None):
    """Upload a file to S3"""
    s3 = get_s3_client()
    if key is None:
        key = os.path.basename(file_path)
    s3.upload_file(file_path, bucket_name, key)
    print(f"Uploaded {file_path} to s3://{bucket_name}/{key}")

def download_file(bucket_name: str, key: str, download_path: str):
    """Download a file from S3"""
    s3 = get_s3_client()
    s3.download_file(bucket_name, key, download_path)
    print(f"Downloaded s3://{bucket_name}/{key} to {download_path}")

def list_objects(bucket_name: str):
    """List objects in a bucket"""
    s3 = get_s3_client()
    response = s3.list_objects_v2(Bucket=bucket_name)
    for obj in response.get('Contents', []):
        print(f"  {obj['Key']} ({obj['Size']} bytes)")

if __name__ == "__main__":
    # Example usage
    bucket = "my-test-bucket"
    create_bucket(bucket)
    
    # Create a test file
    with open("/tmp/test.txt", "w") as f:
        f.write("Hello, LocalStack!")
    
    upload_file(bucket, "/tmp/test.txt")
    list_objects(bucket)
    download_file(bucket, "test.txt", "/tmp/downloaded.txt")
