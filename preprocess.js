"use strict";

// on publish this script will check all docs projects and versions and prepare static data
// so it does not have to be generated using complicated logic from liquid templates / jekyll

const fs = require("fs");
const jsonfile = require("jsonfile");
const path = require("path");
const semver = require("semver");

function getDirectories(srcpath) {
  return fs
    .readdirSync(srcpath)
    .filter(file => fs.lstatSync(path.join(srcpath, file)).isDirectory());
}

const ROOT_DIR = `${__dirname}`;

// collect all docs projects with versions (forcing master to the end)
const projects = [
  ...getDirectories(`${ROOT_DIR}/docs`).map(project => {
    // get all versions except master
    const versions = getDirectories(`${ROOT_DIR}/docs/${project}`)
      .filter(v => v !== "latest")
      .sort((a, b) =>
        semver.rcompare(semver.coerce(a).version, semver.coerce(b).version)
      );
    return {
      project,
      path: `/docs/${project}`,
      versions: [...versions, "latest"].map(version => ({
        version,
        path: `/docs/${project}/${version}`
      }))
    };
  })
];

// write json for jekyll (and browser)
jsonfile.writeFileSync(`${ROOT_DIR}/_data/projects.json`, projects);
