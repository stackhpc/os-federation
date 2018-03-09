# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  if Vagrant.has_plugin?('landrush')
    config.landrush.enabled = true
    config.landrush.upstream '8.8.8.8'
  end

  config.vm.box = 'stackhpc/centos-7'

  config.vm.provider 'virtualbox' do |vb|
    vb.cpus   = '1'
    vb.memory = '2048'
    vb.linked_clone = true
  end

  config.vm.provider 'vmware_fusion' do |vmware|
    vmware.vmx['numvcpus'] = '1'
    vmware.vmx['memsize']  = '2048'
    vmware.linked_clone = true
  end

  config.user.hosts.each do |host_name, options|
    config.vm.define host_name do |host|
      if options.has_key?(:ip)
        host.vm.network :private_network, ip: options.ip
      else
        host.vm.network :private_network, type: :dhcp
      end
      host.vm.hostname = "#{host_name}.vagrant.test"
      host.vm.synced_folder '.', '/vagrant'
      host.vm.provision 'shell', path: 'vagrant/bootstrap.sh'
    end
  end
end
