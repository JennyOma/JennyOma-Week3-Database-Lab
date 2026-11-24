# JennyOma — AWS DynamoDB Document Metadata Lab

## Project Overview

A hands-on AWS Solutions Architect Associate (SAA-C03) lab demonstrating how to create and manage a serverless NoSQL database using Amazon DynamoDB and Terraform.

The project uses fictional document metadata inspired by Lorekeeper, a privacy-first document-processing application. No real personal or legal documents were used.

## Architecture

- **AWS Region:** Stockholm (`eu-north-1`)
- **Database:** Amazon DynamoDB
- **Table:** `JennyOma-Week3-Documents`
- **Billing mode:** On-demand (`PAY_PER_REQUEST`)
- **Infrastructure as Code:** Terraform
- **Testing:** AWS CLI from PowerShell

DynamoDB is a fully managed regional database service. Unlike our earlier Amazon RDS lab, we did not need to provision database servers, VPC subnets or database security groups.

## Table Design

| Attribute | Purpose |
|---|---|
| `UserID` | Partition key |
| `DocumentID` | Sort key |
| `DocumentName` | Fictional document name |
| `ProcessingStatus` | Uploaded, Processing, etc. |
| `UploadedAt` | Upload date |

The combination of `UserID` and `DocumentID` uniquely identifies each document.

**Primary access pattern:** Retrieve all documents belonging to a specific user.

A DynamoDB `Query` retrieves records for a given partition key efficiently.

## Practical Tests Completed

### Create

Used `PutItem` to insert two fictional document records belonging to `USER-101`.

Applied conditional expressions to prevent accidental overwriting of existing records.

### Read

Tested three approaches:

- `Scan` — examines items across the table.
- `Query` — retrieves documents using their partition key.
- `GetItem` — retrieves one document using its complete primary key.

### Update

Used `UpdateItem` to change `DOC-001` from `Uploaded` to `Processing`.

Verified the updated value using `GetItem`.

### Delete

Used `DeleteItem` to remove `DOC-001`.

Verified that the deleted document could no longer be retrieved.

## Security Considerations

Partition keys support efficient retrieval but do not automatically enforce access permissions.

A production application must authenticate users, authorise document ownership and restrict database access using IAM and application-level controls.

This lab used fictional data and did not implement a production application authorisation layer.

## Terraform Commands

Run from the `dynamodb` directory:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Cleanup

All testing was completed successfully.

The DynamoDB table was deleted using:

```bash
terraform destroy
```

Independent verification confirmed:

- Terraform state was empty.
- AWS returned `ResourceNotFoundException` for the table.

The local Terraform configuration and fictional JSON files were retained for documentation and future testing.

## Future Improvements

- Test strongly consistent versus eventually consistent reads.
- Add a Global Secondary Index (GSI) for additional access patterns.
- Implement IAM least-privilege permissions.
- Explore DynamoDB Streams and Time to Live (TTL).
- Evaluate Point-in-Time Recovery (PITR) for production workloads.

## Certification Topics

- DynamoDB versus relational databases
- Partition and sort keys
- Query versus Scan
- On-demand capacity
- NoSQL data modelling
- Conditional writes
- Serverless database architecture
- Cost optimisation