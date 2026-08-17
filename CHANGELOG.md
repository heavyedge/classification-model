# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0rc1] - 2026-08-17

- v1
  - Model: `heavyedge-classify==1.4.0`
  - Dataset: `heavyedge/profiles:v1.0.0`

### Fixed

- Deploy now keeps going even if previous step(s) failed.

## [1.0.0rc0] - 2026-08-17

- v1
  - Model: `heavyedge-classify==1.4.0`
  - Dataset: `heavyedge/profiles:v1.0.0`

## [1.0.0a2] - 2026-07-31

- v1
  - Model: `heavyedge-classify==1.4.0`
  - Dataset: `heavyedge/profiles:v1.0.0rc3`

### Added

- `examples/v1/profiles.ipynb` is added.

### Changed

- Modified profile dataset to `heavyedge/profiles:v1.0.0rc3`.
- HuggingFace repository is now `heavyedge/classifier-v*`.

### Fixed

- `numpy < 2.4.0` is specified to avoid error.

## [1.0.0a1] - 2026-07-24

### Changed

- Models are now in `models/v1/classifiers/` directory, instead of `models/v1/models/`.

## [1.0.0a0] - 2026-07-24

### Added

- v1
  - Model: `heavyedge-classify==1.4.0`
  - Dataset: `jeesoo9595/heavyedge-dataset:v1.0.0rc1`
