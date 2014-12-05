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
      

#Uchiwa server config
sensu-uchiwa-config:
  file.managed:
    - name: /etc/sensu/conf.d//uchiwa.json
    - source: salt://sensu/uchiwa-config.json
       
    - require:
      - pkg: uchiwa
    
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
            
 