define :supervisor_deploy do
  deploy = params[:deploy_data]
  application = params[:app_name]

  options = deploy["opsworks_python"]["supervisor"]
  venv_path = ::File.join(deploy[:deploy_to], 'shared', 'env')
  env = OpsWorks::Escape.escape_double_quotes(deploy[:environment_variables])
  env["PATH"] = venv_path
  script_path = ::File.join(deploy[:deploy_to], 'current', options["script"])
  python_path = ::File.join(venv_path, "bin", "python")

  command = "#{python_path} #{script_path}"
  
  if options[:command]
    command = options[:command]
    if options.has_key?("command_in_env")
      command = ::File.join(venv_path, command)
    end
  end

  options[:command] = command
  options[:env] = env
  Chef::Log.info("supervisor command for application #{application} is #{command}")
  supervisor_service application do
    options
  end

end