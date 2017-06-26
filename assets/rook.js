---
# front matter required for jekyll recognition
---

(() => {

  const Rook = window.Rook;

  Rook.changeVersion = (version) => {
    window.location.href = `${ Rook.current.project.path }/${ version }/${ Rook.current.filepath }`;
  };

})();
