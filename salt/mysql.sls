

mypkg:
  pkg.installed:
    - pkgs:
      - mariadb-server

{% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}


{% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}

debconfpkg:
  pkg.installed:
    - pkgs:
      - debconf-utils
      
mysql_setup:
  debconf.set:
    - name: mariadb-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql_root_pw', '') }}' }
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ salt['pillar.get']('mysql_root_pw', '') }}' }
    - require:
      - debconfpkg

{% endif %}


mysql:
  service.running:
    - name: mariadb
    - watch:
      - pkg: mariadb-server
      - file: /etc/mysql/my.cnf



