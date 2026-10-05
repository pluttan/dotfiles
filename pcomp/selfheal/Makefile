# pcomp selfheal — survive a power loss without hands. Signed: pluttan

.PHONY: all install uninstall status

all: install

# root не видит файлы через sshfs (~/mnt/pr), поэтому копия идёт через stdin.
install:
	cat pcomp-selfheal.sh | sudo tee /usr/local/sbin/pcomp-selfheal >/dev/null
	sudo chmod 755 /usr/local/sbin/pcomp-selfheal
	cat pcomp-selfheal.service | sudo tee /etc/systemd/system/pcomp-selfheal.service >/dev/null
	cat pcomp-selfheal.timer | sudo tee /etc/systemd/system/pcomp-selfheal.timer >/dev/null
	sudo mkdir -p /etc/systemd/system/incus.service.d
	cat incus-after-libvirt.conf | sudo tee /etc/systemd/system/incus.service.d/after-libvirt.conf >/dev/null
	sudo systemctl daemon-reload
	sudo systemctl add-wants multi-user.target incus.service
	sudo systemctl enable --now pcomp-selfheal.timer

uninstall:
	sudo systemctl disable --now pcomp-selfheal.timer
	sudo rm -f /etc/systemd/system/multi-user.target.wants/incus.service
	sudo rm -f /usr/local/sbin/pcomp-selfheal /etc/systemd/system/pcomp-selfheal.service /etc/systemd/system/pcomp-selfheal.timer /etc/systemd/system/incus.service.d/after-libvirt.conf
	sudo systemctl daemon-reload

status:
	systemctl list-timers pcomp-selfheal.timer --no-pager | head -2
	journalctl -u pcomp-selfheal -n 10 --no-pager
