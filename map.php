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
      html, body {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      #map {
        height: 100%;
      }
#floating-panel {
  position: absolute;
  top: 10px;
  left: 25%;
  z-index: 5;
  background-color: #fff;
  padding: 5px;
  border: 1px solid #999;
  text-align: center;
  font-family: 'Roboto','sans-serif';
  line-height: 30px;
  padding-left: 10px;
}
      #floating-panel {
        background-color: #fff;
        border: 1px solid #999;
        left: 25%;
        padding: 5px;
        position: absolute;
        top: 10px;
        z-index: 5;
      }
    </style>
  </head>

  <body>
    <div id="floating-panel">
      <button onclick="toggleHeatmap()">Toggle Heatmap</button>
      <button onclick="changeGradient()">Change gradient</button>
      <button onclick="changeRadius()">Change radius</button>
      <button onclick="changeOpacity()">Change opacity</button>
    </div>
    <div id="map"></div>
    <script>
var map, heatmap;
function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    zoom: 7,
    center: {lat: 39.04, lng: -104.99},
    mapTypeId: google.maps.MapTypeId.SATELLITE
  });
  heatmap = new google.maps.visualization.HeatmapLayer({
    data: getPoints(),
    map: map,
    radius: 30,
    dissipating:true,
    maxIntensity:<?php
      $query = 'select MAX(max) from peittrei.wxdata_avg';
      $result = pg_query($query) or die('Query failed: ' . pg_last_error());
      $line = pg_fetch_array($result, null, PGSQL_ASSOC);
      echo $line["max"];
    ?>,
  });
}
function toggleHeatmap() {
  heatmap.setMap(heatmap.getMap() ? null : map);
}
function changeGradient() {
  var gradient = [
    'rgba(0, 255, 255, 0)',
    'rgba(0, 255, 255, 1)',
    'rgba(0, 191, 255, 1)',
    'rgba(0, 127, 255, 1)',
    'rgba(0, 63, 255, 1)',
    'rgba(0, 0, 255, 1)',
    'rgba(0, 0, 223, 1)',
    'rgba(0, 0, 191, 1)',
    'rgba(0, 0, 159, 1)',
    'rgba(0, 0, 127, 1)',
    'rgba(63, 0, 91, 1)',
    'rgba(127, 0, 63, 1)',
    'rgba(191, 0, 31, 1)',
    'rgba(255, 0, 0, 1)'
  ]
  heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
}
function changeRadius() {
  heatmap.set('radius', heatmap.get('radius') ? null : 20);
}
function changeOpacity() {
  heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
}
// Heatmap data: 500 Points
function getPoints() {
  return [

  <?php
// Performing SQL query
$query = 'select latitude, longitude, AVG(max) from peittrei.wxdata_avg where min > -9999 AND (';
//get the years
$i=0;
foreach ($_POST['year'] as $year){
  $query = $query."year = ".$year;
  $i++;
  if($i!=count($_POST['year'])){
    $query = $query." OR ";
  }
}
 $query = $query.") AND (";
//get the seasons
$i=0;
foreach ($_POST['seasons'] as $season){
  $query = $query.'season = '."'".$season."'";
  $i++;
  if($i!=count($_POST['seasons'])){
    $query = $query." OR ";
  }
}
$query = $query.") GROUP BY latitude, longitude";

$result = pg_query($query) or die('Query failed: ' . pg_last_error());

// Printing results in HTML
//while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {

//        
//}
while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
       echo "{location: new google.maps.LatLng(".$line["latitude"].",".$line["longitude"]."), weight: ".$line["avg"]."},";
    }    
  ?>
  ]
}
    </script>
    <script async defer
        src="https://maps.googleapis.com/maps/api/js?signed_in=true&libraries=visualization&callback=initMap">
    </script>
  </body>
</html>

<?php
// Free resultset
pg_free_result($result);

// Closing connection
pg_close($dbconn);
?>