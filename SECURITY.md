# Security Policy

## Supported release

The initial project release is `v1.35.9-go1.26.9-r1`. No ongoing support or security-update service is guaranteed. Upstream Kubernetes support policies are independent of this project.

## Reporting a vulnerability

Please avoid publishing exploit details or credentials in public issues. Use the repository's GitHub **Report a vulnerability** / private vulnerability reporting feature if enabled. If that feature is unavailable, open a public issue requesting a private reporting channel **without disclosing sensitive technical details**. No private response-time SLA is promised.

## What was validated

- A SHA-256 comparison confirmed the packaged binary matches the recorded checksum.
- A SHA-256 comparison confirmed the recorded security patch matches its expected checksum.
- Bash syntax checks passed for three scripts.
- Previous evidence records byte-identical rebuilds in the same available local builder environment.
- Previous Trivy rootfs analysis recognized the Go binary and reported **zero detected CVEs within the configured scan scope**.
- Previous read-only functional checks against Kubernetes v1.35.3 passed 16/16.

These results are point-in-time observations, not guarantees of absence of vulnerabilities. They do not constitute a full security audit, prove any published Docker Hub image is vulnerability-free, or establish independent reconstruction of the builder image.

## Distribution safeguards

Verify release checksums and provenance before deployment. Scan the complete downstream container image, not only `kubectl`. Keep secrets, kubeconfigs, private keys and environment files out of Git commits and release artifacts. Preserve upstream and dependency license notices.
