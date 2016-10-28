# ls_user_mgmt_tool

This is a cookbook the deploys the User Management Tool as well as configuring the server to support it's use.

<h2>Attributes</h2>

exch_server_fqdn - The FQDN of the Mircosoft 2013 Exchange server.
mail_database - The Default User mail database the users will be added to.
default_ou_path - The Default location in Active Directory the user will live
registrar_pool - The Default Skype for Business or Lync registrar pool the users will be placed in.
lync_source - The file share location for the Lync Server 2013 Admin Tools Install files.
