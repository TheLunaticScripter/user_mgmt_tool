# # encoding: utf-8

# Inspec test for recipe ls_user_mgmt_tool::default

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

script = <<-EOH
  (Get-DscLocalConfigurationManager | select -ExpandProperty "ConfigurationMode") -eq "ApplyOnly"
EOH

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

describe file ('C:\Users\Public\Desktop\User Mgmt Tool.lnk') do
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
