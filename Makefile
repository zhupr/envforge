.PHONY: help install install-offline uninstall update container proxy

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install everything
	./install.sh

install-zsh: ## Install zsh config only
	./install.sh --zsh --tools

install-nvim: ## Install neovim config only
	./install.sh --nvim

install-cpp: ## Install C++ toolchain
	./install.sh --cpp

install-python: ## Install Python environment
	./install.sh --python

install-go: ## Install Go toolchain
	./install.sh --go

install-rust: ## Install Rust toolchain
	./install.sh --rust
install-herdr: ## Install Herdr multiplexer
	./install.sh --herdr

install-omp: ## Install omp agent config
	./install.sh --omp

install-interactive: ## Interactive component picker
	./install.sh --interactive

install-offline: ## Install from pre-downloaded offline packages
	./install.sh --offline

uninstall: ## Remove symlinks
	./scripts/uninstall.sh

update: ## Update zimfw + nvim plugins + tmux framework
	zsh -c 'ZIM_HOME=~/.zim; source ~/.zim/zimfw.zsh update' 2>/dev/null || true
	./scripts/nvim_sync.sh
	cd ~/.tmux && git pull 2>/dev/null || true

nvim-sync: ## Sync Neovim plugins and wait for Mason installs
	./scripts/nvim_sync.sh

download-offline: ## Download all packages for offline use
	./scripts/download_offline.sh

proxy: ## Show proxy/mirror configuration for China
	@echo "Source the proxy script: source scripts/setup_proxy.sh"

container: ## Build and start dev container
	docker compose -f containers/docker-compose.yml up -d --build

container-shell: ## Shell into dev container
	docker compose -f containers/docker-compose.yml exec dev zsh

container-stop: ## Stop dev container
	docker compose -f containers/docker-compose.yml down
