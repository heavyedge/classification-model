#!/bin/sh

pip install uv

mkdir -p ./_data/v1/

(
    uv pip install --system -r requirements.txt -r examples/requirements.txt
) &
requirements_pid=$!

(
    curl -LsSf https://hf.co/cli/install.sh | bash
    "$HOME/.local/bin/hf" auth login --token "$HUGGINGFACE_TOKEN"
    if [ "${HEAVYEDGE_TEST_MODE:-}" = "1" ]; then
        profiles="v1/mean_profiles/dataset5.tar.gz"
    else
        profiles="v1/mean_profiles/*.tar.gz"
    fi
    "$HOME/.local/bin/hf" download jeesoo9595/heavyedge-profiles --repo-type dataset --revision v1.0.0rc1 --include "$profiles" --local-dir _data/
    for dataset in _data/v1/mean_profiles/*.tar.gz; do
        stem=$(basename "$dataset" .tar.gz)
        dirname=_data/v1/mean_profiles/"$stem"
        mkdir -p "$dirname"
        tar -xzf "$dataset" -C "$dirname"
    done
) &
profiles_pid=$!

(
  uv pip install --system 'gdown<6.0.0'
  gdown --fuzzy "$LABELS_V1_GDRIVE" -O ./_data/v1/labels.tar
  mkdir -p ./_data/v1/labels
  tar -xf _data/v1/labels.tar -C _data/v1/labels
) &
labels_pid=$!

wait "$requirements_pid"
wait "$profiles_pid"
wait "$labels_pid"
