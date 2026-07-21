.ONESHELL:

DATASETS_v1 := $(shell ls -d _data/v1/profiles/dataset* | xargs -n 1 basename)
PROFILES_v1 = $(shell ls _data/v1/profiles/$(1)/*-Mean.h5)

.PHONY: all

all:

_temp/v1/MeanProfiles.h5: $(foreach dataset,$(DATASETS_v1),$(call PROFILES_v1,$(dataset)))
	mkdir -p $(@D)
	heavyedge merge $^ -o $@

.SECONDARY: