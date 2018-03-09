#!/usr/bin/env bash
test -f /root/.provisioned && exit 0

# Install packages
PACKAGES="epel-release ansible python-virtualenv \
    python-devel libffi-devel libselinux-python \
    gcc openssl-devel git vim ntp yum-utils"
yum install -y $PACKAGES

yum install -y python-pip
pip install -U pip

cat >> /etc/hosts << EOF
192.168.10.100  sp.vagrant.test     sp
192.168.10.200  idp.vagrant.test    idp
EOF

# Enable ntp
systemctl enable ntpd.service
systemctl start ntpd.service

# Create a virtualenv for the OSC
VIRTUALENV_PATH=/vagrant/venvs/openstack
if [ ! -d "$VIRTUALENV_PATH" ]; then
    mkdir -p $VIRTUALENV_PATH
    virtualenv $VIRTUALENV_PATH
    source $VIRTUALENV_PATH/bin/activate
    pip install -U pip
    pip install python-{openstack,keystone}client
    chown -R vagrant:vagrant $VIRTUALENV_PATH
    deactivate
fi

# Bootstrap Kolla
pip install -U kolla kolla-ansible
mkdir /etc/kolla
cp /vagrant/vagrant/globals-$(hostname -s).yml /etc/kolla/globals.yml
cp /usr/share/kolla-ansible/etc_examples/kolla/passwords.yml /etc/kolla/
kolla-genpwd
kolla-ansible -i /vagrant/vagrant/all-in-one bootstrap-servers
# kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t haproxy
# kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t mariadb
# kolla-ansible -i /vagrant/vagrant/all-in-one deploy -t keystone
# kolla-ansible post-deploy

# Cleanup
usermod -aG docker vagrant

# Done provisioning
touch /root/.provisioned

