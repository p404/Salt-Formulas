curl:
  pkg:
    - installed

rvm:
  cmd:
    - run
    - name: curl -L get.rvm.io | bash -s stable
    - unless: test -s "$HOME/.rvm/scripts/rvm"
    - require:
      - pkg: curl

rvm_bashrc:
  cmd:
    - run
    - name: echo "[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc
    - unless: grep ".rvm/scripts/rvm" ~/.bashrc
    - require:
      - cmd: rvm