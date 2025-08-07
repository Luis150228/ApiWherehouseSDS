<?php
include_once "../classes/reportsMontheut.class.php";

$_consult = new valores;

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, PUT, DELETE, GET');
// header('Content-Type: application/json; charset=UTF-8');


$contBody = file_get_contents('php://input');
$bodyJson = json_decode($contBody, true);
$headers = getallheaders();
$fechaSub = date('Y-m-d', strtotime('-1 day'));
// foreach ($_GET as $key => $value) {
//     echo $key.'=>'.$value.'<br>';
// }

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (isset($headers['token']) && isset($_GET['print'])) {
        $dataClass = $_consult->createReports($headers['token'], $_GET['print']);
    } else {
        http_response_code(203);
    }
} else if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (isset($headers['token'])) {
        $dataClass = $_consult->eut_monthReports($headers['token'], $contBody);
    }
    http_response_code(200);
} else if ($_SERVER['REQUEST_METHOD'] == 'PUT') {
    http_response_code(200);
} else if ($_SERVER['REQUEST_METHOD'] == 'DELETE') {
    http_response_code(200);
} else {
    http_response_code(400);
}

http_response_code($dataClass['code']);
echo json_encode($dataClass);
// print_r($dataClass);
