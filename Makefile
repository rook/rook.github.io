.PHONY: help run build publish

# https://pages.github.com/versions/
JEKYLL_DOCKER_IMAGE ?= docker.io/library/ruby:3.1

# Gems go to vendor/bundle (gitignored, excluded from the site). Runs as the calling user so files stay theirs.
JEKYLL_DOCKER_RUN = docker run --rm -i \
	--user "$(shell id -u):$(shell id -g)" -e HOME=/tmp \
	-e BUNDLE_PATH=/srv/jekyll/vendor/bundle -e PAGES_REPO_NWO=rook/rook.github.io \
	--volume="$(PWD):/srv/jekyll" --workdir /srv/jekyll

CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

.DEFAULT: help
help:	## Show this help menu.
	@echo "Usage: make [TARGET ...]"
	@echo ""
	@grep --no-filename -E '^[a-zA-Z_%-. ]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo ""

run:	## run jekyll in development mode
run:
	$(JEKYLL_DOCKER_RUN) -p 4000:4000 -p 4001:4001 $(JEKYLL_DOCKER_IMAGE) \
		bash -c 'bundle install && bundle exec jekyll serve --host 0.0.0.0 --livereload --livereload-port 4001'

build:	## build output is in _site
build:
	mkdir -p _site/
	$(JEKYLL_DOCKER_RUN) $(JEKYLL_DOCKER_IMAGE) \
		bash -c 'bundle install && bundle exec jekyll build'
	# Correct permissions when running in CI
	if test "$$CI" = "true"; then sudo chown -R "$(shell id -u):$(shell id -g)" _site/; fi
	# Copy the "no jekyll build" file so Github pages does not build the gh-pages branch
	cp .nojekyll _site/
	cp .gitignore _site/

bundle_update: ## Update Gemfile.lock (via bundler)
bundle_update:
	$(JEKYLL_DOCKER_RUN) $(JEKYLL_DOCKER_IMAGE) \
		bash -c 'bundle update'

publish:	## push changed files to the live site through the gh-pages branch
publish: build
	$(eval ROOT_DIR = $(shell pwd -P))
	git -C "$(ROOT_DIR)" checkout gh-pages

	rsync -rv --delete \
		--exclude .git/ \
		--exclude _site/ \
		--exclude assets/ \
		--exclude CNAME \
		--exclude docs/ \
		--exclude vendor/ \
		_site/ .

	git -C "$(ROOT_DIR)" add -A
	@if git -C "$(ROOT_DIR)" diff-index --cached --quiet HEAD --; then\
		echo "no changes detected"; \
	else \
		echo "committing changes..."; \
		git -C "$(ROOT_DIR)" -c user.email="cncf-rook-info@lists.cncf.io" -c user.name="Rook" commit --message="website changes $(shell date +"%Y-%m-%d %H:%M:%S")"; \
		echo "pushing changes..."; \
		git -C "$(ROOT_DIR)" push; \
		echo "rook.github.io changes published"; \
	fi

	git checkout $(CURRENT_BRANCH)
