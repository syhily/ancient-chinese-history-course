PANDOC ?= pandoc
BUILD_DIR := build
EPUB := $(BUILD_DIR)/中国古代史教程.epub
MANUSCRIPT := $(sort $(wildcard manuscript/*.md))

COVER := $(firstword $(wildcard assets/cover.jpg assets/cover.png))
ifneq ($(COVER),)
COVER_OPT := --epub-cover-image=$(COVER)
endif

.PHONY: build clean

build: $(EPUB)

$(EPUB): metadata.yaml $(MANUSCRIPT) assets/epub.css scripts/build.sh scripts/newpage.lua scripts/ascii-heading-ids.lua scripts/chapter-titlepage.lua scripts/pangu.lua $(COVER)
	@bash scripts/build.sh

clean:
	rm -rf $(BUILD_DIR)
