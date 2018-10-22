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

# Test

To test your changes to the Rook website locally before committing to the Rook repo, you can generate the docs locally and start a local web server.

To generate the docs:
```bash
# Remove the old master docs and copy your updated docs from your rook repo
rm -fr docs/rook/master
mkdir docs/rook/master
cp -r ../rook/Documentation/* docs/rook/master/

# Generate the docs. This requires Docker installed on your machine.
build/run.sh
```
When running the script, it will start a Jekyll Docker container which will then build and rebuild the docs on changes
to the `_site/` directory. Please note that Jekyll takes some time to rebuild the docs on changes (the time varies depending on your hardware specs).
When you see the message `Auto-regeneration: enabled for '/srv/jekyll'`, the docs are generated. If you update the docs, the scripts will be automatically
re-generated until you stop the script.

After the docs are generated, start the local web server:
```bash
cd _site/
# For Python2 users
python -m SimpleHTTPServer 8000
# For Python3 users
python3 -m http.server 8000
```

To see the docs, open your browser to [http://127.0.0.1:8000/docs/rook/master](http://127.0.0.1:8000/docs/rook/master).

When you are done, revert the changes to the repo:
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
