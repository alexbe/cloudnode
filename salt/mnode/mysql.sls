include:
  - mysql
  
mypypkg:
  pkg.installed:
    - pkgs:
      - python3-mysqldb
      
salt:
  mysql_database.present:
    - name: {{ pillar['returner_db'] }}
    - character_set: utf8
    - collate: utf8_general_ci
    - connection_host: {{ pillar['mnode_hostname'] }}
    - connection_user: {{ pillar['returner_dbuser'] }}
    - connection_pass: {{ pillar['returner_dbpass'] }}
    - require:
      - mysql
      
sql_app_user:
  mysql_user.present:
    - name: {{ pillar['returner_dbuser'] }}
    - password: {{ pillar['returner_dbpass'] }}
    - host: '%'
    - use:
      - mysql_database: salt      
      
returner_dl:
  file.managed:
    - name: /home/{{ pillar['sysuser'] }}/{{ pillar['returner_sql'] }}     
    - user: {{ pillar['sysuser'] }}
    - group: {{ pillar['sysgroup'] }}
    - mode: 0644
    - source: salt://files/{{ pillar['returner_sql'] }}      
