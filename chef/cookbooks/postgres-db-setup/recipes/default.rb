package '#{node[:postgres][:software]}'

directory '#{node[:postgres][:workarea]}' do
	user '#{node[:system][:owner]}'
	group '#{node[:system][:owner]}'
	mode '644'
end

directory '#{node[:postgres][:workarea]}#{node[:postgres][:version]}' do
	user '#{node[:system][:owner]}'
	group '#{node[:system][:owner]}'
	mode '644'
end

directory '#{node[:postgres][:workarea]}#{node[:postgres][:version]}#{node[:postgres][:data]}' do
	user '#{node[:system][:owner]}'
	group '#{node[:system][:owner]}'
	mode '644'
end

execute '-- copy data' do
	user '#{node[:system][:owner]}'
	cwd '.'
	command 'chown -R postgres:tape /opt/postgresql/'
end


execute '-- copy data' do
	user 'postgres'
	cwd '.'
	command 'cp /etc/postgresql/9.1/main/* /opt/postgresql/9.1/data/'
end

#Modify postgresql.conf file

template "#{node[:postgres][:workarea]}#{node[:postgres][:version]}#{node[:postgres][:data]}/postgresql.conf" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0644"
  source "posrtesql.conf.erb"
  variables(
    :HBA_FILE => '#{node[:postgres][:workarea]}#{node[:postgres][:version]}#{node[:postgres][:data]}/pg_hba.conf'
    :IDENT_FILE => '#{node[:postgres][:workarea]}#{node[:postgres][:version]}#{node[:postgres][:data]}/pg_ident.conf'
    :PORT => 5433
  )
end

#Modify pb_hba.conf file

cookbook_file "#{node[:postgres][:workarea]}#{node[:postgres][:version]}#{node[:postgres][:data]}/pb_hba.conf" do
  owner "#{node[:system][:owner]}"
  user "#{node[:system][:owner]}"
  mode "0755"
  source "pb_hba.conf"
end

#create user

execute '-- create user' do
	user 'postgres'
	cwd '.'
	command 'create user #{node[:postgres][:username]} with password "#{node[:postgres][:password]}"'
end

#create database

execute '-- create database' do
	user 'postgres'
	cwd '.'
	command 'CREATE DATABASE #{node[:postgres][:dbname]} WITH OWNER #{node[:postgres][:username]}'
end



