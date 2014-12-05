sensu_ssl_certs:
  file:
    - name: /etc/rabbitmq/ssl
    - recurse
    - user: root
    - group: root
    - source: salt://sensu/files/ssl
    - clean: True

# Repo
rabbitmq_deb:
   pkgrepo.managed:
     - name: deb http://www.rabbitmq.com/debian/ testing main
     - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
     - require_in:
       - pkg: rabbitmq-server

# Install Erlang
erlang:
  pkg.installed:
    {% if grains['os'] == 'RedHat' or grains['os'] == 'Fedora' or grains['os'] == 'CentOS'%}
    - name: erlang
    {% elif grains['os'] == 'Debian' or grains['os'] == 'Ubuntu'%}
    - name: erlang-nox
    {% endif %}       
       
rabbitmq-server:

  # Install package
  pkg.installed:
    - name: rabbitmq-server

  # Install configuration file
  file.managed:
    - name: /etc/rabbitmq/rabbitmq.config
    - contents: |
          [
              {rabbit, [
              {ssl_listeners, [5671]},
              {ssl_options, [{cacertfile,"/etc/rabbitmq/ssl/cacert.pem"},
                             {certfile,"/etc/rabbitmq/ssl/cert.pem"},
                             {keyfile,"/etc/rabbitmq/ssl/key.pem"},
                             {verify,verify_peer},
                             {fail_if_no_peer_cert,true}]}
            ]}
          ].

    - require:
      - pkg: rabbitmq-server
      - file: sensu_ssl_certs

  # Ensure service is running and restart service on pkg or conf changes
  service.running:
    - watch:
      - pkg: rabbitmq-server   
      - file: rabbitmq-server   

