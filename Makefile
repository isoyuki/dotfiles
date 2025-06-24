init:
	sow -v -t ~ systemd
	systemctl --user enable dotfiles-git.service
	systemctl --user start dotfiles-git.service
	systemctl --user enable dotfiles-monitor.path
	systemctl --uesr start dotfiles-monitor.path

system:
	sudo stow -v -t / incron
	sudo stow -v -t / usr-bin

all:
	stow -v -t ~ *
