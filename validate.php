<?php

$hex = $_POST['receipt'];
$testing = $_POST['testing'];
$password = "Your Shared Secret Key Here";


echo $hex;


if ($testing == 1)
	$url = 'https://sandbox.itunes.apple.com/verifyReceipt';
else 
	$url = 'https://buy.itunes.apple.com/verifyReceipt';

	
$postData = json_encode
(
array(
	'receipt-data' => $hex,
	'password' => $password,
	)
);


function do_post_request($url, $data, $optional_headers = null)
{
  $params = array('http' => array(
              'method' => 'POST',
              'content' => $data
            ));
  if ($optional_headers !== null) {
    $params['http']['header'] = $optional_headers;
  }
  $ctx = stream_context_create($params);
  $fp = @fopen($url, 'rb', false, $ctx);
  if (!$fp) {
    throw new Exception("Problem with $url, $php_errormsg");
  }
  $response = @stream_get_contents($fp);
  if ($response === false) {
    throw new Exception("Problem reading data from $url, $php_errormsg");
  }
  return $response;
}

$response = do_post_request($url, $postData);
echo $response;
?>