include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  
  if deploy["application_type"] != "other" || deploy["custom_type"] != 'python'
    Chef::Log.debug("Skipping deploy_python::undeploy for application #{application} as it is not a python app")
    next
  end
  
  virtualenv application + '-venv' do
    action :delete
  done
  directory "#{deploy[:deploy_to]}" do
    recursive true
    action :delete
    only_if do 
      ::File.exists?("#{deploy[:deploy_to]}")
    end
  end
  supervisor_service application do
    action :stop
  end
end
