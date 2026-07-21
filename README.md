# HeavyEdge-Classify Model
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Model-orange?logo=huggingface)](https://huggingface.co/jeesoo9595/heavyedge-classify-v1)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/classification-model)

Repository to train and distribute [HeavyEdge-Classify](https://pypi.org/project/heavyedge-classify/) model.

## Setup

```sh
export HF_TOKEN="..."
export LABELS_V1_GDRIVE="..."
./setup.sh
```

## Train & test

```
make
make test
```

## Upload

```
pip install huggingface_hub
python3 upload.py
```

## Contributing

### Configuring git

Configure the local git filter (run once after cloning):

```sh
nbstripout --install --attributes .gitattributes
git config filter.nbstripout.clean "nbstripout"
git config filter.nbstripout.smudge cat
git config filter.nbstripout.required true
```

## Versioning policy

This repository follows semantic versioning with [Python version specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/):

```
N.N.N[{a|b|rc}N][.postN][.devN]
```

- On final release and pre-release (`N.N.N[{a|b|rc}N]`), model is re-trained and deployed to HuggingFace.
- On post-release (`*.postN`), model is deployed to HuggingFace without re-training.
- On developmental release (`*.devN`), model is not deployed to HuggingFace.
