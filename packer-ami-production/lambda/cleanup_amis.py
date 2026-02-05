"""
Lambda function to clean up old AMIs
Schedule with EventBridge rule (weekly recommended)

Environment variables:
  APP_NAME: Application name tag to filter AMIs (default: myapp)
  KEEP_COUNT: Number of AMIs to keep (default: 5)
"""

import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Clean up old AMIs for an application, keeping the most recent N.
    
    Args:
        event: Can contain 'app_name' and 'keep_count' to override env vars
        context: Lambda context
    
    Returns:
        dict with 'deleted' count
    """
    ec2 = boto3.client('ec2')
    
    # Get configuration from event or environment
    app_name = event.get('app_name', os.environ.get('APP_NAME', 'myapp'))
    keep_count = int(event.get('keep_count', os.environ.get('KEEP_COUNT', 5)))
    dry_run = event.get('dry_run', False)
    
    logger.info(f"Cleaning up AMIs for {app_name}, keeping {keep_count}")
    
    # Get all AMIs for the application
    response = ec2.describe_images(
        Owners=['self'],
        Filters=[
            {'Name': 'tag:Application', 'Values': [app_name]},
            {'Name': 'state', 'Values': ['available']}
        ]
    )
    
    # Sort by creation date
    amis = sorted(response['Images'], key=lambda x: x['CreationDate'])
    
    logger.info(f"Found {len(amis)} AMIs")
    
    # Calculate how many to delete
    delete_count = len(amis) - keep_count
    
    if delete_count <= 0:
        logger.info(f"Only {len(amis)} AMIs exist, nothing to delete")
        return {
            'deleted': 0,
            'total': len(amis),
            'kept': len(amis)
        }
    
    deleted = 0
    errors = []
    
    for ami in amis[:delete_count]:
        ami_id = ami['ImageId']
        ami_name = ami.get('Name', 'unnamed')
        created_at = ami['CreationDate']
        
        logger.info(f"Processing AMI: {ami_id} ({ami_name}, created {created_at})")
        
        # Get snapshots associated with this AMI
        snapshots = [
            bdm['Ebs']['SnapshotId'] 
            for bdm in ami.get('BlockDeviceMappings', [])
            if 'Ebs' in bdm and 'SnapshotId' in bdm['Ebs']
        ]
        
        if dry_run:
            logger.info(f"  [DRY RUN] Would delete AMI {ami_id} and snapshots {snapshots}")
            deleted += 1
            continue
        
        try:
            # Deregister AMI
            logger.info(f"  Deregistering AMI: {ami_id}")
            ec2.deregister_image(ImageId=ami_id)
            
            # Delete associated snapshots
            for snapshot_id in snapshots:
                logger.info(f"  Deleting snapshot: {snapshot_id}")
                try:
                    ec2.delete_snapshot(SnapshotId=snapshot_id)
                except Exception as e:
                    logger.warning(f"  Failed to delete snapshot {snapshot_id}: {e}")
            
            deleted += 1
            
        except Exception as e:
            logger.error(f"Failed to delete AMI {ami_id}: {e}")
            errors.append({'ami_id': ami_id, 'error': str(e)})
    
    result = {
        'deleted': deleted,
        'total': len(amis),
        'kept': len(amis) - deleted,
        'errors': errors if errors else None
    }
    
    logger.info(f"Cleanup complete: {result}")
    return result


# For local testing
if __name__ == '__main__':
    # Test with dry run
    result = handler({'app_name': 'myapp', 'keep_count': 5, 'dry_run': True}, None)
    print(result)
