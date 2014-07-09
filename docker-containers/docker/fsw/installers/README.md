# Creating installers for FSW image
This will create a container that serves the purpose of a volume with installers. This image could be redistributed if necessary.

````
docker build -t "jmorales_fsw/installers:6.0" -rm .
````

To run a FSW installers volume container

````
docker run -t -i --name "fsw_installer" jmorales_fsw/installers:6.0
````

There is a volume at /software with all FSW needed software:

- jboss-fsw-installer-6.0.0.GA-redhat-4.jar
- BZ-1063388-RollupPatch1.zip
- install-dtgov.xml  install-dtgov.xml.variables  
- install-fsw.xml  install-fsw.xml.variables  
- install-rtgov.xml  install-rtgov.xml.variables  
- install-sy.xml  install-sy.xml.variables
