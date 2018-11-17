#ContainerCLI gives you a CLI for your docker-compose file
With container-cli you can easily transform your docker-compose.yml into a CLI tool to manage your application.
You can use and modify this project to your needs.
We have provided a blog post [TODO link] explaining the tool.

## Commands
* start (service-name) 
	* Starts all services defined in active-services
* stop (service-name)
	* Stops and deletes containers
* restart (service-name)
	* Restarts services defined in active-services
* update (service-name)
	* Downloads new docker images
* set-template (template-name)
	* Replaces the systems file with file mode-name
* log (service-name)
	* Prints the logs of the service
* list-available
  * Lists all services defined in services folder
* list-active
  * Lists all services in the active-services file
* list-templates
  * Lists all services in the templates folder
* activate (service-name) (--all)
	* Adds service to system and starts
* add (service-name) (--all)
	* Adds service to system
* deactivate {remove} (service-name)  (--all)
	* Stops container and removes from system file
* clean
	* Stops all services and deletes ./config directory


## Build & Extend the functionality
We use argbash to create the bash script from the template container-cli.m4. You can extend this file with further bash commands. To compile it you need to install arg-bash and execute the following command.
(argbash_dir_on_your_computer)/bin/argbash container-cli.m4 -o container-cli

## Internals
This section explains the internals of this project

### Files and Folders
* nginx_conf/ `(Volume mapping of service nginx)`
* services/ `(Folder containing all services of your application)`
	* backend/ `(Each service contains a docker-compose.yml)` 
	* db/
	* e2e-db/
	* ui/
* templates/ `(Default templates containing different services)`
* tmpl_env `(Set environment variables that can be used in docker-compose.yml files)`
* .env `(Is created dynamically, should not be changed. Add changes to templ_env)`
* active-services `(Names of all services that are startet with container-cli start)`
* container-cli `(Script created by argbash, changes should be done in container-cli.m4)`
* container-cli.m4 `(Actual script with all commands)`
* docker-compose.yml `(Contains services, volumes, networks relevant for all services)`


