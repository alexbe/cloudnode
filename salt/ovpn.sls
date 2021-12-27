
gitfs_remotes:
  - https://github.com/salt-formulas/salt-formula-openvpn.git

pkg:
  pkg.installed:
    - pkgs:
      - mariadb-server
