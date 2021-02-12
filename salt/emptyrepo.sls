{% if grains['os'] == 'Ubuntu' and grains['oscodename'] == 'focal' %}
    
cleanrepo:
  file.absent:
    - name: /etc/apt/sources.list.d/saltstack.list
    
buggyrepo:
  pkgrepo.managed:
    - humanname: saltstack
    - name: deb https://repo.saltstack.com/apt/ubuntu/20.04/amd64/latest focal main
    - file: /etc/apt/sources.list.d/saltstack.list
    - clean_file: True
    - disabled: True
    - refresh: True

{% endif %}
