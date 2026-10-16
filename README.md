# kubectl Hardened

Community-maintained, independently built packaging of `kubectl` based on Kubernetes v1.35.9. **Not an official Kubernetes release and not affiliated with or endorsed by the Kubernetes project.**

## Release

- Project release: `v1.35.9-go1.26.9-r1`
- Upstream Kubernetes source tag: `v1.35.9`
- Go compiler used: `go1.26.9`
- Target: Linux amd64, `GOAMD64=v1`, `CGO_ENABLED=0`
- Build flags: `-trimpath -mod=vendor -ldflags="-s -w -X k8s.io/component-base/version.gitVersion=v1.35.9"`
- Binary SHA-256: `fcc015a755bcf666e058811efebc14a233a596f58f67acb37e906e8f7c19bcbf`

## Purpose and security scope

This package includes a `kubectl` binary built from Kubernetes upstream source with patched Go module and vendored dependencies. See `patches/kubernetes-v1.35.9-security.patch` and `provenance/BUILD-METADATA.txt` for the recorded changes and source identifiers. A previous Trivy rootfs scan recognized the Go binary and reported zero detected CVEs within the scanned severities. This is **not** a guarantee that the binary or container image is free of vulnerabilities.

Prior validation recorded 16/16 read-only Kubernetes checks against a v1.35.3 cluster. These checks do not establish exhaustive command compatibility or production readiness for every environment.

## Integrity verification

From the release directory:

```sh
sha256sum -c provenance/SHA256SUMS
printf '%s  %s\n' '699a88385a6ea01fe40c6a18ddfa005b8752c008e707fca7edded43a76cefdb0' 'patches/kubernetes-v1.35.9-security.patch' | sha256sum -c -
```

The binary is intentionally excluded from Git history by `.gitignore` and is intended for separate distribution as a GitHub Release asset. A source checkout does not include `bin/kubectl`. The Dockerfile requires this binary in the local build context. After the official GitHub Release asset is published, obtain the Linux amd64 binary, place it at `bin/kubectl`, and verify its SHA-256 against the value recorded above before running `docker build`. The GitHub Release asset has not yet been published; until then, use only an independently verified local binary. The existing Docker Hub image is distributed separately.

## Container usage

The Docker Hub image `docker.io/erivando/kubectl:v1.35.9` was pushed successfully on 2026-10-16. Docker reported manifest digest `sha256:27191a3d9da9232d5dd040c07b4570b3d5bbbaae595b4698860d384098b6160d`. Independent registry verification and a complete container-image vulnerability scan remain pending.

To use it as a binary donor stage in another Dockerfile:

```Dockerfile
FROM docker.io/erivando/kubectl:v1.35.9 AS kubectl_source

# Example final stage; replace with the application's actual base image.
FROM docker.io/library/alpine:3.18
COPY --from=kubectl_source /usr/local/bin/kubectl /usr/local/bin/kubectl
```

Preserve the actual application's base image and validate the complete resulting image. Record and compare the Docker Hub manifest digest for integrity checks. Use human-readable image tags in downstream manifests and retain digests for internal integrity verification.

## Build and reproducibility limitations

`./scripts/prepare-source.sh <original-source-dir> <patched-source-dir>` applies the recorded patch to a suitable upstream source tree. `./scripts/build-kubectl.sh <patched-source-dir> <output-dir>` builds in the **locally available** image `local/go1269-alpine318-tools-completo:teste` and checks the resulting SHA-256. These scripts do not automatically download the original source or reconstruct the compiler image.

The recorded validation produced byte-identical binaries in the tested environment, with network access disabled during compilation. **Independent reconstruction of the Docker compiler image from publicly versioned build instructions has not yet been demonstrated.** The complete modified source tree (including workspace and vendor content) is not stored in this packaging repository; retain and distribute it separately with appropriate license notices if claiming end-to-end third-party reproducibility.

The optional `scripts/source-snapshot.sh` accepts two arguments: `<source-directory>` and `<destination-directory>`. It creates a source archive and SHA-256 checksum without overwriting existing output files. Functional snapshot tests passed using a temporary test tree: equal and nested destinations were rejected, archive integrity and contents were verified, and overwriting was prevented. A full Kubernetes source snapshot remains untested.

## Upstream attribution and license

Based on Kubernetes upstream source: https://github.com/kubernetes/kubernetes . Kubernetes is licensed under Apache License 2.0; see `LICENSE`. Preserve all applicable upstream and third-party copyright, license, and NOTICE files when redistributing source, binaries, or images. This repository is an independent derivative distribution.

## Security reports

See [SECURITY.md](SECURITY.md). Changes are described in [CHANGELOG.md](CHANGELOG.md).
