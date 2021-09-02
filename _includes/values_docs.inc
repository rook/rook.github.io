{% assign url = page.url | split: '/' %}
{% assign currentProject = url[2] %}
{% assign currentVersion = url[3] %}
{% assign currentPath = '' %}
{% for i in url %}
{% if forloop.index0 >= 4 %}
  {% assign currentPath = currentPath | append: '/' | append: url[forloop.index0] %}
{% endif %}
{% endfor %}
{% assign current_project_index = 2 %}
{% if currentProject == 'cassandra' %}
  {% assign current_release_index = site.current_cassandra_release_index %}
  {% assign current_project_index = 0 %}
  {% assign current_project_name = 'Cassandra' %}
{% elsif currentProject == 'nfs' %}
  {% assign current_release_index = site.current_nfs_release_index %}
  {% assign current_project_index = 1 %}
  {% assign current_project_name = 'NFS' %}
{% else %}
  {% assign current_release_index = site.current_ceph_release_index %}
  {% assign current_project_index = 2 %}
  {% assign current_project_name = 'Ceph' %}
{% endif %}
{% assign latestVersion = site.data.projects[current_project_index].versions[current_release_index].version %}
{% assign latestCassandraVersion = site.data.projects[0].versions[site.current_cassandra_release_index].version %}
{% assign latestNFSVersion = site.data.projects[1].versions[site.current_nfs_release_index].version %}
{% assign latestCephVersion = site.data.projects[2].versions[site.current_ceph_release_index].version %}

{% assign currentProjectPath = '/docs/' | append: currentProject | append: '/' %}
{% assign currentProjectVersionPath = currentProjectPath | append: currentVersion | append: '/' %}
{% assign project = site.data.projects | where_exp: 'item', 'item.project == currentProject' | first %}
{% assign filepath = page.url | replace: currentProjectVersionPath %}
