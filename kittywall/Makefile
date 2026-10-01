# kittywall — смена фона kitty раз в 15 минут. Signed: pluttan

AGENT := $(HOME)/Library/LaunchAgents/com.pluttan.kittywall.plist

.PHONY: all install uninstall next

all: install

install:
	mkdir -p $(HOME)/.local/bin $(HOME)/Library/Logs
	install -m 755 kittywall.sh $(HOME)/.local/bin/kittywall
	sed 's|HOME_PLACEHOLDER|$(HOME)|g' com.pluttan.kittywall.plist > $(AGENT)
	launchctl bootout gui/$$(id -u)/com.pluttan.kittywall 2>/dev/null || true
	launchctl bootstrap gui/$$(id -u) $(AGENT)

uninstall:
	launchctl bootout gui/$$(id -u)/com.pluttan.kittywall 2>/dev/null || true
	rm -f $(AGENT) $(HOME)/.local/bin/kittywall

next:
	$(HOME)/.local/bin/kittywall next
