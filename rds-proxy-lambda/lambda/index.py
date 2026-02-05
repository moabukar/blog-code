"""
Lambda function that connects to RDS via RDS Proxy using IAM authentication.

Dependencies (add to requirements.txt):
- psycopg2-binary
- boto3 (included in Lambda runtime)
"""
import os
import json
import boto3
import psycopg2
from contextlib import contextmanager


def get_db_auth_token():
    """
    Generate an IAM authentication token for RDS Proxy.
    Token is valid for 15 minutes.
    """
    client = boto3.client('rds', region_name=os.environ['AWS_REGION_NAME'])
    
    token = client.generate_db_auth_token(
        DBHostname=os.environ['DB_PROXY_ENDPOINT'],
        Port=int(os.environ['DB_PORT']),
        DBUsername=os.environ['DB_USER'],
        Region=os.environ['AWS_REGION_NAME']
    )
    
    return token


@contextmanager
def get_connection():
    """
    Context manager for database connections.
    Ensures connection is properly closed after use.
    """
    conn = None
    try:
        token = get_db_auth_token()
        
        conn = psycopg2.connect(
            host=os.environ['DB_PROXY_ENDPOINT'],
            port=int(os.environ['DB_PORT']),
            database=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=token,
            sslmode='require',
            connect_timeout=5
        )
        
        yield conn
        
    finally:
        if conn:
            conn.close()


def handler(event, context):
    """
    Example Lambda handler that queries the database.
    """
    try:
        with get_connection() as conn:
            with conn.cursor() as cursor:
                # Example: Get PostgreSQL version
                cursor.execute("SELECT version();")
                version = cursor.fetchone()[0]
                
                # Example: Simple query
                cursor.execute("SELECT NOW() as current_time;")
                current_time = cursor.fetchone()[0]
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Connected via RDS Proxy!',
                'postgres_version': version,
                'server_time': str(current_time),
                'proxy_endpoint': os.environ['DB_PROXY_ENDPOINT']
            })
        }
    
    except psycopg2.OperationalError as e:
        # Connection errors
        return {
            'statusCode': 503,
            'body': json.dumps({
                'error': 'Database connection failed',
                'details': str(e)
            })
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Internal server error',
                'details': str(e)
            })
        }


def handler_with_transaction(event, context):
    """
    Example showing proper transaction handling.
    Keep transactions short to avoid connection pinning.
    """
    try:
        with get_connection() as conn:
            # Auto-commit is off by default, so we're in a transaction
            with conn.cursor() as cursor:
                # Do your work
                cursor.execute(
                    "INSERT INTO logs (message, created_at) VALUES (%s, NOW())",
                    [event.get('message', 'test')]
                )
                
                # More queries in the same transaction...
                cursor.execute("SELECT COUNT(*) FROM logs;")
                count = cursor.fetchone()[0]
            
            # COMMIT - releases the connection back to the pool
            conn.commit()
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Transaction committed',
                'total_logs': count
            })
        }
    
    except Exception as e:
        # Rollback happens automatically when connection closes
        # if commit wasn't called
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
