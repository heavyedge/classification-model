#!/bin/sh

set -eu

if ! ./setup.sh; then
  exit 1
fi

case "${MODEL_MODE}" in
  test)
    HEAVYEDGE_TEST_MODE=1
    make_targets="test"
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
    make_targets="test"
    HEAVYEDGE_TEST_MODE=0
    ;;
  release|development)
    make_targets="all"
    HEAVYEDGE_TEST_MODE=0
    ;;
  *)
    echo "::error::Unsupported model mode: ${MODEL_MODE}" >&2
    exit 2
    ;;
esac

if ! make -j ${CPU_REQUEST} ${make_targets}; then
  exit 3
fi
