#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <fonte-corrigida> <diretorio-saida>" >&2
  exit 2
fi

SOURCE="$(realpath "$1")"
OUTPUT="$(realpath -m "$2")"

IMAGE="local/go1269-alpine318-tools-completo:teste"
EXPECTED_SHA256="fcc015a755bcf666e058811efebc14a233a596f58f67acb37e906e8f7c19bcbf"

command -v docker >/dev/null
command -v sha256sum >/dev/null

test -d "$SOURCE"
test -f "$SOURCE/go.work"
test -f "$SOURCE/vendor/modules.txt"

if [ "$SOURCE" = "$OUTPUT" ]; then
  echo "ERRO: origem e destino nao podem ser iguais." >&2
  exit 1
fi

case "$OUTPUT/" in
  "$SOURCE/"*)
    echo "ERRO: destino dentro da fonte." >&2
    exit 1
    ;;
esac

case "$SOURCE/" in
  "$OUTPUT/"*)
    echo "ERRO: fonte dentro do destino." >&2
    exit 1
    ;;
esac

if [ -e "$OUTPUT" ] || [ -L "$OUTPUT" ]; then
  echo "ERRO: diretorio de saida ja existe; nenhuma sobrescrita." >&2
  exit 1
fi

docker image inspect "$IMAGE" >/dev/null

mkdir -p "$OUTPUT"

echo "=== COMPILANDO KUBECTL ==="

docker run --rm \
  --network none \
  --user "$(id -u):$(id -g)" \
  -e CGO_ENABLED=0 \
  -e GOOS=linux \
  -e GOARCH=amd64 \
  -e GOAMD64=v1 \
  -e GOTOOLCHAIN=local \
  -e GOWORK=/src/go.work \
  -e GOFLAGS=-mod=vendor \
  -e GOCACHE=/tmp/go-build-cache \
  -v "$SOURCE:/src:ro" \
  -v "$OUTPUT:/out" \
  -w /src \
  "$IMAGE" \
  /bin/sh -ec '
    go version
    go build \
      -trimpath \
      -mod=vendor \
      -ldflags="-s -w -X k8s.io/component-base/version.gitVersion=v1.35.9" \
      -o /out/kubectl \
      ./cmd/kubectl
  '

echo
echo "=== VALIDANDO SHA-256 ==="

echo "$EXPECTED_SHA256  $OUTPUT/kubectl" | sha256sum -c -

echo
echo "=== VALIDANDO VERSAO ==="

"$OUTPUT/kubectl" version --client

echo
echo "PASS: compilacao reproduzivel validada"
