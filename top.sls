##############################################################################
# top.sls
#
# Definition state.highstate
# Base and OpServer
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

base:
  '*':
    - git
  'OpServer*':
    - java
    - nginx.server
    - rabbitmq.server-sensu
    - redis.server
    - sensu.server
    - elk.stack
