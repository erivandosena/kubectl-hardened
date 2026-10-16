FROM docker.io/library/alpine:3.18

ARG KUBECTL_SHA256=fcc015a755bcf666e058811efebc14a233a596f58f67acb37e906e8f7c19bcbf

LABEL org.opencontainers.image.title="kubectl-hardened" \
      org.opencontainers.image.description="kubectl v1.35.9 recompilado com Go 1.26.9 e dependencias atualizadas para corrigir vulnerabilidades conhecidas." \
      org.opencontainers.image.authors="Erivando Sena <erivandosena@gmail.com>" \
      org.opencontainers.image.vendor="Erivando Sena" \
      org.opencontainers.image.version="v1.35.9" \
      org.opencontainers.image.source="https://github.com/erivandosena/kubectl-hardened" \
      org.opencontainers.image.licenses="Apache-2.0" \
      io.github.erivandosena.kubectl.go-version="1.26.9" \
      io.github.erivandosena.kubectl.architecture="amd64-v1" \
      io.github.erivandosena.kubectl.security-scanner="Trivy" \
      io.github.erivandosena.kubectl.security-result="0 vulnerabilities detected" \
      io.github.erivandosena.kubectl.security-scope="Go binary; container image pending validation" \
      io.github.erivandosena.kubectl.security-policy="No vulnerability exclusions or suppressions" \
      io.github.erivandosena.kubectl.binary-sha256="${KUBECTL_SHA256}"

COPY --chmod=0755 bin/kubectl /usr/local/bin/kubectl

RUN echo "${KUBECTL_SHA256}  /usr/local/bin/kubectl" | sha256sum -c - \
    && /usr/local/bin/kubectl version --client=true

ENTRYPOINT ["/usr/local/bin/kubectl"]
