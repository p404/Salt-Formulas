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
    - elk.stack
    - rabbitmq.server-sensu
    - redis.server
    - sensu.server
