# Home

This is the GitHub Pages repository that currently powers rook.io using the Jekyll static site generator.

# Contributing

If you would like to contribute to Rook's documentation, please open a PR on the main [rook repository](https://github.com/rook/rook/tree/master/Documentation). Any changes will automatically be mirrored here to be hosted.

You may preview any changes locally by following the [test](#test) section below.

The homepage is `index.html` in the root.

# Docs

Docs live in `/docs/{ project }/{ version }`.  Simply copy a directory full of markdown files with front matter
and place them in the relevant project / version.  After the docs are copied, a build is required for the frontend
to pick up the new version for cross linking between versions of the same project.

# Build

To run the build you must be running a Docker host.  Run `make build` which will build a container
with all required dependencies and then run the script to preprocess the project versions and store them statically.

# Publish

Simply commit your changes, do a git push and then to get the changes to the `gh-pages` branch, run  `make publish`.

# Test

To test your changes to the Rook website locally before committing to the Rook repo, you can generate the docs locally and start a local web server.

To generate and view the docs:

```bash
# Remove the old master docs and copy your updated docs from your rook repo
rm -fr docs/rook/master
mkdir docs/rook/master
cp -r ../rook/Documentation/* docs/rook/master/

# Start a live-reloading server that serves the docs at [http://0.0.0.0:4000/docs/rook/master](http://0.0.0.0:4000/docs/rook/master). This requires Docker to be installed on your machine.
make run
```

When you are done, revert the changes to this repo:

```bash
rm docs/rook/master
git checkout -- docs/rook/master
```

# Github Pages & Jekyll

To avoid additional pre-processing work, we push a project to `rook.github.io` which recognizes the project
is a Jekyll project and processes the static site after the code is pushed.  While this saves us time
processing the Jekyll site manually, it does limit our ability to run custom code such as custom Jekyll
plugins.  Github only allows for [public popular whitelisted gems](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/).

Improvements in the future may include setting up our own build step to process the static site and test before pushing.

# Licensing

The source code in this repository is licensed under the [Apache 2.0](LICENSE) license.

The documentation is distributed under [CC-BY-4.0](LICENSE-DOCS).
