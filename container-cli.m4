#!/bin/bash

# ARG_OPTIONAL_SINGLE([hostname],, [Set the default hostname of your server by providing the IP or DNS name], )
# ARG_OPTIONAL_BOOLEAN([all],a, [Select all available StreamPipes services])
# ARG_POSITIONAL_MULTI([operation], [The StreamPipes operation (operation-name) (service-name (optional))], 2, [], [])
# ARG_TYPE_GROUP_SET([operation], [type string], [operation], [start,stop,restart,update,set-template,log,list-available,list-active,list-templates,activate,add,deactivate,clean,remove-settings,generate-compose-file])
# ARG_DEFAULTS_POS
# ARG_HELP([This script provides advanced features to run StreamPipes on your server])
# ARG_VERSION([echo This is the StreamPipes dev installer v0.1])
# ARGBASH_SET_INDENT([  ])
# ARGBASH_GO

# [ <-- needed because of Argbash

endEcho() {
	echo ''
	echo $1
}

moveSystemConfig() {
  if [ -e ./templates/"$1" ]; then
		cp ./templates/$1 active-services
	  echo "Set configuration for $1" 
	else
		echo "Configuration $1 was not found"
	fi
}


getCommand() {
    command="docker-compose -f docker-compose.yml"
    while IFS='' read -r line || [[ -n "$line" ]]; do
        command="$command -f ./services/$line/docker-compose.yml"
    done < "./active-services"
}

startStreamPipes() {

	if [ ! -f "./active-services" ]; 
	then
		moveSystemConfig active-services
	fi

	if [ ! -f "./.env" ]; 
    then
		sed "s/##IP##/${ip}/g" ./tmpl_env > .env
	fi
    getCommand
		echo "Starting StreamPipes ${_arg_operation[1]}"
    $command up -d ${_arg_operation[1]}

    endEcho "StreamPipes started ${_arg_operation[1]}"
}

updateStreamPipes() {
    getCommand

		echo "Updating StreamPipes ${_arg_operation[1]}"
    $command up -d ${_arg_operation[1]}

		endEcho "Services updated"
}

updateServices() {
    getCommand
    $command pull ${_arg_operation[1]}

    endEcho "Service updated. Execute sp restart ${_arg_operation[1]} to restart service"
}

stopStreamPipes() {
    getCommand

		echo "Stopping StreamPipes ${_arg_operation[1]}"
    if [ "${_arg_operation[1]}" = "" ]; 
		then
    	$command down
		else
    	$command stop ${_arg_operation[1]}
    	$command rm -f ${_arg_operation[1]}
		fi

    endEcho "StreamPipes stopped ${_arg_operation[1]}"
}

restartStreamPipes() {
	getCommand
	echo "Restarting StreamPipes."
	$command restart ${_arg_operation[1]}

  endEcho "StreamPipes restarted ${_arg_operation[1]}"

}

logServices() {
    getCommand
    $command logs ${_arg_operation[1]}
}

cleanStreamPipes() {
    stopStreamPipes
    rm -r ./config
    endEcho "All configurations of StreamPipes have been deleted."
}

removeStreamPipesSettings() {
    stopStreamPipes
		rm .env
}

resetStreamPipes() {
    cleanStreamPipes
    rm .env
    echo "All configurations of StreamPipes have been deleted."
}

listAvailableServices() {
	echo "Available services:"
  cd services
  for dir in */ ; do
  	echo $dir | sed "s/\///g" 
  done
  cd ..
}

listActiveServices() {
	echo "Active services:"
	cat active-services
}

listTemplates() {
	echo "Available Templates:"
  cd templates
  for file in * ; do
  	echo $file 
  done
	cd ..
}


deactivateService() {
    if [ "$_arg_all" = "on" ]; 
    then
        removeAllServices
    else
        if grep -iq "${_arg_operation[1]}" active-services;then 
            sed -i "/${_arg_operation[1]}/d" ./active-services
            echo "Service ${_arg_operation[1]} removed"
            else
            echo "Service ${_arg_operation[1]} is currently not running"
        fi	
    fi
}

activateService() {
	addService
	updateStreamPipes
}

addService() {
    if [ "$_arg_all" = "on" ]; 
    then
        addAllServices
    else
        if grep -iq "${_arg_operation[1]}" active-services;then 
            echo "Service ${_arg_operation[1]} already exists"
        else
            echo ${_arg_operation[1]} >> ./active-services
        fi
    fi
    
}

removeAllServices() {
    stopStreamPipes
    > active-services
}

setTemplate() {
  moveSystemConfig ${_arg_operation[1]}
}

addAllServices() {
    cd services
    for dir in */ ; do
        service_name=`echo $dir | sed "s/\///g"` 
        if grep -iq "$service_name" ../active-services;then 
            echo "Service $service_name already exists"
        else
            echo $service_name >> ../active-services
        fi
    done
    cd ..
    updateStreamPipes
}

export COMPOSE_CONVERT_WINDOWS_PATHS=1
cd "$(dirname "$0")"

if [ "$_arg_operation" = "start" ];
then
    startStreamPipes
fi

if [ "$_arg_operation" = "stop" ];
then
    stopStreamPipes
fi

if [ "$_arg_operation" = "restart" ];
then
    restartStreamPipes
fi

if [ "$_arg_operation" = "clean" ];
then
    cleanStreamPipes
fi

if [ "$_arg_operation" = "remove-settings" ];
then
    removeStreamPipesSettings
fi

if [ "$_arg_operation" = "activate" ];
then
    activateService
fi

if [ "$_arg_operation" = "add" ];
then
    addService
fi


if [ "$_arg_operation" = "deactivate" ];
then
    deactivateService
fi

if [ "$_arg_operation" = "list-available" ];
then
    listAvailableServices
fi

if [ "$_arg_operation" = "list-active" ];
then
    listActiveServices
fi

if [ "$_arg_operation" = "list-templates" ];
then
    listTemplates
fi

if [ "$_arg_operation" = "update" ];
then
    updateServices
fi

if [ "$_arg_operation" = "log" ];
then
    logServices
fi

if [ "$_arg_operation" = "reset" ];
then
    resetStreamPipes
fi

if [ "$_arg_operation" = "set-template" ];
then
    setTemplate
fi

if [ "$_arg_operation" = "nil" ];
then
    print_help
fi

# ] <-- needed because of Argbash
