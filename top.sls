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
    - nginx.server
    - elk.stack
    - rabbitmq.server-sensu
    - redis.server
    - sensu.server
