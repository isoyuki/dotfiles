init:
	sow -v -t ~ systemd
	systemctl --user enable dotfiles-git.service
	systemctl --user start dotfiles-git.service
	systemctl --user enable dotfiles-monitor.path
	systemctl --uesr start dotfiles-monitor.path

all:
	stow -v -t ~ *
