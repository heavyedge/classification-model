#!/bin/sh

set -eu

if ! ./setup.sh; then
  exit 1
fi

case "${MODEL_MODE}" in
  test)
    make_targets="test examples"
    ;;
  post)
    if [ -z "${MODEL_REVISION:-}" ] || [ -z "${MODEL_REPO_ID:-}" ]; then
      echo "::error::Missing Hugging Face model revision or repository." >&2
      exit 2
    fi
    if [ -z "${HUGGINGFACE_TOKEN:-}" ]; then
      echo "::error::Missing Hugging Face token for model download." >&2
      exit 2
    fi

    model_overlay_dir="$(mktemp -d)"
    trap 'rm -rf "$model_overlay_dir"' EXIT INT TERM
    if [ -d model ]; then
      cp -a model/. "$model_overlay_dir/"
    fi
    if ! hf download "${MODEL_REPO_ID}" \
        --repo-type model \
        --revision "${MODEL_REVISION}" \
        --token "${HUGGINGFACE_TOKEN}" \
        --local-dir model; then
      exit 2
    fi
    cp -a "$model_overlay_dir/." model/
    rm -rf model/.cache/huggingface
    make_targets="examples"
    ;;
  release|development)
    make_targets="all"
    ;;
  *)
    echo "::error::Unsupported model mode: ${MODEL_MODE}" >&2
    exit 2
    ;;
esac
