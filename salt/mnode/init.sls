

common_packages:
  pkg.installed:
    - pkgs:
      - wget
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
      - apt-transport-https
      - software-properties-common 
    {% endif %}
    
include:
  - mnode.mysql

grafana_repo:
  pkgrepo.managed:
    - humanname: grafana
    - clean_file: True
    - gpgcheck: 1
    - key_url: https://packages.grafana.com/gpg.key
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
    - baseurl: https://packages.grafana.com/oss/rpm
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
    - name: deb https://packages.grafana.com/oss/deb stable main
    - file: /etc/apt/sources.list.d/grafana.list    
    {% endif %}

     
rest_pkgs:
  pkg.installed:
    - pkgs:
      - grafana
