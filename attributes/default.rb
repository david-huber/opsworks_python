include_attribute "deploy"

#include_attribute "deploy_python::django"
#include_attribute "deploy_python::buildout"

# node[:deploy].each do |application, deploy|
# 	default[:deploy][application][:custom_type] = "python"
# 	default[:deploy][application][:purge_before_symlink] = []
# 	default[:deploy][application][:create_dirs_before_symlink] = ['public', 'tmp']
# 	default[:deploy][application][:packages] = []
# 	default[:deploy][application][:os_packages] = []
# 	default[:deploy][application][:venv_options] = '--no-site-packages'
# end

node.default["opsworks_python"]["custom_type"] = "python"
node.default["opsworks_python"]["symlink_before_migrate"] = {}
node.default["opsworks_python"]["purge_before_symlink"] = []
node.default["opsworks_python"]["create_dirs_before_symlink"] = ['public', 'tmp']
node.default["opsworks_python"]["packages"] = []
node.default["opsworks_python"]["os_packages"] = []
node.default["opsworks_python"]["venv_options"] = '--no-site-packages'

include_attribute "opsworks_python::supervisor"