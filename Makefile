.PHONY: help run build publish

# https://pages.github.com/versions/
JEKYLL_DOCKER_IMAGE ?= jekyll/jekyll:3.8.6

.DEFAULT: help
help:	## Show this help menu.
	@echo "Usage: make [TARGET ...]"
	@echo ""
	@grep --no-filename -E '^[a-zA-Z_%-. ]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

run:	## run jekyll in development mode
run: _data/projects.json
	docker run --rm -it \
		-p 4000:4000 -p 4001:4001 \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll serve --livereload --livereload-port 4001

build:	## build output is in _site
build: _data/projects.json
	docker run --rm -it \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll build

bundle_update: ## Update Gemfile.lock (via bundler)
bundle_update: _data/projects.json
	docker run --rm -it \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		jekyll/jekyll -- \
		bundle update

publish:	## push new changes to the live site
publish: _data/projects.json
	$(eval ROOT_DIR = $(shell pwd -P))
	git -C "$(ROOT_DIR)" add -A
	@if git -C "$(ROOT_DIR)" diff-index --cached --quiet HEAD --; then\
		echo "no changes detected";\
	else \
		echo "committing changes...";\
		git -C "$(ROOT_DIR)" -c user.email="cncf-rook-info@lists.cncf.io" -c user.name="Rook" commit --message="docs snapshot for rook version \`$(DOCS_VERSION)\`"; \
		echo "pushing changes..."; \
		git -C "$(ROOT_DIR)" push; \
		echo "rook.github.io changes published"; \
	fi

_data/projects.json:	## generate projects.json
_data/projects.json: node_modules docs $(wildcard docs/*)
	node preprocess.js
	@touch _data/projects.json

node_modules:	## install node_modules
node_modules: package.json package-lock.json
	npm ci
	@touch node_modules
