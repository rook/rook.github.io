{% assign url = page.url | split: '/' %}
{% assign currentProject = url[2] %}
{% assign currentVersion = url[3] %}
{% assign currentPath = '' %}
{% for i in url %}
{% if forloop.index0 >= 4 %}
{% assign currentPath = currentPath | append: '/' | append: url[forloop.index0] %}
{% endif %}
{% endfor %}
{% assign latestVersion = site.data.projects[0].versions[site.current_release_index].version %}
{% assign currentProjectPath = '/docs/' | append: currentProject | append: '/' %}
{% assign currentProjectVersionPath = currentProjectPath | append: currentVersion | append: '/' %}
{% assign project = site.data.projects | where_exp: 'item', 'item.project == currentProject' | first %}
{% assign filepath = page.url | replace: currentProjectVersionPath %}
