define :python_base_setup do
  deploy = params[:deploy_data]
  application = params[:app_name]

  Chef::Log.debug("*****************************************")
  Chef::Log.debug("Running #{recipe_name} for #{application}")
  Chef::Log.debug("*****************************************")

  os_packages = deploy["os_packages"] ? deploy["os_packages"] : node["opsworks_python"]["os_packages"]
  # Install os dependencies
    os_packages.each do |pkg,ver|
    package pkg do
      action :install
      version ver if ver && ver.length > 0
    end
  end

  # We need to establish a value for the original pip/venv location as
  # a baseline so we don't find the older ones later, we assume ubuntu
  # here, because we are lazy and this is for OpsWorks
  node.normal['python']['pip_location'] = "/usr/local/bin/pip"
  node.normal['python']['virtualenv_location'] = "/usr/local/bin/virtualenv"
  # We also need to override the prior override
  node.override['python']['pip_location'] = "/usr/local/bin/pip"
  node.override['python']['virtualenv_location'] = "/usr/local/bin/virtualenv"
  include_recipe "python::default"

  py_version = deploy["python_major_version"]
  use_custom_py = py_version && py_version != "2.7"
  pip_ver_map = {
    "2.4" => "1.1",
    "2.5" => "1.3.1",
    "2.6" => "1.5.4"
  }
  virtualenv_ver_map = {
    "2.4" => "1.7.2",
    "2.5" => "1.9.1",
    "2.6" => "1.11.4"
  }
  if use_custom_py
    # We need to install an older python
    py_command = "python#{py_version}"
    apt_repository 'deadsnakes' do
      uri 'http://ppa.launchpad.net/fkrull/deadsnakes/ubuntu'
      distribution node['lsb'] && node['lsb']['codename'] || 'precise'
      components ['main']
      keyserver "keyserver.ubuntu.com"
      key "DB82666C"
      action :add
    end
    package "#{py_command}-dev"
    package "#{py_command}-setuptools" do
      action :install
      ignore_failure true  # This one doesn't always exist
    end
    package "#{py_command}-distribute-deadsnakes" do
      action :install
      ignore_failure true  # This one doesn't always exist
    end
    # only set the python binary for this chef run, once the venv is
    # established we don't want to keep this around
    node.force_override['python']['binary'] = "/usr/bin/#{py_command}"
    # We use easy install to install pip, because get-pip.py seems to
    # fail on some python versions
    pip = "pip"
    pip_ver = pip_ver_map[py_version]
    pip << "==#{pip_ver}" if pip_ver
    venv = "virtualenv"
    venv_ver = virtualenv_ver_map[py_version]
    venv << "==#{venv_ver}" if venv_ver
    execute "/usr/bin/easy_install-#{py_version} #{pip} #{venv}"
    node.override['python']['pip_location'] = "/usr/bin/pip#{py_version}"
    node.override['python']['virtualenv_location'] = "/usr/bin/virtualenv-#{py_version}"
  end
  
  if !use_custom_py
    python_pip "setuptools" do
      version 3.3
      action :upgrade
    end
  end

  # Set deployment user home dir, OpsWorks normally does this
  if !deploy[:home]
    node.default[:deploy][application][:home] = ::File.join('/home/', deploy[:user])
  end

  opsworks_deploy_user do
    deploy_data deploy
  end

  directory "#{deploy[:deploy_to]}/shared" do
    group deploy[:group]
    owner deploy[:user]
    mode 0770
    action :create
    recursive true
  end

  python_dependencies do
    deploy_data deploy
    app_name application
  end

end
