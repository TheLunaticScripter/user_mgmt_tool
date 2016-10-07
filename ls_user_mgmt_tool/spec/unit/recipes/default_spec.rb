#
# Cookbook Name:: ls_user_mgmt_tool
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'ls_user_mgmt_tool::default' do
  context 'when run on Window Server 2012R2' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
                            .converge(described_recipe)
    end

    before do
      stub_command("(Get-DscLocalConfigurationManager | select -ExpandProperty \"ConfigurationMode\") -eq \"ApplyOnly\"").and_return(false)
      stub_command("(Get-Item -Path \"c:\\Users\\Public\\Desktop\\User Mgmt Tool.lnk\").Count -eq 1").and_return(true)
    end

    it 'Configure the User Managment tool' do
      expect { chef_run }.to_not raise_error
    end
  end
end
