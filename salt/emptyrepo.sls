

{% if grains['os_family'] == 'Debian' %}
    
saltrepo_clean:
  file.absent:
    - name: /etc/apt/sources.list.d/saltstack.list
    
saltrepo_setup:
  pkgrepo.managed:
    - humanname: saltstack
    - name: deb http://repo.saltstack.com/py3/{{ grains['os']|lower }}/{{ grains['osrelease'] }}/amd64/latest {{ grains['oscodename'] }} main
    - key_url: https://repo.saltstack.com/py3/{{ grains['os']|lower }}/{{ grains['osrelease'] }}/amd64/latest/SALTSTACK-GPG-KEY.pub
    - file: /etc/apt/sources.list.d/saltstack.list
    - clean_file: True
    - refresh: True    

{% endif %}
