# AWS Cloud Security Lab – Misconfiguration Detection & Remediation

## Overview
Hands-on security engineering project demonstrating how to build an intentionally vulnerable-by-design AWS environment, detect its security flaws, and successfully harden it using AWS Free Tier resources. This project simulates common cloud misconfigurations and applies industry best practices for remediation.

## Architecture & Resources
- **Cloud Provider:** Amazon Web Services (AWS) (`eu-north-1` / `us-east-1`)
- **Storage:** Amazon S3 (`mon-lab-securite-s3-issamneji`) configured with Server-Side Encryption (SSE-S3), bucket versioning, and strict public access blocking.
- **Compute:** Amazon EC2 (`serveur-vulnerable`, instance ID `i-09acc999b769d5df`) with restricted SSH access.
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

### Phase 2: Security Hardening & Remediation
1. **S3 Hardening:**
   - Enabled **SSE-S3** encryption by default.
   - Activated **Bucket Versioning** to protect against accidental deletion or modification.
   - Applied **Block Public Access** settings to completely shut down public exposure.
2. **Network Hardening:**
   - Updated the EC2 Security Group inbound rule to replace `0.0.0.0/0` with a strict personal IP restriction (`196.238.53.151/32`).
3. **Auditing & Logging:**
   - Deployed **AWS CloudTrail** (`mon-lab-trail`) to capture API activity and track administrative changes.

### Phase 3: Verification & CLI Audit
Validated the security posture directly via AWS CloudShell using the AWS CLI:
```bash
aws s3api get-public-access-block --bucket mon-lab-securite-s3-issamneji
