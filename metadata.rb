name             "opsworks_python"
maintainer       "Florent Vilmart"
maintainer_email "florent@flovilmart.com"
license          "BSD License"
description      "Deploys and configures python based applications with supervisor"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "deploy"
depends "scm_helper"
depends "opsworks_initial_setup"

# Non Opsworks cookbook
depends "python"
depends "supervisor"

recipe "opsworks_python::deploy", "Install and setup a python application in a virtualenv"
recipe "opsworks_python::r3-mount-patch", "Patch to mount /mnt filesystems for r3 instances"
