.PHONY: all home config system

all: home config system

home:
	stow -v -t ~ home 

config:
	stow -v -t ~/.config config

system:
	sudo stow -v / system
