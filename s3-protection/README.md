# JennyOma — AWS S3 Data Protection and Recovery Lab

## Project Overview

A hands-on AWS Solutions Architect Associate (SAA-C03) lab demonstrating secure Amazon S3 storage, object versioning, accidental-deletion recovery and lifecycle management using Terraform and the AWS CLI.

This lab uses fictional document content.It is separate from the Lorekeeper application.

## Architecture

- **AWS Region:** Stockholm (`eu-north-1`)
- **Storage:** Amazon S3
- **Infrastructure as Code:** Terraform
- **Encryption:** SSE-S3 (`AES256`)
- **Public access:** Blocked
- **Versioning:** Enabled
- **Bucket deletion protection:** `force_destroy = false`

## Terraform Resources

Five resources were created:

1. S3 bucket
2. S3 bucket versioning configuration
3. Server-side encryption configuration
4. Public access block
5. Lifecycle configuration

## Lifecycle Rules

- Expire noncurrent object versions after 30 days.
- Remove expired object delete markers where eligible.
- Abort incomplete multipart uploads after seven days.

**Important:** The 30-day noncurrent-version period starts when a version becomes noncurrent, not necessarily when a user requests deletion.

These lifecycle rules do not implement a complete application-level Trash system.

## Practical Tests

### 1. Object upload and versioning

Uploaded a fictional court letter as Version 1.

Modified the document and uploaded it again using the same object key.

Verified that S3 retained both versions:

- Version 2 — Current
- Version 1 — Noncurrent

### 2. Accidental deletion

Deleted the object without specifying a version ID.

Verified that:

- S3 created a delete marker.
- Normal object requests returned `404 Not Found`.
- Both historical versions remained stored.

### 3. Recovery from deletion

Identified the current delete marker using the AWS CLI.

Permanently removed the delete marker by specifying its version ID.

Successfully downloaded the restored current document:

`Version 2 - Updated fictional court letter.`

### 4. Recovery of an older version

Retrieved the original version using its specific version ID.

Verified the recovered content:

`Version 1 - Original fictional court letter.`

Retrieving the older version did not change which version was current in S3.

## Security and Privacy Lessons

- Versioning protects recoverability but does not prevent all forms of deletion.
- Deleting an object normally does not permanently delete stored versions.
- Previous versions continue consuming storage until removed.
- Access to historical versions must be appropriately restricted.
- Permanent deletion requires removing all applicable object versions and delete markers.
- Encryption, retention and user authorisation are separate security concerns.

## Relevance to Lorekeeper

The experiment provides a technical foundation for a proposed recoverable Trash feature.

Lorekeeper's future production design should consider:

- Document ownership checks before recovery.
- A clearly disclosed recovery period.
- Application-managed deletion deadlines.
- Deletion of associated OCR text, summaries and processing records.
- Verified permanent erasure workflows.
- Applicable legal retention obligations.

This lab does not implement those production features.

## Cleanup and Cost Control

All stored document versions were permanently removed before infrastructure destruction.

Terraform reported:

`Destroy complete! Resources: 5 destroyed.`

Independent verification confirmed:

- Empty Terraform state.
- S3 bucket no longer exists (`404 Not Found`).

No temporary AWS infrastructure was intentionally retained.

## SAA-C03 Topics Covered

- S3 Versioning
- Object version IDs
- Delete markers
- Accidental-deletion recovery
- SSE-S3 encryption
- S3 Block Public Access
- S3 Lifecycle rules
- Storage cost optimisation
- Infrastructure cleanup with Terraform