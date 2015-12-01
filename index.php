<?php
 // Connecting, selecting database
$dbconn = pg_connect("host=flowers.mines.edu dbname=csci403 user=avanderm password=oldpassword")
    or die('Could not connect: ' . pg_last_error());
?>


<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Heatmaps</title>
    <style>
    body {
    overflow:hidden;
}
    iframe{
 position: absolute;
	top: 0px;
	left: 0px;
  
		  height:100vh;
		  width:100vw;
    }
    #sidebar{
    position: absolute;
	top: 50px;
	left: 0px;
	background-color: white;

	width: 130px;
    }
    </style>
  </head>

  <body>

  <iframe name="my_frame" src="map.php">
  	</iframe>

  <form target="my_frame" action="map.php" method="post" id="sidebar">
   <fieldset>
  <legend>Year</legend>
  	<?php
	// Performing SQL query
	$query = 'select distinct year from peittrei.years ORDER BY year';
	$result = pg_query($query) or die('Query failed: ' . pg_last_error());

	while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
       print '<input type="checkbox" name="year[]" value="'.$line["year"].'"> '.$line["year"].'<br>';
    }
    
  ?>
  	</fieldset>
  	 <fieldset>
  <legend>Season</legend>
  <?php
	// Performing SQL query
	$query = 'select distinct season from peittrei.seasons';
	$result = pg_query($query) or die('Query failed: ' . pg_last_error());

	while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
       print '<input type="checkbox" name="seasons[]" value="'.$line["season"].'"> '.$line["season"].'<br>';
    }
    
  ?>
  </fieldset>


  	<input type="submit" value="Submit">
  	


  </body>

</html>

<?php
// Free resultset
pg_free_result($result);

// Closing connection
pg_close($dbconn);
?>