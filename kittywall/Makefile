# kittywall — новый фон kitty с wallhaven раз в 15 минут. Signed: pluttan

AGENT := $(HOME)/Library/LaunchAgents/com.pluttan.kittywall.plist

.PHONY: all install uninstall next keep

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

keep:
	$(HOME)/.local/bin/kittywall keep
