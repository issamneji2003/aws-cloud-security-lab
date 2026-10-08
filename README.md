# AWS Cloud Security Lab – Misconfiguration Detection & Remediation

## Overview
Hands-on security engineering project demonstrating how to build an intentionally vulnerable-by-design AWS environment, detect its security flaws, and successfully harden it using AWS Free Tier resources. This project simulates common cloud misconfigurations and applies industry best practices for remediation.

## Architecture & Resources
- **Cloud Provider:** Amazon Web Services (AWS) (`eu-north-1` / `us-east-1`)
- **Storage:** Amazon S3 (`mon-lab-securite-s3-issamneji`) configured with Server-Side Encryption (SSE-S3), bucket versioning, and strict public access blocking.
- **Compute:** Amazon EC2 (`serveur-vulnerable`, instance ID `i-0123456789abcdef0`) with restricted SSH access.
- **Monitoring & Auditing:** AWS CloudTrail (`mon-lab-trail`) for centralized management event logging.

## Key Skills Demonstrated
- **IAM & Security Posture:** Implementing least-privilege principles and securing credentials.
- **Storage Security:** Enforcing encryption at rest, enabling versioning, and blocking public S3 access vectors.
- **Network Hardening:** Restricting Security Group inbound rules from wide-open (`0.0.0.0/0`) to specific trusted IP addresses (`/32`).
- **Cloud Logging & Compliance:** Configuring AWS CloudTrail and verifying security configurations via AWS CLI / CloudShell.

---

## Lab Progression & Implementation

### Phase 1: Vulnerable-by-Design Setup
* **S3 Misconfiguration:** Created a storage bucket with public-read ACLs and policies containing sensitive data.
* **EC2 Misconfiguration:** Deployed an EC2 instance with an inbound Security Group rule allowing SSH (port 22) from anywhere (`0.0.0.0/0`).

### 🔒 Phase 2: Security Hardening & Remediation
- **S3 Hardening**: Activated **Bucket Versioning**, enforced **AES-256 Server-Side Encryption**, blocked all public access, and configured strict SSL bucket policies (`aws:SecureTransport`).
- **Network & Compute Hardening**: Configured an isolated EC2 instance running with **IMDSv2 required**, **EBS encryption**, **detailed CloudWatch monitoring**, and a hardened **Security Group** restricting SSH ingress strictly to `192.0.2.1/32`.
- **Auditing & Logging**: Deployed secure S3 logging targets for tracking and compliance.

### Phase 3: Verification & CLI Audit
Validated the security posture directly via AWS CloudShell using the AWS CLI:
```bash
aws s3api get-public-access-block --bucket mon-lab-securite-s3-issamneji
---

## 🧪 Testing & Verification Scenarios

To ensure the security controls are actively protecting the environment, the following test scenarios were executed via AWS CLI in AWS CloudShell.

| Security Control | Initial State (Vulnerable) | Hardened State (Secure) | Verification Command & Result |
| :--- | :--- | :--- | :--- |
| **S3 Public Access** | Public ACLs and policies allowed. | All public access blocked (`BlockPublicAcls = true`). | `aws s3api get-public-access-block --bucket mon-lab-securite-terraform-issamneji`<br>👉 *Result: All flags set to `true`.* |
| **S3 Encryption** | Unencrypted objects permitted. | Server-Side Encryption forced (`AES256`). | `aws s3api get-bucket-encryption --bucket mon-lab-securite-terraform-issamneji`<br>👉 *Result: SSEAlgorithm applied by default.* |
| **S3 HTTPS Enforcement** | HTTP plain text transfers allowed. | TLS explicitly enforced via bucket policy (`Deny` if `aws:SecureTransport` is false). | Tested via curl / policy evaluation.<br>👉 *Result: Non-secure requests denied with `403 Access Denied`.* |
| **CI/CD Compliance** | Pipeline blocked by strict Checkov rules. | Automated compliance validated via GitHub Actions. | GitHub Actions Pipeline Status<br>👉*Result: **Passed (Green)**.* |
| **EC2 Security Group** | Inbound SSH open to all (`0.0.0.0/0`). | Inbound SSH strictly restricted to trusted IP (`192.0.2.1/32`) and IMDSv2 enforced. | `aws ec2 describe-security-groups --group-ids <sg-id>`<br>👉 *Result: Restricted CIDR and secure metadata tokens required.* |
---

## 🚀 Deployment Guide

1. Clone the repository:
   ```bash
   git clone [https://github.com/issamneji2003/aws-cloud-security-lab.git](https://github.com/issamneji2003/aws-cloud-security-lab.git)
   cd aws-cloud-security-lab
