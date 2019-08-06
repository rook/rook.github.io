# Home

The homepage is `index.html` in the root.

# Docs

Docs live in `/docs/{ project }/{ version }`.  Simply copy a directory full of markdown files with front matter
and place them in the relevant project / version.  After the docs are copied, a build is required for the frontend
to pick up the new version for cross linking between versions of the same project.

# Build

To run the build you must be running a docker host.  Run `make build` which will build a container
with all required dependencies and then run the script to preprocess the project versions and store them statically.

# Publish

Simply commit your changes and do a git push.  There is also `make publish` which integrates with the rook `Makefile`
nicely, and is meant to be run in conjunction with Jenkins CI -- and expects environment variable `DOCS_VERSION`.

# Test

To test your changes to the Rook website locally before committing to the Rook repo, you can generate the docs locally and start a local web server.

To generate the docs:
```bash
# Remove the old master docs and copy your updated docs from your rook repo
rm -fr docs/rook/master
mkdir docs/rook/master
cp -r ../rook/Documentation/* docs/rook/master/

# Starts a live-reloading server that serves the docs at [http://0.0.0.0:4000/docs/rook/master](http://0.0.0.0:4000/docs/rook/master). This requires Docker installed on your machine.
make run
```

When you are done, revert the changes to the repo:
```bash
rm docs/rook/master
git checkout -- docs/rook/master
```

## Test using a container

### Run a jekyll container

* On a SELinux enabled OS:

    ```console
    cd rook.github.io
    sudo docker run -d --name rookio -p 4000:4000 -v $(pwd):/srv/jekyll:Z jekyll/jekyll jekyll serve --watch
    ```

    **NOTE**: Be sure to cd into the *rook.github.io* directory before running the above command as the Z at the end of the volume (-v) will relabel its contents so it can be written from within the container, like running `chcon -Rt svirt_sandbox_file_t -l s0:c1,c2` yourself.

* On an OS without SELinux:

    ```console
    cd rook.github.io
    sudo docker run -d --name rookio -p 4000:4000 -v $(pwd):/srv/jekyll jekyll/jekyll jekyll serve --watch
    ```

### View the site

Visit `http://0.0.0.0:4000` in your local browser.


# Github Pages & Jekyll

To avoid additional pre-processing work, we push a project to `rook.github.io` which recognizes the project
is a Jekyll project and processes the static site after the code is pushed.  While this saves us time
processing the Jekyll site manually, it does limit our ability to run custom code such as custom Jekyll
plugins.  Github only allows for [public popular whitelisted gems](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/).

Improvements in the future may include setting up our own build step to process the static site and test before pushing.
