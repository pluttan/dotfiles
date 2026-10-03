# cache-cap — page cache limit for vpnvm. Signed: pluttan

.PHONY: all install uninstall status

all: install

# root не видит файлы через sshfs (~/mnt/pr), поэтому копия идёт через stdin.
install:
	cat cache-cap.sh | sudo tee /usr/local/sbin/cache-cap >/dev/null
	sudo chmod 755 /usr/local/sbin/cache-cap
	cat cache-cap.service | sudo tee /etc/systemd/system/cache-cap.service >/dev/null
	sudo systemctl daemon-reload
	sudo systemctl enable --now cache-cap.service
	sudo systemctl restart cache-cap.service

uninstall:
	sudo systemctl disable --now cache-cap.service
	sudo rm -f /usr/local/sbin/cache-cap /etc/systemd/system/cache-cap.service
	sudo systemctl daemon-reload

status:
	systemctl status cache-cap.service --no-pager | head -5
	journalctl -u cache-cap -n 5 --no-pager
