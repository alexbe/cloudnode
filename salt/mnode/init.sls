


common_packages:
  pkg.installed:
    - pkgs:
      - wget
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
      - apt-transport-https
      - software-properties-common 
    {% endif %}


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

############## MYSQL setup
foo_db:
  mysql_database.present:
    - name: {{ pillar['SQL_DATABASE'] }}
    - connection_host: {{ pillar['SQL_HOST'] }}
    - connection_user: {{ pillar['SQL_ROOT_USER'] }}
    - connection_pass: {{ pillar['SQL_ROOT_PASSWORD'] }}
    - require:
      - pip: mysql
      
sql_app_user:
  mysql_user.present:
    - name: {{ pillar['SQL_APP_USER'] }}
    - password: {{ pillar['SQL_APP_PASSWORD'] }}
    - host: '%'
    - use:
      - mysql_database: foo_db
      
server_pkgs:
  pkg:
    - installed
    - pkgs:
      - python-dev
    - refresh: True

mysql_python_pkgs:
  pkg.installed:
    - pkgs:
      - libmysqlclient-dev
      - mysql-client
      - python-mysqldb
    - require:
      - pkg: server_pkgs

python-pip:
  pkg:
    - installed
    - refresh: False

mysql:
  pip.installed:
    - require:
      - pkg: python-pip
      - pkg: mysql_python_pkgs      
      
      
      
      
      
      
            
