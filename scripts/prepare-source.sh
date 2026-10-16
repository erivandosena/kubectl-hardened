#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <diretorio-fonte-original> <diretorio-destino>" >&2
  exit 2
fi

if [ -L "$2" ]; then
  echo "ERRO: destino informado e um link simbolico." >&2
  exit 1
fi

ORIGINAL="$(realpath "$1")"
DESTINO="$(realpath -m "$2")"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
PATCH="$REPO_DIR/patches/kubernetes-v1.35.9-security.patch"

PATCH_SHA256="699a88385a6ea01fe40c6a18ddfa005b8752c008e707fca7edded43a76cefdb0"

command -v rsync >/dev/null
command -v git >/dev/null
command -v sha256sum >/dev/null

test -d "$ORIGINAL"
test -f "$ORIGINAL/go.mod"
test -f "$ORIGINAL/vendor/modules.txt"
test -f "$PATCH"

if [ "$ORIGINAL" = "$DESTINO" ]; then
  echo "ERRO: origem e destino nao podem ser iguais." >&2
  exit 1
fi

case "$DESTINO/" in
  "$ORIGINAL/"*)
    echo "ERRO: destino nao pode estar dentro da origem." >&2
    exit 1
    ;;
esac

case "$ORIGINAL/" in
  "$DESTINO/"*)
    echo "ERRO: origem nao pode estar dentro do destino." >&2
    exit 1
    ;;
esac

if [ -e "$DESTINO" ]; then
  echo "ERRO: destino ja existe; nenhuma alteracao realizada." >&2
  exit 1
fi

echo "$PATCH_SHA256  $PATCH" | sha256sum -c -

if ! grep -Eq '^go 1\.25\.0$' "$ORIGINAL/go.mod"; then
  echo "ERRO: fonte original nao apresenta go 1.25.0." >&2
  exit 1
fi

echo "=== PREPARANDO COPIA ==="

mkdir -p "$DESTINO"

rsync -a \
  --exclude='_output/' \
  "$ORIGINAL/" "$DESTINO/"

echo "=== VALIDANDO PATCH ==="

git -C "$DESTINO" apply --check -p2 "$PATCH"

echo "=== APLICANDO PATCH ==="

git -C "$DESTINO" apply -p2 "$PATCH"

echo "=== VALIDANDO RESULTADO ==="

grep -Eq '^go 1\.26\.0$' "$DESTINO/go.mod"

echo "PASS: fonte corrigida preparada em $DESTINO"
