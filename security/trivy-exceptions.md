# Trivy Exceptions

## AWS-0053 - Public ALB

Resource:
modules/alb/aws_lb.main

Decision:
Accepted Risk

Reason:
This ALB is intentionally internet-facing.

Status: Suppressed

## AWS-0054 (CRITICAL): Listener for application load balancer does not use HTTPS.
Resource:
modules/alb/aws_lb.main

Decision:
Accepted Risk

Reason:
The architecture is for test purpose only and there is no real domain name.

Status: Suppressed

## AWS-0028 (HIGH): Instance does not require IMDS access to require a token.
Resource:
modules/bastion/main.tf

Decision:
Fix

Reason:
Need "Require IMDSv2."

Status: Fixed

## AWS-0104 (CRITICAL): Security group rule allows unrestricted egress to any IP address.
Resource:
modules/bastion/main.tf

Decision:
Accepted Risk

Reason:
Need to connect to AWS to download patches or updates

Status: Suppressed

## AWS-0131 (HIGH): Root block device is not encrypted.

Resource:
modules/bastion/main.tf
modules/ec2-instance/main.tf

Decision:
Fix

Status: Fixed

## AWS-0080 (HIGH): Instance does not have storage encryption enabled.
Resource:
modules/database/main.tf

Decision:
Fix

Status: Fixed

## AWS-0095 (HIGH): Topic does not have encryption enabled.
Resource:
modules/sns/main

Decision:
Fix

Status: Fixed

## AWS-0136 (HIGH): Topic encryption does not use a customer managed key.
Resource:
modules/sns/main

Decision:
Accepted Risk

Reason:
This is test architecture and the SNS topic does not contain any sensitve information for us to create CMK. The AWS managed key provides encryption at rest which is sufficient for this architecture.

Status: Suppressed