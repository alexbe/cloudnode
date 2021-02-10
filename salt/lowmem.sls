
{% if grains['mem_total'] < 1000 and grains['swap_total'] < 1000 and grains['kernel'] == 'Linux' %}
addswapfile:
  cmd.run:
    - name: "fallocate -l 1G /swapfile && dd if=/dev/zero of=/swapfile bs=1024 count=1048576 && chmod 0600 /swapfile && mkswap /swapfile"
    - creates: /swapfile
swap_on:
  cmd.run:  
    - name: 'swapon /swapfile > /dev/null 2>&1 || swapon --show'
{% endif %}
