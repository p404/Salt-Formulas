rabbitmq_deb:
   pkgrepo.managed:
     - name: deb http://www.rabbitmq.com/debian/ testing main
     - key_url: http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
     - require_in:
       - pkg: rabbitmq-server
       
rabbitmq-server:

  #SSL Cert for rabbitmq
  cmd.run:
    - name: cd /tmp && wget http://sensuapp.org/docs/0.13/tools/ssl_certs.tar && tar -xvf ssl_certs.tar
    - name: cd ssl_certs && ./ssl_certs.sh generate
    - name: mkdir -p /etc/rabbitmq/ssl && sudo cp /tmp/ssl_certs/sensu_ca/cacert.pem /tmp/ssl_certs/server/cert.pem /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl
  

  # install package
  pkg.installed:
    - name: rabbitmq-server
    - require:
          - pkg: erlang-nox 

  # install configuration file
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

  # Ensure service is running and restart service on pkg or conf changes
  service.running:
    - watch:
      - pkg: rabbitmq-server   
      - file: rabbitmq-server   

