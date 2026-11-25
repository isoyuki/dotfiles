.PHONY: all home config system claude

all: home config system claude

home:
	stow -v -t ~ home 

config:
	stow -v -t ~/.config config

system:
	sudo stow -v / system

claude:
	mkdir -p ~/.claude/skills
	for s in config/claude/skills/*; do ln -sfn "$$PWD/$$s" ~/.claude/skills/; done
