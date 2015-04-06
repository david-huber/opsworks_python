default["opsworks_python"]["supervisor"] = {}
default["opsworks_python"]["supervisor"]["redirect_stderr"] = true
default["opsworks_python"]["supervisor"]["stdout_logfile"] = "/var/log/supervisor/%(program_name)s.log"
default["opsworks_python"]["supervisor"]["script"] = 'application.py'
node[:deploy].each do |application, deploy|
	default[:deploy][application]["opsworks_python"]["supervisor"]["action"] = [:enable, :start]
	default[:deploy][application]["opsworks_python"]["supervisor"]["process_name"] = application 
	default[:deploy][application]["opsworks_python"]["supervisor"]["autorestart"] = true
	default[:deploy][application]["opsworks_python"]["supervisor"]["autostart"] = t
end