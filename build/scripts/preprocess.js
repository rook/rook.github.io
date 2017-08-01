'use strict';

// on publish this script will check all docs projects and versions and prepare static data
// so it does not have to be generated using complicated logic from liquid templates / jekyll

const fs = require('fs')
const jsonfile = require('jsonfile');
const path = require('path')

function getDirectories(srcpath) {
  return fs.readdirSync(srcpath).filter(file => fs.lstatSync(path.join(srcpath, file)).isDirectory());
}

const ROOT_DIR = `${ __dirname }/../../`;

// collect all docs projects
const data = [];
const projects = getDirectories(`${ ROOT_DIR }/docs`);

projects.forEach(project => {

  // get all versions
  const versions = getDirectories(`${ ROOT_DIR }/docs/${ project }`);

  // sort all versions -- bump `master` to top, or versions newest to oldest (we can use float because of major.minor)
  versions.sort((a, b) => {
    return a === 'master' ? -1 : parseFloat(a.substr(1)) < parseFloat(b.substr(1)) ? 1 : -1;
  });

  // save project data with version path mappings
  data.push({
    project: project,
    path: `/docs/${ project }`,
    versions: versions.map((pv) => {
      return {
        version: pv,
        path: `/docs/${ project }/${ pv }`
      };
    })
  });

});

// write json for jekyll (and browser)
jsonfile.writeFileSync('./_data/projects.json', data);
