#!/bin/sh

pip install uv

mkdir -p ./_data/v1/

(
    uv pip install --system -r requirements.txt
) &
requirements_pid=$!

(
    curl -LsSf https://hf.co/cli/install.sh | bash
    hf auth login --token "$HF_TOKEN"
    hf download jeesoo9595/heavyedge-profiles --repo-type dataset --revision v1.0.0rc0 --include "v1/profiles/*" --local-dir _data/
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
