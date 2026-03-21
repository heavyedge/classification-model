# HeavyEdge-Classify Model
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Model-orange?logo=huggingface)](https://huggingface.co/jeesoo9595/heavyedge-classify-v1)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/classification-model)

Repository to train and distribute [HeavyEdge-Classify](https://pypi.org/project/heavyedge-classify/) model.

## Download profile data

```
curl -LsSf https://hf.co/cli/install.sh | bash
hf auth login --token [Huggingface Token]
hf download jeesoo9595/heavyedge-profiles-v1 --repo-type dataset --revision v1.0.0 --include "dataset.tar.gz" --local-dir .
mkdir -p _data
tar -xzf dataset.tar.gz -C _data
```

## Download label data

```
pip install gdown
gdown --fuzzy [google drive link] -O labels.tar
tar -xf labels.tar -C _data
```

## Train & test

```
pip install -r requirements.txt
make model/classify-model.pkl
make test
```

## Upload

```
pip install huggingface_hub
python3 upload.py
```

## Versioning policy

The HeavyEdge-Classify model follows semantic versioning.

**Major version**

- Updated if model API is changed.
- Each major version has dedicated repository, e.g., `heavyedge-classify-v1`, `heavyedge-classify-v2`, and so on.

**Minor version**

- Updated if model is re-trained without API change.

**Patch version**

- Bug fix.
- Metadata change.
