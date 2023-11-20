PATH_ROOT = $(shell pwd)
PATH_PRIV = $(PATH_ROOT)/priv
PATH_LLAMA = $(PATH_ROOT)/llama.cpp
LLAMA_URL = https://github.com/ggerganov/llama.cpp
LLAMA_HASH = a6fc554e268634494f33b0de76f9dde650dd292f
BINS = $(PATH_LLAMA)/main

.DEFAULT_GLOBAL := build

build: $(PATH_LLAMA)
	@mkdir -p "$(PATH_PRIV)"
	@cd $(PATH_LLAMA) && $(MAKE)
	@cp $(BINS) $(PATH_PRIV)

$(PATH_LLAMA):
	@git clone $(LLAMA_URL) $(PATH_LLAMA)
	@cd $(PATH_LLAMA) && git checkout $(LLAMA_HASH)
