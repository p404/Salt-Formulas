##############################################################################
# server.sls
#
# Redis 
# Redis install
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

redis-server:
  
  # install package
  pkg.installed:
    - name: redis-server

  # ensure service is running
  service.running:
    - name: redis-server
