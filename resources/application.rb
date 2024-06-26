#
# Cookbook Name:: docker_compose
# Resource:: application
#
# Copyright (c) 2016 Sebastian Boschert, All Rights Reserved.

property :project_name, kind_of: String, name_property: true
property :compose_files, kind_of: Array, required: true
property :remove_orphans, kind_of: [TrueClass, FalseClass], default: false
property :services, kind_of: Array, default: []
property :workdir, kind_of: String

default_action :up

def get_compose_params
  "-p #{project_name}" +
      ' -f ' + compose_files.join(' -f ')
end

def get_up_params
  '-d' +
    (remove_orphans ? ' --remove-orphans' : '') +
    (services.nil? ? '' : ' ' + services.join(' '))
end

def get_down_params
  (remove_orphans ? ' --remove-orphans' : '') +
  (services.nil? ? '' : ' ' + services.join(' '))
end

action :pull do
  project_name = new_resource.project_name || current_resource.project_name

  execute "running docker compose pull for project #{project_name}" do
    command "docker compose #{get_compose_params} pull"
    environment('PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin')
    user 'root'
    group 'root'
    cwd new_resource.workdir
  end
end

action :up do
  project_name = new_resource.project_name || current_resource.project_name
  compose_files = new_resource.compose_files || current_resource.compose_files

  execute "running docker compose up for project #{project_name}" do
    command "docker compose #{get_compose_params} up #{get_up_params}"
    environment('PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin')
    user 'root'
    group 'root'
    cwd new_resource.workdir
  end
end

action :create do
  project_name = new_resource.project_name || current_resource.project_name

  execute "running docker compose create for project #{project_name}" do
    command "docker compose #{get_compose_params} create #{get_up_params}"
    environment('PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin')
    user 'root'
    group 'root'
    cwd new_resource.workdir
  end
end

action :down do
  project_name = new_resource.project_name || current_resource.project_name
  compose_files = new_resource.compose_files || current_resource.compose_files

  execute "running docker compose down for project #{project_name}" do
    command "docker compose #{get_compose_params} down  #{get_down_params}"
    environment('PATH' => '/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin')
    not_if "[ $(docker compose -f #{compose_files.join(' -f ')} ps -q | wc -l) -eq 0 ]"
    user 'root'
    group 'root'
    cwd new_resource.workdir
  end
end
