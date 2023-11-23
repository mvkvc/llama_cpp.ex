LLAMA_URL = https://github.com/ggerganov/llama.cpp
LLAMA_HASH = a6fc554e268634494f33b0de76f9dde650dd292f
PATH_ROOT = $(shell pwd)
PATH_PRIV = $(PATH_ROOT)/priv
PATH_LLAMA = $(PATH_ROOT)/llama.cpp
BINARIES = main server

.PHONY: clean build

.DEFAULT_GOAL := build

clean:
	@rm -rf $(PATH_PRIV)/*
	@rm -rf $(PATH_LLAMA)/*
	@rm -rf ./_build
	@rm -rf ./deps

build: $(PATH_LLAMA)
	@mkdir -p "$(PATH_PRIV)"
	@cd $(PATH_LLAMA) && $(MAKE)
	$(foreach file,$(BINARIES),cp $(PATH_LLAMA)/$(file) $(PATH_PRIV);)

$(PATH_LLAMA):
	@git clone $(LLAMA_URL) $(PATH_LLAMA)
	@cd $(PATH_LLAMA) && git checkout $(LLAMA_HASH)
