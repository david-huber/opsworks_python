opsworks_python Cookbook
=============================
This cookbook is designed to be able to describe and deploy python applications on AWS OpsWorks with supervisor.

Requirements
------------
Chef 0.10.0 or higher required (for Chef environment use).

The following Opscode cookbooks are dependencies:

- python
- supervisor

Additionally, the AWS OpsWorks following cookbooks are required:

- deploy
- scm_helper


Stack/Layer configuration
-------------------

### Stack configuration
In your stack, update enable your custom json:

	{
 	 "deploy": {
		"my_python_app": {
     		"custom_type": "python", // Required otherwise the recipe will skip
      		// List of package to install (optional)
      		"packages": { 
        		"pip_package_name": "latest",
      		},
      		// OS packages  (optional)
      		"os_packages": { 
      			"package_name": "lasest"
      		},
      		"opsworks_python": {
      			"supervisor": {
      				// supervisor options
      			}
      		}
    	}
    }}


Recipes
-------------------

### python
The python deploy recipe creates a virtualenv and installs specified OS and python packages.  This is the default recipe.  These attributes can be set on the deploy configuration (`node[:deploy][application_name]`) or globally (`node["opsworks_python"]`).

#### Attribute Parameters
- packages: a list of python packages to be installed in the virtualenv
- os_packages: a list of OS packages to be installed on the instance
- venv_options: a string with command line options for virtualenv creation (defaults to `--no-site-packages`)
- python_major_version: the major version of python to use (only allowable in the deploy configuration, not globally), allows you to use python `2.4`, `2.5` or `2.6` as needed.

#### Related recipes
- python-undeploy: removes the virtual env and stops supervisor for the app


#### supervisor
by default supervisor looks for application.py into your app folder.
If your entrypoint is different set: 

`["opsworks_python"]["supervisor"]["script"] = 'myscript.py'` 

If you want supervisor to use a specific command:
`["opsworks_python"]["supervisor"]["command"] = 'mycommand'` 

Other supervisor options for the service are described [here](https://supermarket.chef.io/cookbooks/supervisor)

#### Disable supervisor
set `node["opsworks_python"]["supervisor"]["disabled"] = true` and supervisor will be disabled.


Bugfix for R3 Instances
-----------------------

OpsWorks currently has a bug that affects r3 class instances, where the
ephemeral instance storage is not formatted or mounted on initial load.  This
causes reboots to fail, since the volume is listed in fstab, and also results
in reduced space available on ``/mnt``.

To workaround this issue, this package contains a custom recipe that formats
and mounts the default ephemeral volume on r3 instances.  To enable the
recipe, add the ``opsworks_deploy_python::r3-mount-patch`` recipe to the start
of the setup section of any layers that might run on an r3 instance.

[More info here](https://forums.aws.amazon.com/thread.jspa?threadID=156342).


License & Authors
-----------------
- Author:: Florent Vilmart (<flo@flovilmart.com>)

- Inspired from:: Alec Mitchell (<alecpm@gmail.com>)

With thanks to Jazkarta, Inc. and KCRW Radio
```text
Copyright 2014, Alec Mitchell

Licensed under the BSD License.
```
