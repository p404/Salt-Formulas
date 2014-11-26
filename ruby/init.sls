include:
  - rvm

ruby:
  cmd:
    - run
    - name: rvm install 2.1.0
    - unless: test -d $HOME/.rvm/rubies/2.1.0
    - require:
      - cmd: rvm_bashrc