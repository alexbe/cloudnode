{% set osrelease = salt['grains.get']('osrelease')|string %}
{% set pget = salt['pillar.get'] -%}

gitdir:
  file.directory:
    - name: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}
    - user: {{ pillar['sysuser'] }}
    - group: {{ pillar['sysgroup'] }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
      - ignore_files
      
instdir:
  file.directory:
    - name: {{ pillar['rnode']['instdir'] }}/tools
    - user: {{ pillar['sysuser'] }}
    - group: {{ pillar['sysgroup'] }}
    - dir_mode: 755
    - file_mode: 644
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
      - ignore_files

basepkgs:
  pkg.installed:
    - pkgs:
      - rsync
      - curl 
      - git 
      - gnupg2
      - sed
      - cron
      - gcc
      - libtool
      - autoconf
      - make 
      - automake 
      - autotools-dev
      - pkg-config
      - openssl
      - clang

cleanrepo:
  file.absent:
    - name: /etc/apt/sources.list.d/confluent.list  
    
{% if pget('rnode:kafkarepo') == 'confluent' %}    
kafkarepo:
  pkgrepo.managed:
    - humanname: confluent
    - clean_file: True
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
    - key_url: http://packages.confluent.io/rpm/6.0/archive.key
    - baseurl: http://packages.confluent.io/rpm/6.0/{{ osrelease }}
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
    - name: deb [arch=amd64] https://packages.confluent.io/deb/6.0 stable main
    - key_url: https://packages.confluent.io/deb/6.0/archive.key
    - file: /etc/apt/sources.list.d/confluent.list    
    {% endif %}

{% endif %}
     
addpkgs:
  pkg.installed:
    - refresh: True
    - pkgs:
    {% if grains['os'] == 'RedHat' or grains['os'] == 'CentOS' %}
      - openssl-devel
      - libclang-devel
    {% elif grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
      - libssl-dev
      - libclang-dev
#      - libstdc++-8-dev
    {% endif %}
#      - librdkafka1
      - librdkafka-dev
      - netcat
      - tcpdump
      - jq

{% if grains['rnodebuild_allow'] == True %}

get_rust:
  cmd.run:
    - name: su - -c 'curl https://sh.rustup.rs -sSf | sh -s -- -y' {{ pillar['sysuser'] }}
    - cwd: /home/{{ pillar['sysuser'] }}

cargo_fix:
  cmd.run:
    - name: su - -c 'rustup uninstall stable && rustup install stable' {{ pillar['sysuser'] }}

node_app:
  git.latest:
    - name: https://github.com/tonlabs/ton-labs-node.git
    - target: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/ton-node
    - user: {{ pillar['sysuser'] }}


node_tools:
  git.latest:
    - name: https://github.com/tonlabs/ton-node-tools.git
    - target: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/tools
    - user: {{ pillar['sysuser'] }}
    - submodules: True


tonos_cli:  
  git.latest:
    - name: https://github.com/tonlabs/tonos-cli.git 
    - target: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/tonos-cli   
    - user: {{ pillar['sysuser'] }}

rnodeconf:
  git.latest:
    - name: https://github.com/tonlabs/rustnet.ton.dev.git
    - target: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/rustnet
    - user: {{ pillar['sysuser'] }}


gitprep:
  cmd.run:
    - name: id && pwd && git submodule init && git submodule update 
    - cwd: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/ton-node
    - runas: {{ pillar['sysuser'] }}

rustup_tmp_clean:
  cmd.run:
    - name: su - -c 'cd .rustup/tmp/ && rm -fr ./*' {{ pillar['sysuser'] }} 

build_node:
  cmd.run:
    - name: cargo build --release {{ pillar['rnode']['buildopts'] }}
    - cwd: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/ton-node
    - prepend_path: /home/{{ pillar['sysuser'] }}/.cargo/bin
    - runas: {{ pillar['sysuser'] }} 

build_cli:  
  cmd.run:
    - name: cargo update && cargo build --release
    - cwd: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/tonos-cli
    - runas: {{ pillar['sysuser'] }}

build_tools:  
  cmd.run:
    - name: cargo update && cargo build --release 
    - cwd: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/tools  
    - runas: {{ pillar['sysuser'] }}

put_deploy_script:
  file.managed:
    - name: {{ pillar['rnode']['instdir'] }}/deploy.sh
    - source: salt://files/deploy.sh
    - mode: 755
    - user: {{ pillar['sysuser'] }}
    - group: {{ pillar['sysgroup'] }}
    
deploy:  
  cmd.run:
    - name: {{ pillar['rnode']['instdir'] }}/deploy.sh
    - cwd: {{ pillar['rnode']['instdir'] }}
    - runas: {{ pillar['sysuser'] }}

/etc/systemd/system/ton-node.service:
  file.copy:
    - source: {{ pillar['rnode']['instdir'] }}/setup/ton-node.service
    - mode: 755

rnodebuild_allow:
  grains.present:
    - value: False

{% endif %}#### rnodebuild_allow == True

rest_pkgs:
  pkg.installed:
    - pkgs:
      - salt-minion
    - require:
      - sls: emptyrepo


master_ip:
  cmd.run:
    - name: grep salt /etc/hosts || echo {{ pillar['mnode_ip'] }} salt >> /etc/hosts 

salt-minion:
  service:
    - running
    - enable: True
    - restart: True
    - require:
      - rest_pkgs
    - watch:
      - file: /etc/salt/minion


#linknode:
#  file.hardlink:
#    - name: /home/{{ pillar['sysuser'] }}/{{ pillar['rnode']['git'] }}/ton-node/target/release/ton_node
#    - target: {{ pillar['rnode']['instdir'] }}/ton_node_no_kafka


# /tonlabs/ton-node/target/release/ton_node /ton-node/ton_node_no_kafka
# /tonlabs/ton-node/ton-labs-node-tools/target/release/console /ton-node/tools/
# /tonlabs/ton-node/ton-labs-node-tools/target/release/keygen /ton-node/tools/
# /tonlabs/tonos-cli/target/release/tonos-cli /ton-node/tools/


# salt-ssh -ltrace '*' state.apply rnode pillar='{"instdir": "git"}'
