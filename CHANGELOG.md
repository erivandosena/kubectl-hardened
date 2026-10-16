# Changelog

This project versions an independently built `kubectl` package; it does not replace the official Kubernetes release history.

## [v1.35.9-go1.26.9-r1] - 2026-10-16 (proposed; not yet published)

### Added
- Packaging Dockerfile, source-preparation and build scripts.
- Patch and provenance records for Kubernetes upstream v1.35.9.
- Binary integrity manifest (`provenance/SHA256SUMS`).
- Project README, security policy and change history.

### Changed
- Recorded Go compiler version: 1.26.9.
- Updated Go dependencies as captured in `patches/kubernetes-v1.35.9-security.patch` and `provenance/BUILD-METADATA.txt`.
- Build target recorded as Linux amd64 baseline (`GOAMD64=v1`) with CGO disabled.

### Validation recorded
- Byte-identical rebuilds using the locally available builder image.
- Binary and patch SHA-256 checks passed.
- Three Bash syntax checks passed.
- Previous Trivy rootfs analysis: zero detected CVEs in the configured scope.
- Previous Kubernetes read-only functional checks: 16/16 passed.

### Known limitations
- Builder image reconstruction from independently available build instructions has not been demonstrated.
- Complete modified source and vendored workspace are not included in this packaging repository.
- The planned Docker Hub image must be confirmed as published; its manifest digest and full-image vulnerability status must be independently verified before production use.
- Release asset upload, Git commit, tag and push are not yet performed.
