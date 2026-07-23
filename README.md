# HeavyEdge-Classify Model
[![HuggingFace](https://img.shields.io/badge/HuggingFace-Model-orange?logo=huggingface)](https://huggingface.co/jeesoo9595/heavyedge-classify-v1)
[![GitHub repository](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/heavyedge/classification-model)

Edge classification model for [HeavyEdge-Classify](https://pypi.org/project/heavyedge-classify/).

Provides:
  - Edge classification models.
  - Benchmark results of different models.
  - Example notebooks.

## Usage

This repository provides scripts to train classification models and notebooks to visualize the model performance.

### Cloning the repository

You need:

- `git`
- Python runtime with `pip`

Run the following commands to clone the repository and install the necessary requirements.

```sh
git clone git@github.com:heavyedge/classification-model.git
cd classification-model
pip install -r requirements.txt
```

### Downloading the dataset (Optional)

Run the following commands to download the profile dataset and labels in the `_data` directory.

```sh
export HUGGINGFACE_TOKEN="..."
export LABELS_V1_GDRIVE="..."
./setup.sh
```

### Acquiring the model

The classification model trained by this project can be acquired by downloading it from the [model repository](https://huggingface.co/jeesoo9595/heavyedge-classify-v1).
Alternatively, you can train the model yourself if you have downloaded the dataset.

Either approach creates the trained model in the `model` directory.

#### Direct download

You need:

- [Hugging Face CLI](https://huggingface.co/docs/transformers/en/installation)

Run the following command:

```sh
hf download jeesoo9595/heavyedge-classify-v1 --repo-type model --local-dir model
```

#### Training the model

You need:

- `make`

Run the following command:

```sh
make model
```

You can test the trained model by running:

```sh
make test
```

### Training other models

This repository defines several models with different architectures and hyperparameters, but only the best model is stored in `model` directory and published to the model repository.

To train the other models, run:

```sh
make models
```

The resulting models are saved in the `models` directory.

### Using the trained model

Once a model is trained (either in `model` or `models` directory), you can pass it to the `heavyedge` command line to perform inference.

```sh
heavyedge classify-predict <input.h5> model.pkl -o <output>
```

Refer to the [HeavyEdge-Classify](https://pypi.org/project/heavyedge-classify/) documentation.

### Acquiring the built examples

The benchmark results are visualized as notebooks in the `examples` directory.

The notebook outputs are stripped before being stored in this repository.
To check their outputs, you must acquire the built example notebooks.

You can either download the built notebooks from the [GitHub release](https://github.com/heavyedge/classification-model/releases) artifacts, or build the notebooks yourself if you have acquired the preprocessed data.

#### Building the notebooks

You need:

- `make`

```sh
pip install -r examples/requirements.txt
make examples
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

### Testing

Setting the `HEAVYEDGE_TEST_MODE` environment variable to `1` downloades and trains on only a small subset of data for testing purposes.

```sh
export HEAVYEDGE_TEST_MODE=1
./setup.sh
make model test
```

### Building the container image

The `Dockerfile` is provided to facilitate model distribution without sharing secrets.

After downloading the dataset and training `model` and `models`, build the image with one of the following targets:

- `infer`
  - Includes the trained model (`model`).
  - Includes essential environment for inference.
- `base` (default)
  - Includes the trained model and other models (`model`, `models`).
  - Includes the benchmarks and built examples (`benchmarks`, `examples`).
  - Includes essential environment for inference.
  - Includes non-hidden source files.
- `dev`
  - Includes the dataset (`_data`).
  - Includes the trained model and other models (`model`, `models`).
  - Includes the benchmarks and built examples (`benchmarks`, `examples`).
  - Includes essential environment for inference.
  - Includes all source files.

### Versioning policy

This repository follows semantic versioning with [Python version specifiers](https://packaging.python.org/en/latest/specifications/version-specifiers/):

```
N.N.N[{a|b|rc}N][.postN][.devN]
```

- Final release and pre-release (`N.N.N[{a|b|rc}N]`):
  - Model is re-trained and deployed to HuggingFace.
  - Examples are re-built using the new model and uploaded as release artifacts.
- Post-release (`*.postN`):
  - Model is deployed to HuggingFace without re-building.
    This means that only the metadata will change.
  - Examples are re-built using the previous model and uploaded as release artifacts.
- Developmental release (`*.devN`):
  - Model is not built and not deployed to HuggingFace.
  - Examples are not built and not uploaded as release artifacts.

> **NOTE**: The major version is raised when the model is changed in a backward-incompatible way.
> When the major version is raised, trained model is deployed in the new repository, e.g., `heavyedge-classify-v1`, `heavyedge-classify-v2`, and so on.
