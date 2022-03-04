#!/bin/sh

sudo yum makecache fast
sudo yum install -y vim-enhanced bind-utils mlocate deltarpm

sudo echo "alias l='ls -latFrh'" >> /home/centos/.bashrc
sudo echo "alias vi=vim"         >> /home/centos/.bashrc
sudo echo "set background=dark"  >> /home/centos/.vimrc
sudo echo "syntax on"            >> /home/centos/.vimrc
sudo echo "alias l='ls -latFrh'" >> /root/.bashrc
sudo echo "alias vi=vim"         >> /root/.bashrc
sudo echo "set background=dark"  >> /root/.vimrc
sudo echo "syntax on"            >> /root/.vimrc

sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
sudo setenforce 0

