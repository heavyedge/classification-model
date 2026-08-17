.ONESHELL:
.SECONDEXPANSION:
.SECONDARY:
.PHONY: all models examples tests clean .FORCE
# Dummy target to ensure that prerequisite files are built.
.FORCE:

all: models examples

models: models-v1

examples: examples-v1

tests: test-v1

clean:
	shopt -s globstar nullglob
	rm -rf _temp benchmarks models/**/*.pkl

include make/v1.mk
