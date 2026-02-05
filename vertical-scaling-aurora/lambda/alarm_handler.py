"""
Aurora Vertical Autoscaler - Alarm Handler
Triggered by CloudWatch Alarm when CPU exceeds threshold.
"""
import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

rds = boto3.client('rds')

# Instance size progression
INSTANCE_SIZES = [
    'db.r6g.large',
    'db.r6g.xlarge',
    'db.r6g.2xlarge',
    'db.r6g.4xlarge',
    'db.r6g.8xlarge',
    'db.r6g.12xlarge',
    'db.r6g.16xlarge'
]

def get_next_size(current_size: str, direction: str = 'up') -> str:
    """Get next instance size up or down."""
    try:
        current_idx = INSTANCE_SIZES.index(current_size)
        if direction == 'up' and current_idx < len(INSTANCE_SIZES) - 1:
            return INSTANCE_SIZES[current_idx + 1]
        elif direction == 'down' and current_idx > 0:
            return INSTANCE_SIZES[current_idx - 1]
    except ValueError:
        logger.error(f"Unknown instance size: {current_size}")
    return current_size

def is_instance_modifying(instance_id: str) -> bool:
    """Check if instance is already being modified."""
    response = rds.describe_db_instances(DBInstanceIdentifier=instance_id)
    status = response['DBInstances'][0]['DBInstanceStatus']
    return status != 'available'

def tag_instance(instance_arn: str, key: str, value: str):
    """Add tag to instance."""
    rds.add_tags_to_resource(
        ResourceName=instance_arn,
        Tags=[{'Key': key, 'Value': value}]
    )

def scale_instance(instance_id: str, new_size: str):
    """Initiate instance modification."""
    logger.info(f"Scaling {instance_id} to {new_size}")
    rds.modify_db_instance(
        DBInstanceIdentifier=instance_id,
        DBInstanceClass=new_size,
        ApplyImmediately=True
    )

def lambda_handler(event, context):
    """Main handler for CloudWatch Alarm events."""
    logger.info(f"Event: {json.dumps(event)}")
    
    # Parse SNS message
    message = json.loads(event['Records'][0]['Sns']['Message'])
    alarm_name = message['AlarmName']
    
    # Extract cluster info from alarm name or tags
    cluster_id = os.environ.get('CLUSTER_IDENTIFIER')
    
    # Get cluster instances
    response = rds.describe_db_clusters(DBClusterIdentifier=cluster_id)
    cluster = response['DBClusters'][0]
    
    # Find reader instances (scale readers first)
    readers = [m for m in cluster['DBClusterMembers'] if not m['IsClusterWriter']]
    writer = [m for m in cluster['DBClusterMembers'] if m['IsClusterWriter']][0]
    
    # Get current instance size
    instance_response = rds.describe_db_instances(
        DBInstanceIdentifier=readers[0]['DBInstanceIdentifier'] if readers else writer['DBInstanceIdentifier']
    )
    current_size = instance_response['DBInstances'][0]['DBInstanceClass']
    new_size = get_next_size(current_size, 'up')
    
    if new_size == current_size:
        logger.info("Already at maximum size")
        return {'statusCode': 200, 'body': 'At max size'}
    
    # Scale first reader (or writer if no readers)
    target = readers[0]['DBInstanceIdentifier'] if readers else writer['DBInstanceIdentifier']
    
    if is_instance_modifying(target):
        logger.info(f"{target} already modifying")
        return {'statusCode': 200, 'body': 'Already modifying'}
    
    # Tag and scale
    instance_arn = f"arn:aws:rds:{os.environ['AWS_REGION']}:{context.invoked_function_arn.split(':')[4]}:db:{target}"
    tag_instance(instance_arn, 'autoscale-status', 'modifying')
    scale_instance(target, new_size)
    
    return {
        'statusCode': 200,
        'body': f'Initiated scale of {target} to {new_size}'
    }
