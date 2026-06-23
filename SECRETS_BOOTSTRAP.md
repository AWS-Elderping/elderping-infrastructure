# AWS Secrets Manager Bootstrapping for ElderPing

The ElderPing Kubernetes workloads retrieve database passwords and JWT signing keys dynamically from AWS Secrets Manager using the **External Secrets Operator (ESO)**. 

To successfully deploy and run the microservices, the following secrets must be pre-populated in your AWS account in the active environment region (e.g. `us-east-1`).

---

## 1. Required Secrets Configuration

### Secret A: Database Connection Secret
*   **Secret Name**: `elderpinq/dev/db`
*   **Secret Type**: Key/Value
*   **Required Keys**:
    *   `password`: The password used to connect to the PostgreSQL RDS database instances.
*   **Consuming Services**:
    *   All 11 backend microservices (e.g., `auth-service`, `health-service`, `appointment-service`, etc.) fetch this password to authenticate their PostgreSQL client connections.

#### Sample Payload Structure:
```json
{
  "password": "SuperSecurePassword123!"
}
```

---

### Secret B: JWT Authentication Secret
*   **Secret Name**: `elderpinq/dev/jwt`
*   **Secret Type**: Key/Value
*   **Required Keys**:
    *   `secret`: The cryptographic signature key used to sign and verify JSON Web Tokens (JWT) for user sessions and API authentication.
*   **Consuming Services**:
    *   All 11 backend microservices read this signing key to validate authentication headers on inbound requests.

#### Sample Payload Structure:
```json
{
  "secret": "supersecretjwt_change_in_production"
}
```

---

## 2. Bootstrapping Secrets via AWS CLI

Run the following commands to initialize these secrets in a fresh AWS account. Replace the dummy values with your desired production-strength passwords and secret keys.

### Step 1: Create the Database Secret
```bash
aws secretsmanager create-secret \
    --name elderpinq/dev/db \
    --description "Database password for ElderPing dev microservices" \
    --secret-string '{\"password\":\"SuperSecurePassword123!\"}' \
    --region us-east-1
```

### Step 2: Create the JWT Secret
```bash
aws secretsmanager create-secret \
    --name elderpinq/dev/jwt \
    --description "JWT signing key for ElderPing dev microservices" \
    --secret-string '{\"secret\":\"supersecretjwt_change_in_production\"}' \
    --region us-east-1
```

> [!NOTE]
> Ensure the secrets are created in the **same region** specified in your Terraform variables (e.g. `us-east-1`). The External Secrets Operator `ClusterSecretStore` uses the region of the cluster to connect to Secrets Manager.
