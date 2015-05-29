require 'spec_helper'
# Rename this file to classname_spec.rb
# Check other boxen modules for examples
# or read http://rspec-puppet.com/tutorial/
describe 'vault' do
  let(:facts) { default_test_facts }
  let(:default_params) do
    {
      :ensure => "present",
      :version => "0.9.9"
    }
  end
  
  context "ensure => present" do
    let(:params) { default_params }
    let(:command) {
      [
        "rm -rf /tmp/vault* /tmp/0",
        # download the zip to tmp
        "curl http://dl.bintray.com/mitchellh/vault/vault_0.9.9_darwin_amd64.zip?direct -L > /tmp/vault-v0.9.9.zip",
        # extract the zip to tmp spot
        "mkdir /tmp/vault",
        "unzip -o /tmp/vault-v0.9.9.zip -d /tmp/vault",
        # blow away an existing version if there is one
        "rm -rf /test/boxen/vault",
        # move the directory to the root
        "mv /tmp/vault /test/boxen/vault",
        # chown it
        "chown -R testuser /test/boxen/vault"
      ].join(" && ")
    }
    
    it do
      should contain_exec("install vault v0.9.9").with({
        :command => command,
        :user    => "testuser",
      })
      
      #todo: figure this out
      #should contain_file("/text/boxen/env.d/vault.sh")
    end
  end
end
