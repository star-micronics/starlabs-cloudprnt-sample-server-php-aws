#!/bin/bash

function callPHP() {
    VAR=$1
    echo "${VAR//'"'/'\"'}"
    php /var/www/html/php_queue/cloudprnt.php "MQTT" "$1"
}

export -f callPHP

exec awsiot_mqtt sub -t='star/cloudprnt/to-server/#' | xargs -d'\n' -I@ bash -c "callPHP '@'"

# Subscribe using awsiot_mqtt.
# Start a PHP program every time an MQTT message is received.
