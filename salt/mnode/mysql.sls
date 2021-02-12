include:
  - mysql
  
mypypkg:
  pkg.installed:
    - pkgs:
      - python3-mysqldb
    - require:
      - sls: emptyrepo 
         
sql_app_user:
  mysql_user.present:
    - connection_user: root
    - connection_pass: {{ pillar['mysql_root_pw'] }}
    - connection_charset: utf8
    - name: {{ pillar['returner_dbuser'] }}
    - password: {{ pillar['returner_dbpass'] }}
    - host: '%'

sql_app_user_grants:
  mysql_grants.present:
    - connection_user: root
    - connection_pass: {{ pillar['mysql_root_pw'] }}
    - connection_charset: utf8  
    - grant: all privileges
    - database: salt.*
    - user: {{ pillar['returner_dbuser'] }} 
    - host: '%'    
    - require:
      - sql_app_user
  
sql_app_db:
  mysql_database.present:
    - name: {{ pillar['returner_db'] }}
    - character_set: utf8
    - collate: utf8_general_ci
    - connection_host: localhost
    - connection_user: {{ pillar['returner_dbuser'] }}
    - connection_pass: {{ pillar['returner_dbpass'] }}
    - require:
      - sql_app_user
      - sql_app_user_grants
      
returner_dl:
  file.managed:
    - name: /home/{{ pillar['sysuser'] }}/{{ pillar['returner_sql'] }}     
    - user: {{ pillar['sysuser'] }}
    - group: {{ pillar['sysgroup'] }}
    - mode: 0644
    - source: salt://files/{{ pillar['returner_sql'] }}      

rerurner_tables:
  mysql_query.run_file
    - database: salt
    - query_file: /home/{{ pillar['sysuser'] }}/{{ pillar['returner_sql'] }} 
    
    
