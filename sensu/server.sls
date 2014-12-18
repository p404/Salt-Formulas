##############################################################################
# server.sls
#
# Sensu Server Formula
# Sensu + Sensu client + Sensu API + (Uchiwa + Nginx conf)
##############################################################################

{% set uchiwa_server_name = salt['pillar.get']('uchiwa:domain', 'monitor.4talent.cl') %}

# Include all common sensu configuration
include:
  - sensu.common

# Checks that all monitor server run
sensu-checks-master-json:
  file.managed:
    - name: /etc/sensu/conf.d/checks-master.json
    - source: salt://sensu/checks-master.json
    - template: jinja  

# Manage RabbitMQ Sensu vhost
sensu-rabbitmq-vhost:
  cmd.run:
    - name: rabbitmqctl add_vhost /sensu
    - unless: rabbitmqctl list_vhosts | grep -q /sensu


# Manage RabbitMQ Sensu user
sensu-rabbitmq-user:
  cmd.run:
    - name: rabbitmqctl add_user sensu mypass
    - unless: rabbitmqctl list_users | grep -q sensu
 

# Manage RabbitMQ Sensu permissions
sensu-rabbitmq-permissions:
  cmd.run:
    - name: rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
    - unless: rabbitmqctl list_user_permissions -p /sensu sensu | grep /sensu | grep -q '\.\*'
    - require:
      - cmd: sensu-rabbitmq-vhost
      - cmd: sensu-rabbitmq-user


# Manage Sensu server configuration file
sensu-server-config:
  file.managed:
    - name: /etc/sensu/conf.d/config.json
    - source: salt://sensu/server-config.json
       
    - require:
      - pkg: sensu-package
    
    - watch_in:
      - service: sensu-server
      

#Uchiwa server config + nginx
sensu-uchiwa-config:
  file.managed:
    - name: /etc/sensu/uchiwa.json
    - source: salt://sensu/uchiwa-config.json
       
    - require:
      - pkg: uchiwa
      - file: nginx_conf_uchiwa
      - file: nginx_sites_dir
    
    - watch_in:
      - service: uchiwa
      - service: sensu-api 

      
# Ensure services are running
  service.running:
    - name: sensu-server
    - name: rabbitmq-server
    - name: redis-server
    - name: sensu-api
    - name: sensu-client
    - name: uchiwa

#Nginx conf
  
nginx_conf_uchiwa: 
  file.managed:
    - template: jinja
    - source: salt://sensu/files/nginx-uchiwa-conf
    - name: /etc/nginx/sites-enabled/uchiwa
    - mode: 644
    - context:
       uchiwa_server_name: {{ uchiwa_server_name }} 


nginx_sites_dir:
  file.directory:
    - name: /etc/nginx/sites-enabled
    - makedirs: True
