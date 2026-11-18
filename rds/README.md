# JennyOma — AWS Private RDS Database Lab

## Project Overview

This project demonstrates the deployment of a secure, private Amazon RDS MySQL database using Terraform, with relational data storage, secure credential management and database backup capabilities.

## Architecture

- AWS Region: Stockholm (eu-north-1)
- Dedicated VPC with public and private subnets
- Two Availability Zones
- Amazon RDS MySQL — Single-AZ
- RDS instance class: db.t4g.micro
- Encrypted gp3 database storage — 20 GiB
- EC2 database client — t3.micro
- AWS Systems Manager
- AWS Secrets Manager
- IAM roles and security groups
- Infrastructure as Code using Terraform

## Security Implementation

- No public database access.
- Database connections restricted to the EC2 client's security group on port 3306.
- No inbound SSH access.
- Encrypted database and EC2 storage.
- TLS database connection with server certificate verification.
- RDS-managed master password stored in Secrets Manager.
- Restricted IAM permissions for secret retrieval.
- IMDSv2 enforcement.
- Fictional customer data only.

## Database Testing

Successfully created two relational tables:

- Customers
- Orders

Established relationships using primary and foreign keys, inserted fictional records and retrieved related data using a SQL JOIN.

### Test Results

| Customer | Order ID | Amount |
|---|---:|---:|
| Customer A | 101 | £50.00 |
| Customer B | 102 | £80.00 |
| Customer A | 103 | £25.00 |

Execution result:

`RDS PRIVATE DATABASE TEST SUCCESSFUL`

## Backup and Recovery

- Configured automated backups with one-day retention.
- Created and inspected a manual RDS snapshot.
- Deleted the manual snapshot before infrastructure destruction.
- Studied Multi-AZ failover, Read Replicas and Point-in-Time Recovery.

## Testing Limitations

Multi-AZ deployment, Read Replicas and database restoration were studied theoretically rather than deployed, to minimise costs.

The master database account was used for this temporary learning exercise. Production applications should use dedicated database users with restricted permissions.

The database client uses a public IP address for outbound Systems Manager connectivity. The RDS database remains private.

## Deployment

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Database testing was performed remotely through AWS Systems Manager Run Command using the AWS CLI.

## Cleanup

The manually created database snapshot was deleted separately because it was not managed by Terraform.

All 16 Terraform-managed resources were successfully destroyed using:

```bash
terraform destroy
```

## Future Improvements

- Implement and test Multi-AZ failover.
- Introduce Read Replicas.
- Test Point-in-Time Recovery.
- Configure monitoring and database alarms.
- Implement dedicated application database accounts.
- Strengthen outbound network restrictions.

## Certification Alignment

AWS Certified Solutions Architect Associate (SAA-C03):

- Designing secure architectures
- Designing resilient architectures
- Designing high-performing architectures
- Designing cost-optimised architectures