# Federated OpenStack Test Environment

## 🚨 This is a work-in-progress. Lower your expectations and proceed at your own risk!

This configuration deploys two independant OpenStack control nodes - `sp` and `idp` - ready for development and test of OpenStack Federation.  The goal of the configuration in this repository is to bootstrap just enough OpenStack in each case to do basic testing, so all this currently deploys is Keystone plus dependencies (i.e MariaDB).

# Getting started

## Pre-requisites

Clone the `shibboleth` branch from these two repos:

https://github.com/yankcrime/kolla
https://github.com/yankcrime/kolla-ansible

TODO: Move these to StackHPC's organisation

You'll also need the Vagrant [Nugrant](https://github.com/maoueh/nugrant) plugin installed:

```shell
$ vagrant plugin install vagrant-nugrant
```

## Launching VMs

Bring up both VMs with:

```shell
vagrant up {sp,idp}
```

Then on the Service Provider (SP) node:

```shell
$ vagrant ssh sp
$ source /vagrant/venvs/kolla/bin/activate
$ cd /vagrant/kolla
$ python tools/build.py --template-override /vagrant/vagrant/template-overrides.j2 \
    --tag pike {haproxy,mariadb,keystone,shibboleth}
$ cd /vagrant/kolla-ansible
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t haproxy
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t mariadb
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t keystone
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t shibboleth
$ tools/kolla-ansible post-deploy
```

For the Identity Provider (IdP) node:
```shell
$ vagrant ssh idp
$ source /vagrant/venvs/kolla/bin/activate
$ cd /vagrant/kolla
$ python tools/build.py --template-overrides.j2 \
    --tag pike {haproxy,mariadb,keystone}
$ cd /vagrant/kolla-ansible
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t haproxy
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t mariadb
$ tools/kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t keystone
$ tools/kolla-ansible post-deploy
```

Quickly test that Keystone is working:

```
# Switch venvs
$ deactivate
$ source /vagrant/venvs/openstack/bin/activate
$ source /etc/kolla/admin-openrc.sh
$ openstack endpoint list
```
