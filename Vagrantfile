servers=[
  {
    :box => "hashicorp/bionic64",
    :hostname => "Server-1",
    :ip => "10.0.2.10",
    :ram => 1024
  },
  {
    :box => "hashicorp/bionic64",
    :hostname => "Server-2",
    :ip => "10.0.2.11",
    :ram => 1024
  }
]

clients=[
  {
    :box => "hashicorp/bionic64",
    :hostname => "Client-1",
    :ip => "10.0.2.12",
    :ram => 1024
  },
  {
    :box => "hashicorp/bionic64",
    :hostname => "Client-2",
    :ip => "10.0.2.13",
    :ram => 1024
  },
  {
    :box => "hashicorp/bionic64",
    :hostname => "Client-3",
    :ip => "10.0.2.14",
    :ram => 1024
  }
]

Vagrant.configure(2) do |config| 
   servers.each do |machine|
      config.vm.define machine[:hostname] do |node|
          node.vm.box = machine[:box]
          node.vm.hostname = machine[:hostname]
          node.vm.network :private_network, ip: machine[:ip]
          node.vm.provider "virtualbox" do |vb|
              vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
          end
          node.vm.provision "shell" do |s|
            ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
            s.inline = <<-SHELL
            SHELL
          end
      end
  end
  clients.each do |machine|
      config.vm.define machine[:hostname] do |node|
          node.vm.box = machine[:box]
          node.vm.hostname = machine[:hostname]
          node.vm.network :private_network, ip: machine[:ip]
          node.vm.provider "virtualbox" do |vb|
              vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
          end
          node.vm.provision "shell" do |s|
            ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
            s.inline = <<-SHELL
              echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys
              echo #{ssh_pub_key} >> /root/.ssh/authorized_keys
              mkdir -p /home/vagrant/images
              chown vagrant:vagrant /home/vagrant/images
              chmod 755 /home/vagrant/images
            SHELL
          end
      end
  end

end

