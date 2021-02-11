

mypy_pkgs:
  pkg.installed:
    - pkgs:
      - mariadb-server
      - python3-mysqldb
{% if grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
      - debconf-utils
{% endif %}
    
{% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}


{% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}

mysql_setup:
  debconf.set:
    - name: mariadb-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql_root_pw', '') }}' }
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql_root_pw', '') }}' }
    - require:
      - pkg: debconf-utils

{% endif %}


mysql:
  service.running:
    - name: mariadb
    - watch:
      - pkg: mariadb-server
      - file: /etc/mysql/my.cnf



