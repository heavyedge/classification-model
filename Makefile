.ONESHELL:

DATASETS := $(shell ls -d _data/dataset* | sed -E 's|^[^/]*/||')

.PHONY: all

all: _temp/MeanProfiles.h5 _temp/labels.npy

_temp/MeanProfiles.h5: $(foreach dataset, $(DATASETS), _data/$(dataset)/MeanProfiles.h5)
	mkdir -p $(@D)
	heavyedge merge $^ -o $@

_temp/knees.csv: $(foreach dataset, $(DATASETS), _data/$(dataset)/knees.csv)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/canonical.csv: $(foreach dataset, $(DATASETS), _data/$(dataset)/canonical.csv)
	python3 -c "import pandas as pd; dfs = [pd.read_csv(path) for path in '$^'.split()]; pd.concat(dfs)[['Type']].to_csv('$@', index=False)"

_temp/labels.npy: write-labels.py _temp/knees.csv _temp/canonical.csv
	python3 $^ -o $@
