NOTEBOOKS := $(wildcard notebooks/*)
DATASETS := $(shell ls -d _data/dataset* | sed -E 's|^[^/]*/||')

.ONESHELL:

.PHONY: all notebooks test test-hardlabel test-softlabel clean FORCE

all: model/classify-model.pkl test

notebooks: $(NOTEBOOKS)

test: test-hardlabel test-softlabel

test-hardlabel: _temp/hardlabel-pred.csv _temp/labels.csv
	python3 -c "import pandas as pd; assert pd.read_csv('$(word 1,$^)').shape == pd.read_csv('$(word 2,$^)').shape"

test-softlabel: _temp/softlabel-pred.csv _temp/labels.csv
	python3 -c "import pandas as pd; assert pd.read_csv('$(word 1,$^)').shape[0] == pd.read_csv('$(word 2,$^)').shape[0]"

clean:
	rm -rf _temp model/*.pkl

# Notebooks

notebooks/%.ipynb: _temp/labels.csv _temp/CV.sigmoid.pkl _temp/CV.sigmoid_ovo.pkl _temp/CV.isotonic.pkl _temp/CV.isotonic_ovo.pkl _temp/CV.temperature.pkl FORCE
	jupyter nbconvert --to notebook --execute --inplace $@

FORCE:  # dummy target to force execution of dependent targets

# Data

_temp/MeanProfiles.h5: $(foreach dataset, $(DATASETS), _data/$(dataset)/MeanProfiles.h5)
	mkdir -p $(@D)
	heavyedge merge $^ -o $@

_temp/knees.csv: $(foreach dataset, $(DATASETS), _data/$(dataset)/knees.csv)
	mkdir -p $(@D)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/canonical.csv: $(foreach dataset, $(DATASETS), _data/$(dataset)/canonical.csv)
	mkdir -p $(@D)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/labels.csv: write-labels.py _temp/knees.csv _temp/canonical.csv
	python3 $^ -o $@

_temp/CV.%.pkl: cv.py _temp/MeanProfiles.h5 _temp/labels.csv
	python3 $^ --calibration $* -o $@

_temp/classify-model.%.pkl: _temp/MeanProfiles.h5 _temp/labels.csv
	mkdir -p $(@D)
	heavyedge --log-level=INFO classify-train --n-splits 5 --calibration $* --random-state 42 $^ -o $@

model/classify-model.pkl: _temp/classify-model.sigmoid.pkl
	cp $^ $@

_temp/softlabel-pred.csv: _temp/MeanProfiles.h5 model/classify-model.pkl
	heavyedge --log-level=INFO classify-predict --batch-size 10 --label-type soft $^ -o $@

_temp/hardlabel-pred.csv: _temp/MeanProfiles.h5 model/classify-model.pkl
	heavyedge --log-level=INFO classify-predict --batch-size 10 --label-type hard $^ -o $@

.SECONDARY:
