<?php
// Sample for mqtt message publish for CloudPRNT Version MQTT

require_once("cputil.php");

/*
	Handle http GET requests and create MQTT message(topic, payload).
*/
function handleGETRequestForPublishMessage($mac, $method, $option = "") {

    if ($method === "request-client-status") {
        // check CloudPRNT MQTT Protocol. Trigger POST or not.
        $parsed = loadParsedServerSettingsJson();

        if (isset($parsed) && !empty($parsed)) {
            $useTriggerPOST = $parsed['settingForMQTT']['useTriggerPOST'];
        }

        if ($useTriggerPOST) {
            $method = "request-post";
        } else {
            $method = "request-client-status";
        }

        $topic = "star/cloudprnt/to-device/{$mac}/{$method}";

        $payload = array();
        $payload['title'] = "$method";

    } elseif ($method === "request-post") {
        $topic = "star/cloudprnt/to-device/{$mac}/{$method}";
        $payload = array();
        $payload['title'] = "$method";

    } elseif ($method === "print-job") {
        $topic = "star/cloudprnt/to-device/{$mac}/{$method}";
        $payload = array();
        $payload['title'] = "$method";
        $payload['jobToken'] = substr(str_shuffle('1234567890abcdefghijklmnopqrstuvwxyz'), 0, 16);

        if ($option === "url") {
            $payload['jobType'] = "url";
            $payload['mediaTypes'] = ["application/vnd.star.starprnt"];
            $printData = (((!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ) ? "https://" : "http://").$_SERVER['HTTP_HOST'].'/php_queue/cloudprnt.php';
            $payload['printData'] = $printData;
        }
        else { // $option === "raw"
            $payload['jobType'] = "raw";
            $payload['mediaTypes'] = ["text/plain"];

            $textData = "
StarMicoronics.

CloudPRNT Version MQTT
Print by Full MQTT.
";
            $printData = $textData;
            $payload['printData'] = $printData;

            $payload['printerControl'] = array();
            $payload['printerControl']['cutter'] = array("type" => "full", "feed" => true);
        }

    } else {
        // ignore
    }

    $result = publishMqttMessage($topic, json_encode($payload, JSON_UNESCAPED_SLASHES));

    if ($result) {
        http_response_code(200);
    } else {
        http_response_code(400);
    }

    return $result;
}

/*
	Publish MQTT Message using awsiot_mqtt
*/
function publishMqttMessage($topic, $payload) {
    $command = "awsiot_mqtt pub -t '{$topic}' -m '{$payload}'";

    exec($command, $output, $result);

    if ($result != 0) {
        // awsiot_mqtt pub failed
        return false;
    }
    return true;
}

/*
    Load cloudprnt-setting.json
*/
function loadParsedServerSettingsJson() {
    if (substr(PHP_OS,0,3) == 'WIN') {
        if (file_exists(dirname(__FILE__).'\cloudprnt-setting.json')) {
            $serverSettingJson = file_get_contents(dirname(__FILE__).'\cloudprnt-setting.json');
        }
    } else {
        if (file_exists(dirname(__FILE__).'/cloudprnt-setting.json')) {
            $serverSettingJson = file_get_contents(dirname(__FILE__).'/cloudprnt-setting.json');
        }
    }

    if (isset($serverSettingJson) && !empty($serverSettingJson)) {
        $parsed = json_decode($serverSettingJson, true);
    }

    return $parsed;
}

?>
