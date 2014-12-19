##############################################################################
# init.sls
#
# Nginx 
# Nginx install
#
# Pablo Opazo <pablo@sequel.ninja>
##############################################################################

nginx-server:
  pkg.installed:
    - name: nginx
    - require:
      - file: nginx_sites_dir

  service.running:
    - name: nginx
    

nginx_sites_dir:
  file.directory:
    - name: /etc/nginx/sites-enabled
    - makedirs: True    