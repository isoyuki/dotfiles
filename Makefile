SYSTEM_DIRS := incron usr-bin

ALL_DIRS := $(wildcard *)
USER_DIRS := $(filter-out $(SYSTEM_DIRS), $(ALL_DIRS))

.PHONY: system all

system:
	sudo stow -v -t / $(SYSTEM_DIRS)

all:
	stow -v -t ~ $(USER_DIRS)

init:
	sow -v -t ~ systemd
	systemctl --user enable dotfiles-git.service
	systemctl --user start dotfiles-git.service
	systemctl --user enable dotfiles-monitor.path
	systemctl --uesr start dotfiles-monitor.path

