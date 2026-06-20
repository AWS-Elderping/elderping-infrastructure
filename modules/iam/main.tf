# IAM Dedicated Module
# Recommendation:
# In the current EKS cluster design, EKS service account IAM roles (IRSA) are consolidated
# directly inside the EKS module (`modules/eks/`) and operator modules (`modules/external-secrets/`)
# to maintain high cohesion and encapsulate permissions close to the resources using them.
# Centralizing them here is optional but can be done if centralized governance is preferred.

# Placeholder for central IAM roles/policies
# data "aws_caller_identity" "current" {}
