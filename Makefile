.PHONY: common

p1: common
common:
	cd common && stow -v -t ~ * && cd ../
