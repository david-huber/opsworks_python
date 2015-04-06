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

  Chef::Log.info("supervisor command for application #{application} is #{command}")
  supervisor_service application do
    command command
    environment env
    process_name application
    numprocs options[:numprocs]
    numprocs_start options[:numprocs_start]
    priority options[:priority]
    autostart options[:autostart]
    autorestart options[:autorestart]
    startsecs options[:startsecs]
    startretries options[:startretries]
    exitcodes options[:exitcodes]
    stopsignal options[:stopsignal]
    stopwaitsecs options[:stopwaitsecs]
    user options[:user]
    redirect_stderr options[:redirect_stderr]
    stdout_logfile options[:stdout_logfile]
    stdout_logfile_maxbytes options[:stdout_logfile_maxbytes]
    stdout_logfile_backups options[:stdout_logfile_backups]
    stdout_capture_maxbytes options[:stdout_capture_maxbytes]
    stdout_events_enabled options[:stdout_events_enabled]
    stderr_logfile options[:stderr_logfile]
    stderr_logfile_maxbytes options[:stderr_logfile_maxbytes]
    stderr_logfile_backups options[:stderr_logfile_backups]
    stderr_capture_maxbytes options[:stderr_capture_maxbytes]
    stderr_events_enabled options[:stderr_events_enabled]
    umask options[:umask]
    serverurl options[:serverurl]
  end

end