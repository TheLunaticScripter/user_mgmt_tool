# encoding: utf-8
# copyright: 2015, The Authors
# license: All rights reserved

title 'User Mmgt Tool Funtional Tests'

# you can also use plain tests
script = <<-EOH
  (Get-DscLocalConfigurationManager | select -ExpandProperty "ConfigurationMode") -eq "ApplyOnly"
EOH

control 'ls_user_mgmt_tool_smoke' do
  impact 1.0
  title 'Ensure User Mgmt Tool is Working'
  desc 'This is a smoke test to validate the Mgmt Tools will Run.'
  describe powershell(script) do
    its('strip') { should eq 'True'}
  end

  describe windows_feature('RSAT-AD-Tools') do
    it { should be_installed}
  end

  describe package('Microsoft Lync Server 2013, Administrative Tools') do
    it { should be_installed }
  end

  describe file('c:\Program Files\Mgmt Tools\UserAcctMgmtTool.ps1') do
    it { should be_file }
  end

  describe file('C:\Users\Public\Desktop\User Mgmt Tool.lnk') do
    it { should be_file }
  end

  script1 = <<-EOH
    $app = Start-Process 'C:\\Users\\Public\\Desktop\\User Mgmt Tool.lnk' -PassThru
    (Get-Process -Id $app.Id).Count -eq 1
    Stop-Process $app
  EOH

  describe powershell(script1) do
    its('strip') { should eq 'True'}
  end
end
