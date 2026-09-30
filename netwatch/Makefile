# netwatch — Wi-Fi watchdog for the Mac. Signed: pluttan

AGENT := $(HOME)/Library/LaunchAgents/com.pluttan.netwatch.plist

.PHONY: all install uninstall report

all: install

install:
	mkdir -p $(HOME)/.local/bin $(HOME)/Library/Logs/netwatch
	install -m 755 netwatch.sh $(HOME)/.local/bin/netwatch
	sed 's|HOME_PLACEHOLDER|$(HOME)|g' com.pluttan.netwatch.plist > $(AGENT)
	launchctl bootout gui/$$(id -u)/com.pluttan.netwatch 2>/dev/null || true
	launchctl bootstrap gui/$$(id -u) $(AGENT)

uninstall:
	launchctl bootout gui/$$(id -u)/com.pluttan.netwatch 2>/dev/null || true
	rm -f $(AGENT) $(HOME)/.local/bin/netwatch

report:
	$(HOME)/.local/bin/netwatch report 3
