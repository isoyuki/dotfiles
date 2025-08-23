SYSTEM_DIRS := incron usr-bin

ALL_DIRS := $(wildcard */)
SYSTEM_DIRS_WITH_SLASH := $(addsuffix /, $(SYSTEM_DIRS))
USER_DIRS := $(patsubst %/,%,$(filter-out $(SYSTEM_DIRS_WITH_SLASH), $(ALL_DIRS)))

.PHONY: all system

system:
	@echo "--- Stowing system directories one by one ---"
	@for dir in $(SYSTEM_DIRS); do \
		echo "==> Stowing $$dir to /"; \
		sudo stow -v -t / $$dir; \
	done

user:
	@for dir in $(USER_DIRS); do \
		echo "==> Stowing $$dir to ~"; \
		stow -v -t ~ $$dir; \
	done

all: user system

init:
	# sow -v -t ~ systemd
	systemctl --user enable dotfiles-git.service
	systemctl --user start dotfiles-git.service
	systemctl --user enable dotfiles-monitor.path
	systemctl --uesr start dotfiles-monitor.path

