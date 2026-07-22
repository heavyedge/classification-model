.ONESHELL:

DATASETS_v1 := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),dataset5,$(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename))
PROFILES_v1 = $(shell ls _data/v1/profiles/$(1)/*-Mean.h5)
N_SPLITS := $(if $(filter 1,$(HEAVYEDGE_TEST_MODE)),2,5)
TRAIN_JOBS ?= 1

.PHONY: all models test clean

all: model/requirements.txt model/model.pkl

models: models/v1/model.sigmoid.pkl models/v1/model.sigmoid_ovo.pkl models/v1/model.isotonic.pkl models/v1/model.isotonic_ovo.pkl models/v1/model.temperature.pkl

test: _data/v1/profiles/dataset5/001-Mean.h5 model/model.pkl
	out=$$(mktemp).csv
	trap 'rm -f $$out' EXIT INT TERM
	heavyedge --log-level=INFO classify-predict $^ -o $$out

clean:
	rm -rf _temp models model/*.pkl

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

model/requirements.txt: requirements.txt
	mkdir -p $(@D)
	grep -E '^(heavyedge-classify)([>=<!~,; \t]|$$)' $< > $@

model/model.pkl: models/v1/model.sigmoid.pkl
	mkdir -p $(@D)
	cp $^ $@

.SECONDARY:
