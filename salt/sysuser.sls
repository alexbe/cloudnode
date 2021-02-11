sysuser:
  user.present:
    - name: {{ pillar['sysuser'] }}
    - fullname: Abu Abed
    - shell: /bin/zsh
    - home: /home/fred
    - uid: {{ pillar['sysuser_id'] }}
    - gid: {{ pillar['sysgroup_id'] }}
    - groups:
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
      - wheel
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
      - sudo
    {% endif %}    
