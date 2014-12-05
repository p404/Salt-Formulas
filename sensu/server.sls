# include all common sensu configuration
include:
  - sensu.common

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

# Example rabbitmqctl output:
#  rabbitmqctl add_vhost /sensu
#  rabbitmqctl add_user sensu mypass
#  rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"

# Manage Sensu server configuration file
sensu-server-config:
  file.managed:
    - name: /etc/sensu/conf.d/config.json
    - source: salt://sensu/server-config.json
    - require:
      - pkg: sensu-package
