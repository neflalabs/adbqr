PREFIX ?= /usr/local

.PHONY: all check install uninstall help

all: check

check:
	@echo "Checking bash syntax..."
	@bash -n bin/adbqr
	@bash -n install.sh
	@bash -n uninstall.sh
	@echo "Syntax OK."

install:
	./install.sh $(PREFIX)

uninstall:
	./uninstall.sh $(PREFIX)

help:
	@echo "adbqr Makefile targets:"
	@echo "  make check      - Verify bash syntax of all scripts"
	@echo "  make install    - Install adbqr to $(PREFIX)/bin"
	@echo "  make uninstall  - Uninstall adbqr from $(PREFIX)/bin"

