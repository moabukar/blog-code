# Custom SSM Document: Enable S3 Bucket Versioning
resource "aws_ssm_document" "enable_s3_versioning" {
  name            = "Custom-EnableS3BucketVersioning"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<-DOC
    description: Enable versioning on S3 bucket
    schemaVersion: '0.3'
    assumeRole: '{{ AutomationAssumeRole }}'
    parameters:
      BucketName:
        type: String
        description: Name of the S3 bucket
      AutomationAssumeRole:
        type: String
        description: IAM role for automation
    mainSteps:
      - name: EnableVersioning
        action: aws:executeAwsApi
        inputs:
          Service: s3
          Api: PutBucketVersioning
          Bucket: '{{ BucketName }}'
          VersioningConfiguration:
            Status: Enabled
        isEnd: true
  DOC
}

# Custom SSM Document: Enable EC2 IMDSv2
resource "aws_ssm_document" "enable_imdsv2" {
  name            = "Custom-EnableEC2IMDSv2"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<-DOC
    description: Enable IMDSv2 on EC2 instance
    schemaVersion: '0.3'
    assumeRole: '{{ AutomationAssumeRole }}'
    parameters:
      InstanceId:
        type: String
        description: EC2 Instance ID
      AutomationAssumeRole:
        type: String
        description: IAM role for automation
    mainSteps:
      - name: EnableIMDSv2
        action: aws:executeAwsApi
        inputs:
          Service: ec2
          Api: ModifyInstanceMetadataOptions
          InstanceId: '{{ InstanceId }}'
          HttpTokens: required
          HttpEndpoint: enabled
        isEnd: true
  DOC
}

# Custom SSM Document: Tag Non-Compliant Resource
resource "aws_ssm_document" "tag_non_compliant" {
  name            = "Custom-TagNonCompliantResource"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<-DOC
    description: Tag resource as non-compliant for review
    schemaVersion: '0.3'
    assumeRole: '{{ AutomationAssumeRole }}'
    parameters:
      ResourceArn:
        type: String
        description: ARN of the resource
      ViolationType:
        type: String
        description: Type of compliance violation
        default: unknown
      AutomationAssumeRole:
        type: String
        description: IAM role for automation
    mainSteps:
      - name: TagResource
        action: aws:executeAwsApi
        inputs:
          Service: resourcegroupstaggingapi
          Api: TagResources
          ResourceARNList:
            - '{{ ResourceArn }}'
          Tags:
            compliance-status: non-compliant
            violation-type: '{{ ViolationType }}'
            requires-review: 'true'
        isEnd: true
  DOC
}

# Custom SSM Document: Stop Non-Compliant EC2 Instance
resource "aws_ssm_document" "stop_ec2_instance" {
  name            = "Custom-StopNonCompliantEC2"
  document_type   = "Automation"
  document_format = "YAML"

  content = <<-DOC
    description: Stop non-compliant EC2 instance (use with caution)
    schemaVersion: '0.3'
    assumeRole: '{{ AutomationAssumeRole }}'
    parameters:
      InstanceId:
        type: String
        description: EC2 Instance ID
      AutomationAssumeRole:
        type: String
        description: IAM role for automation
    mainSteps:
      - name: StopInstance
        action: aws:executeAwsApi
        inputs:
          Service: ec2
          Api: StopInstances
          InstanceIds:
            - '{{ InstanceId }}'
      - name: WaitForStop
        action: aws:waitForAwsResourceProperty
        timeoutSeconds: 300
        inputs:
          Service: ec2
          Api: DescribeInstances
          InstanceIds:
            - '{{ InstanceId }}'
          PropertySelector: '$.Reservations[0].Instances[0].State.Name'
          DesiredValues:
            - stopped
        isEnd: true
  DOC
}
