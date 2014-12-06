# top.sls
#
# Definition state.highstate
# Base and MonitorServer
base:
  '*':
    - git
  'CosmosMinion*':
    - rabbitmq.server-sensu
    - redis.server
    - sensu.server
