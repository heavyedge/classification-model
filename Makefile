.ONESHELL:

DATASETS_v1 := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),dataset5,$(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename))
PROFILES_v1 = $(shell ls _data/v1/profiles/$(1)/*-Mean.h5)
N_SPLITS := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),2,5)
TRAIN_JOBS ?= 1
CALIBRATION_METHODS_v1 := sigmoid isotonic sigmoid_ovo isotonic_ovo temperature

.PHONY: all model models examples test clean .FORCE

all: model

model: model/model.pkl

models: $(foreach method,$(CALIBRATION_METHODS_v1),models/v1/model.$(method).pkl)

examples: $(wildcard examples/v1/*.ipynb)

test: _data/v1/profiles/dataset5/001-Mean.h5 model/model.pkl
	out=$$(mktemp).csv
	trap 'rm -f $$out' EXIT INT TERM
	heavyedge --log-level=INFO classify-predict $^ -o $$out

clean:
	rm -rf _temp benchmarks models model/*.pkl

_temp/v1/MeanProfiles.h5: $(foreach dataset,$(DATASETS_v1),$(call PROFILES_v1,$(dataset)))
	mkdir -p $(@D)
	heavyedge merge $^ -o $@

_temp/v1/knees.csv: $(foreach dataset, $(DATASETS_v1), _data/v1/labels/$(dataset)/knees.csv)
	mkdir -p $(@D)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/v1/canonical.csv: $(foreach dataset, $(DATASETS_v1), _data/v1/labels/$(dataset)/canonical.csv)
	mkdir -p $(@D)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/v1/labels.csv: scripts/v1/write-labels.py _temp/v1/knees.csv _temp/v1/canonical.csv
	python3 $^ -o $@

models/v1/model.%.pkl: _temp/v1/MeanProfiles.h5 _temp/v1/labels.csv
	mkdir -p $(@D)
	heavyedge --log-level=INFO classify-train --n-splits $(N_SPLITS) --calibration $* --n-jobs $(TRAIN_JOBS) --random-state 42 $^ -o $@

model/model.pkl: models/v1/model.sigmoid.pkl
	mkdir -p $(@D)
	cp $^ $@

benchmarks/v1/CV.%.csv: scripts/v1/cv.py _temp/v1/MeanProfiles.h5 _temp/v1/labels.csv
	mkdir -p $(@D)
	python3 $^ --calibration=$* --n-splits $(N_SPLITS) -o $@

benchmarks/v1/CalibrationCurve.%.csv: scripts/v1/calibration-curve.py _temp/v1/labels.csv benchmarks/v1/CV.%.csv
	mkdir -p $(@D)
	python3 $^ --n-bins 5 -o $@

examples/v1/calibration_curve.ipynb: $(foreach method,$(CALIBRATION_METHODS_v1),benchmarks/v1/CalibrationCurve.$(method).csv) .FORCE
	jupyter nbconvert --to notebook --execute --inplace $@

.FORCE:  # dummy target to force execution of dependent targets

.SECONDARY:
