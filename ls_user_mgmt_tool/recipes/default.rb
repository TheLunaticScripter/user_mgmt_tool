#
# Cookbook Name:: ls_user_mgmt_tool
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

powershell_script 'Configure the LCM' do
  code <<-EOH
    Configuration ConfigLCM
    {
        Node "localhost"
        {
            LocalConfigurationManager
            {
                ConfigurationMode = "ApplyOnly"
                RebootNodeIfNeeded = $false
            }
        }
    }
    ConfigLCM -OutputPath "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
    Set-DscLocalConfigurationManager -Path "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
  EOH
  not_if '(Get-DscLocalConfigurationManager | select -ExpandProperty "ConfigurationMode") -eq "ApplyOnly"'
end

dsc_script 'RSAT-AD-Tools' do
  code <<-EOH
    WindowsFeature InstallADTools
    {
        Name = "RSAT-ADDS"
        Ensure = "Present"
    }
  EOH
end

dsc_script 'RSAT-AD-PowerShell' do
  code <<-EOH
    WindowsFeature InstallADPowerShell
    {
        Name = "RSAT-AD-PowerShell"
        Ensure = "Present"
    }
  EOH
end

# Install they Lync 2013 Administration Tools
windows_package 'Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.50727' do
  source "#{node['ls_user_mgmt_tool']['lync_source']}\\vcredist_x64.exe"
  timeout 500
  installer_type :custom
  options '/install /quiet'
end

windows_package 'Microsoft System CLR Types for SQL Server 2012 (x64)' do
  source "#{node['ls_user_mgmt_tool']['lync_source']}\\SQLSysClrTypes.msi"
  action :install
end

windows_package 'Microsoft SQL Server 2012 Management Objects  (x64)' do
  source "#{node['ls_user_mgmt_tool']['lync_source']}\\SharedManagementObjects.msi"
end

windows_package 'Microsoft Lync Server 2013, Core Components' do
  source "#{node['ls_user_mgmt_tool']['lync_source']}\\Setup\\ocscore.msi"
end

windows_package 'Microsoft Lync Server 2013, Administrative Tools' do
  source "#{node['ls_user_mgmt_tool']['lync_source']}\\Setup\\admintools.msi"
end

# Create the Directroy for the Tool under Program Files
directory 'c:\Program Files\Mgmt Tools'

template 'c:\Program Files\Mgmt Tools\UserAcctMgmtTool.ps1' do
  source 'UserAcctMgmtTool.ps1.erb'
  variables(
    exch_server_fqdn: node['ls_user_mgmt_tool']['exch_server_fqdn'],
    mail_database: node['ls_user_mgmt_tool']['mail_database'],
    default_ou: node['ls_user_mgmt_tool']['default_ou_path'],
    registrar_pool: node['ls_user_mgmt_tool']['registrar_pool']
  )
end

directory 'c:\Program Files\Mgmt Tools\Assets'

cookbook_file 'c:\Program Files\Mgmt Tools\Assets\UserMgmtTool-v1.bmp' do
  source 'UserMgmtTool-v1.bmp'
  action :create_if_missing
end

# Create Shortcut with PowerShell
powershell_script 'Create desktop Shortcut for User Account Management Tool' do
  code <<-EOH
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("C:\\Users\\Public\\Desktop\\User Mgmt Tool.lnk")
    $Shortcut.TargetPath = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"
    $Shortcut.Arguments = '-ExecutionPolicy Bypass -File "c:\\Program Files\\Mgmt Tools\\UserAcctMgmtTool.ps1"'
    $Shortcut.IconLocation = 'C:\\Program Files\\Mgmt Tools\\Assets\\UserMgmtTool-v1.bmp'
    $Shortcut.Save()
  EOH
  not_if '(Get-Item -Path "c:\Users\Public\Desktop\User Mgmt Tool.lnk").Count -eq 1'
end
