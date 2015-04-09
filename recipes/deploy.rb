#
# Cookbook Name:: deploy_python
# Recipe:: default
#
include_recipe 'deploy'
include_recipe "python::default"

node["deploy"].each do |application, deploy|
  if deploy["application_type"] != "other" || deploy["custom_type"] != 'python'
    Chef::Log.debug("Skipping deploy_python::deploy for application #{application} as it is not a python app")
    next
  end

  Chef::Log.info("Running deploy_python::python_base_setup for application #{application}")

  opsworks_python application do
    action :setup
    deploy deploy
    application application
  end

  Chef::Log.info("Running opsworks_deploy_dir for application #{application}")
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  Chef::Log.info("Running opsworks_deploy for application #{application}")
  opsworks_deploy do
    deploy_data deploy
    app application
  end

  Chef::Log.info("Running deploy_python::python_dependencies for application #{application}")
  python_dependencies application do
    deploy_data deploy
    only_if "test -e #{::File.join(deploy[:deploy_to], 'current')}"
  end

  if deploy[:opsworks_python][:supervisor][:disabled]
    Chef::Log.info("Skipping supervisor for application #{application} as marked disabled")
    next
  end

  Chef::Log.info("Running deploy_python::supervisor_deploy for application #{application}")
  opsworks_python application do
    action :supervise
    deploy deploy
    application application
  end

end
