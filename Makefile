.PHONY: help run build publish

# https://pages.github.com/versions/
JEKYLL_DOCKER_IMAGE ?= jekyll/jekyll:3.8.6

CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

.DEFAULT: help
help:	## Show this help menu.
	@echo "Usage: make [TARGET ...]"
	@echo ""
	@grep --no-filename -E '^[a-zA-Z_%-. ]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

run:	## run jekyll in development mode
run:
	docker run --rm -it \
		-p 4000:4000 -p 4001:4001 \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll serve --livereload --livereload-port 4001

build:	## build output is in _site
build:
	docker run --rm -it \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		$(JEKYLL_DOCKER_IMAGE) -- \
		jekyll build
	# Copy the "no jekyll build" file so Github pages does not build the gh-pages branch
	cp .nojekyll _site/
	cp .gitignore _site/

bundle_update: ## Update Gemfile.lock (via bundler)
bundle_update:
	docker run --rm -it \
		-v="$(PWD)/vendor/bundle:/usr/local/bundle" \
		-v "$(PWD):/srv/jekyll" \
		jekyll/jekyll -- \
		bundle update

publish:	## push changed files to the live site through the gh-pages branch
publish: build
	$(eval ROOT_DIR = $(shell pwd -P))
	git -C "$(ROOT_DIR)" checkout gh-pages

	rsync -rv --delete \
		--exclude .git/ \
		--exclude _site/ \
		--exlude assets/ \
		--exclude CNAME \
		--exclude docs/ \
		--exclude vendor/ \
		_site/ .

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

	git checkout $(CURRENT_BRANCH)
