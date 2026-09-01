SHELL := /bin/bash

.PHONY: all build check-dub

all: build

check-dub:
	@command -v dub >/dev/null 2>&1 || { \
		echo "Error: dub was not found in PATH"; \
		exit 1; \
	}

build: check-dub
	@set -e; \
	cd modules/xcb-module-grammar; \
	dub build; \
	./xcb-module-grammar > ../../source/language/grammar.d; \
	cd ../../; \
	dub build; \
	mkdir -p bin/$${OSTYPE:-linux-gnu}; \
	mv xcbasic3 bin/$${OSTYPE:-linux-gnu}/xcbasic3; \
	echo "Build completed successfully. Executable is located in bin/$${OSTYPE:-linux-gnu}/xcbasic3"
