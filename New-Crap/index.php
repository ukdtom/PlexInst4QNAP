<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>

<meta http-equiv="content-type" content="text/html; charset=utf-8" />

<meta name="description" content="This will make sure, that the latest release version of Plex Media Server in installed on a QNAP device" />

<meta name="keywords" content="Plex Media Server, QNAP, PlexInst, dane22" />

<meta name="author" content="dane22 aka. Tommy Mikkelsen, a Plex forum member" />

<link rel="stylesheet" type="text/css" href="css/index.css" media="screen" />

<?php
	function InstallPlex(){


echo "Hello world!";


}

?>

<title>Plex Media Server Installer for QNAP</title>

</head>

	<body>

		<div id="wrapper">
			<?php include 'includes/header.php';?>			
		<div id="about">

<p>This will make sure, that Plex is running the latest version from Plex Inc.</p>

<?php
	echo "Today is ";
	echo date("Y/m/d");
	echo  ".";
	
?>
<br/>
<br/>
<?php
	echo "Installed version is detected as: ";



	$PlexVersion=shell_exec("scripts/checkinstalled.sh 2>&1");
	print_r($PlexVersion);
?> 
	
<br/>

		</div>

<br/>

<form><input type="button" value="Get newest version from Plex" onClick=InstallPlex()></form>
	

<form action="InstallPlex.php" method=post">
<input type=submit value="Install Plex">
</form>
		


			<?php include 'includes/footer.php';?>
		</div> <!-- End #wrapper -->

	</body>

</html>

