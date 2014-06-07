<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

<meta http-equiv="content-type" content="text/html; charset=utf-8" />

<meta name="description" content="This will make sure, that the latest release version of Plex Media Server in installed on a QNAP device" />

<meta name="keywords" content="Plex Media Server, QNAP, PlexInst, dane22" />

<meta name="author" content="dane22 aka. Tommy Mikkelsen, a Plex forum member" />

<link rel="stylesheet" type="text/css" href="css/index.css" media="screen" />

<title>Plex Media Server Installer for QNAP</title>

</head>

	<body>

		<div id="wrapper">
			<?php include 'includes/header.php';?>
			
		<div id="about">

<p>This will make sure, that Plex is running the latest version from Plex Inc.</p>

<?php
echo "Today is " . date("Y/m/d") . "<br>";
echo "Today is " . date("Y.m.d") . "<br>";
echo "Today is " . date("Y-m-d") . "<br>";
echo "Today is " . date("l");
?>

<br />

<?php
$message=shell_exec("scripts/plexinst.sh start 2>&1");
      print_r($message);
?>


		</div>

<p>Some text.</p>
<p>Some more text.</p>
			


			<?php include 'includes/footer.php';?>
		</div> <!-- End #wrapper -->

	</body>

</html>

