define :python_dependencies do
  deploy = params[:deploy_data]
  application = params[:app_name]

  # Setup venv
  venv_path = ::File.join(deploy[:deploy_to], 'shared', 'env')
  node.normal[:deploy][application]["venv"] = venv_path
  python_virtualenv application + '-venv' do
    path venv_path
    owner deploy[:user]
    group deploy[:group]
    action :create
  end

  packages = deploy["packages"] ? deploy["packages"] : node["opsworks_python"]["packages"]
  
  # Install pip dependencies
  packages.each do |name, ver|
    python_pip name do
      version ver if ver && ver.length > 0
      virtualenv venv_path
      user deploy[:user]
      group deploy[:group]
      action :install
    end
  end

  # Create environment file
  template File.join(deploy[:deploy_to], "shared","app.env") do
    source "app.env.erb"
    mode 0770
    owner deploy[:user]
    group deploy[:group]
    variables(
      :environment => OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
    )
    only_if {File.exists?("#{deploy[:deploy_to]}/shared")}
  end

end