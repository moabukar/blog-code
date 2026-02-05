"""
DynamoDB integration tests using LocalStack
"""

import pytest


def test_put_and_get_item(test_table):
    """Test basic DynamoDB put and get"""
    # Put item
    test_table.put_item(Item={
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com'
    })
    
    # Get item
    response = test_table.get_item(Key={'id': '123'})
    
    assert 'Item' in response
    assert response['Item']['name'] == 'Test User'
    assert response['Item']['email'] == 'test@example.com'


def test_update_item(test_table):
    """Test updating DynamoDB items"""
    # Create item
    test_table.put_item(Item={
        'id': '456',
        'count': 0
    })
    
    # Update
    test_table.update_item(
        Key={'id': '456'},
        UpdateExpression='SET #count = #count + :inc',
        ExpressionAttributeNames={'#count': 'count'},
        ExpressionAttributeValues={':inc': 1}
    )
    
    # Verify
    response = test_table.get_item(Key={'id': '456'})
    assert response['Item']['count'] == 1


def test_query_items(dynamodb_resource):
    """Test querying with sort key"""
    # Create table with sort key
    table = dynamodb_resource.create_table(
        TableName='query-test',
        KeySchema=[
            {'AttributeName': 'pk', 'KeyType': 'HASH'},
            {'AttributeName': 'sk', 'KeyType': 'RANGE'}
        ],
        AttributeDefinitions=[
            {'AttributeName': 'pk', 'AttributeType': 'S'},
            {'AttributeName': 'sk', 'AttributeType': 'S'}
        ],
        BillingMode='PAY_PER_REQUEST'
    )
    table.wait_until_exists()
    
    try:
        # Add items
        for i in range(5):
            table.put_item(Item={
                'pk': 'user#1',
                'sk': f'order#{i}',
                'total': i * 100
            })
        
        # Query
        response = table.query(
            KeyConditionExpression='pk = :pk AND begins_with(sk, :prefix)',
            ExpressionAttributeValues={
                ':pk': 'user#1',
                ':prefix': 'order#'
            }
        )
        
        assert response['Count'] == 5
    finally:
        table.delete()


def test_batch_write(test_table):
    """Test batch writing items"""
    from boto3.dynamodb.conditions import Key
    
    # Batch write
    with test_table.batch_writer() as batch:
        for i in range(25):
            batch.put_item(Item={
                'id': f'batch-{i}',
                'data': f'Item {i}'
            })
    
    # Verify count with scan
    response = test_table.scan(Select='COUNT')
    assert response['Count'] == 25


def test_delete_item(test_table):
    """Test deleting items"""
    # Create
    test_table.put_item(Item={'id': 'to-delete', 'data': 'temp'})
    
    # Verify exists
    response = test_table.get_item(Key={'id': 'to-delete'})
    assert 'Item' in response
    
    # Delete
    test_table.delete_item(Key={'id': 'to-delete'})
    
    # Verify deleted
    response = test_table.get_item(Key={'id': 'to-delete'})
    assert 'Item' not in response
