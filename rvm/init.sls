curl:
  pkg:
    - installed
    
gpg-import-D39DC0E3:
  cmd.run:
    - name: gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3; echo '409B6B1796C275462A1703113804BB82D39DC0E3:4:' |gpg --import-ownertrust
    - unless: gpg --fingerprint |fgrep 'Key fingerprint = 409B 6B17 96C2 7546 2A17  0311 3804 BB82 D39D C0E3'    

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