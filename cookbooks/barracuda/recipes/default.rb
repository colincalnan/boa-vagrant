Chef::Log.debug("Running barracuda recipe")

execute "update package index" do
   command "apt-get update"
   ignore_failure true
   action :nothing
end.run_action(:run)

execute "Install linux headers to allow guest additions to update properly" do
 command "apt-get install dkms build-essential linux-headers-generic curl -y"
end

remote_file "/tmp/BOA.sh" do
  source "http://files.aegir.cc/BOA.sh.txt"
  mode 00755
end

execute "/tmp/BOA.sh" do
  creates "/usr/local/bin/boa"
end

execute "Run the BOA Installer reoctopus" do
  command "boa in-head local cmsadmin@raisedeyebrow.com mini reoctopus"
end

  user "reoctopus" do
    supports :manage_home => true
    home "/data/disk/reoctopus"
    shell "/bin/bash"
  end

  directory "/data/disk/reoctopus/.ssh" do
    owner "reoctopus"
    group "users"
    mode 00700
    recursive true
  end

  execute "Add ssh key to user" do
    command "ssh-keygen -b 4096 -t rsa -N \"\" -f /data/disk/reoctopus/.ssh/id_rsa"
    creates "/data/disk/reoctopus/.ssh/id_rsa"
  end

  file "/data/disk/reoctopus/.ssh/id_rsa" do
    owner "reoctopus"
    group "users"
    mode 00600
  end
  
  file "/data/disk/reoctopus/.ssh/id_rsa.pub" do
    owner "reoctopus"
    group "users" 
    mode 00600
  end  

 # Only necessary as long as there is a need for it
remote_file "/tmp/fix-remote-import-hostmaster-reoctopus.patch" do
  source "https://raw.github.com/MattReimer/boa-vagrant/master/patches/fix-remote-import-hostmaster-reoctopus.patch"
  mode 00755
end

execute "Apply Remote Import hostmaster patch" do
  cwd "/data/disk/reoctopus/.drush/provision/remote_import"
  command "patch -p1 < /tmp/fix-remote-import-hostmaster-reoctopus.patch"
end

# Rebuild VirtualBox Guest Additions
# http://vagrantup.com/v1/docs/troubleshooting.html
  execute "Rebuild VirtualBox Guest Additions" do
  command "sudo /etc/init.d/vboxadd setup"
end