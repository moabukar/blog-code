#!/bin/bash
# Deploy and test a Lambda function with LocalStack

set -e

echo "=== Lambda Example with LocalStack ==="

# Create function code
cat > /tmp/handler.py << 'EOF'
def lambda_handler(event, context):
    name = event.get('name', 'World')
    return {
        'statusCode': 200,
        'body': f'Hello, {name}!'
    }
EOF

# Zip it
cd /tmp && zip -j function.zip handler.py

echo "Creating Lambda function..."
awslocal lambda create-function \
  --function-name hello-function \
  --runtime python3.9 \
  --handler handler.lambda_handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::000000000000:role/lambda-role

echo ""
echo "Invoking Lambda function..."
awslocal lambda invoke \
  --function-name hello-function \
  --payload '{"name": "LocalStack"}' \
  /tmp/output.txt

echo "Response:"
cat /tmp/output.txt
echo ""

echo ""
echo "Updating function code..."
cat > /tmp/handler.py << 'EOF'
import json
def lambda_handler(event, context):
    name = event.get('name', 'World')
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'message': f'Hello, {name}!',
            'event': event
        })
    }
EOF

cd /tmp && zip -j function.zip handler.py
awslocal lambda update-function-code \
  --function-name hello-function \
  --zip-file fileb://function.zip

echo ""
echo "Invoking updated function..."
awslocal lambda invoke \
  --function-name hello-function \
  --payload '{"name": "Updated", "extra": "data"}' \
  /tmp/output.txt

echo "Response:"
cat /tmp/output.txt | jq .
echo ""

# Cleanup
rm -f /tmp/handler.py /tmp/function.zip /tmp/output.txt

echo "=== Done ==="
