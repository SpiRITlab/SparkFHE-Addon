#!/bin/bash

chmod 700 $HOME/.ssh
rm -rf $HOME/.ssh/id_rsa
geni-get key > $HOME/.ssh/id_rsa
chmod 600 $HOME/.ssh/id_rsa 
ssh-keygen -y -f $HOME/.ssh/id_rsa > $HOME/.ssh/id_rsa.pub

grep -q -f $HOME/.ssh/id_rsa.pub $HOME/.ssh/authorized_keys || cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys