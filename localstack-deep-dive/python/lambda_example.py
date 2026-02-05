"""
Lambda operations with LocalStack
"""
import boto3
import json
import zipfile
import os
import tempfile

def get_lambda_client():
    """Create Lambda client pointing to LocalStack"""
    return boto3.client(
        'lambda',
        endpoint_url=os.getenv('AWS_ENDPOINT_URL', 'http://localhost:4566'),
        aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID', 'test'),
        aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY', 'test'),
        region_name=os.getenv('AWS_DEFAULT_REGION', 'us-east-1')
    )

def create_lambda_zip(handler_code: str) -> bytes:
    """Create a zip file containing the Lambda handler"""
    with tempfile.NamedTemporaryFile(suffix='.zip', delete=False) as tmp:
        with zipfile.ZipFile(tmp.name, 'w') as zf:
            zf.writestr('handler.py', handler_code)
        with open(tmp.name, 'rb') as f:
            return f.read()

def create_function(function_name: str, handler_code: str):
    """Create a Lambda function"""
    client = get_lambda_client()
    zip_content = create_lambda_zip(handler_code)
    
    response = client.create_function(
        FunctionName=function_name,
        Runtime='python3.9',
        Role='arn:aws:iam::000000000000:role/lambda-role',
        Handler='handler.lambda_handler',
        Code={'ZipFile': zip_content},
        Timeout=30,
        MemorySize=128
    )
    print(f"Created function: {function_name}")
    return response

def invoke_function(function_name: str, payload: dict):
    """Invoke a Lambda function"""
    client = get_lambda_client()
    response = client.invoke(
        FunctionName=function_name,
        Payload=json.dumps(payload)
    )
    result = json.loads(response['Payload'].read())
    print(f"Response: {result}")
    return result

if __name__ == "__main__":
    # Example handler code
    handler_code = '''
def lambda_handler(event, context):
    name = event.get('name', 'World')
    return {
        'statusCode': 200,
        'body': f'Hello, {name}!'
    }
'''
    
    function_name = "hello-function"
    create_function(function_name, handler_code)
    invoke_function(function_name, {'name': 'LocalStack'})
