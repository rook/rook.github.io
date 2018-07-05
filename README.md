# Home

The homepage is `index.html` in the root.

# Docs

Docs live in `/docs/{ project }/{ version }`.  Simply copy a directory full of markdown files with front matter
and place them in the relevant project / version.  After the docs are copied, a build is required for the frontend
to pick up the new version for cross linking between versions of the same project.

# Build

To run the build script, you must be running a docker host.  Run `build/build.sh` which will build a container
with all required dependencies and then run the script to preprocess the project versions and store them statically.

# Publish

Simply commit your changes and do a git push.  There is also `build/publish.sh` which integrates with the rook `Makefile`
nicely, and is meant to be run in conjunction with Jenkins CI -- and expects environment variable `DOCS_VERSION`.

# Run

To test your changes to the Rook website locally before committing, you can run the `build/run.sh` script. The script
requires Docker installed on your machine.
When running the script, it will start a Jekyll Docker container which will then build and rebuild the docs on changes
to the `_site/` directory. Viewing the docs in your browser can be achieved by running:
```
cd _site/
# For Python2 users
python -m SimpleHTTPServer 8000
# For Python3 users
python3 -m http.server 8000
```
Go to [http://127.0.0.1:8000](http://127.0.0.1:8000) to view the docs.
Please note that Jekyll takes some time to rebuild the docs on changes (the time varies depending on your hardware specs).

# Github Pages & Jekyll

To avoid additional pre-processing work, we push a project to `rook.github.io` which recognizes the project
is a Jekyll project and processes the static site after the code is pushed.  While this saves us time
processing the Jekyll site manually, it does limit our ability to run custom code such as custom Jekyll
plugins.  Github only allows for [public popular whitelisted gems](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/).

Improvements in the future may include setting up our own build step to process the static site and test before pushing.
