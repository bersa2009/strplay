<?php
header('Content-Type: text/html');
$query = $_GET['q'] ?? '';
$results = []; // Veritabanından arama
echo '<div class="search-results">';
foreach ($results as $result) {
    echo '<div class="song-item"><h3>' . $result['title'] . '</h3><input type="hidden" name="v" value="' . $result['video_id'] . '"></div>';
}
echo '</div>';
?>