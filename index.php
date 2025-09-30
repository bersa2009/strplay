<?php
// Simple search UI + PHP rendering scaffold
header('Content-Type: text/html; charset=utf-8');

$query = isset($_GET['q']) ? trim((string)$_GET['q']) : '';
// Placeholder: fetch search results from DB based on $query
// $results = mySearch($query);
$results = [];
?>
<!doctype html>
<html lang="tr">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Search</title>
    <style>
        :root{--bg:#f2f3f7;--card:#ffffff;--shadow-dark:#c8d0e7;--shadow-light:#ffffff;--text:#1a1a1a;--muted:#6b7280;--accent:#6366f1}
        *{box-sizing:border-box}
        html,body{height:100%}
        body{margin:0;background:var(--bg);font-family:ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial,"Apple Color Emoji","Segoe UI Emoji";color:var(--text);display:flex;align-items:center;justify-content:center;padding:24px}
        .card{width:min(720px,92vw);min-height:540px;background:var(--card);border-radius:24px;box-shadow:20px 20px 60px var(--shadow-dark),-20px -20px 60px var(--shadow-light);padding:28px 28px 40px;position:relative}
        .row{display:flex;align-items:center;gap:12px}
        .space{height:16px}
        h1{margin:0 0 8px 0;font-size:28px}
        form{display:flex;align-items:center;gap:10px}
        .search{flex:1;display:flex;align-items:center;background:var(--card);border-radius:14px;box-shadow:inset 8px 8px 16px var(--shadow-dark),inset -8px -8px 16px var(--shadow-light);padding:10px 14px}
        .search input{flex:1;border:0;outline:0;background:transparent;font-size:16px;color:var(--text)}
        .icon-btn{width:42px;height:42px;border-radius:12px;background:var(--card);box-shadow:8px 8px 16px var(--shadow-dark),-8px -8px 16px var(--shadow-light);display:grid;place-items:center;border:none;cursor:pointer}
        .list{margin-top:18px}
        .item{display:flex;align-items:center;justify-content:space-between;padding:12px 10px;border-radius:14px}
        .item:hover{box-shadow:8px 8px 16px var(--shadow-dark),-8px -8px 16px var(--shadow-light)}
        .item .left{display:flex;align-items:center;gap:14px}
        .bullet{width:40px;height:40px;border-radius:50%;display:grid;place-items:center;background:var(--card);box-shadow:inset 8px 8px 16px var(--shadow-dark),inset -8px -8px 16px var(--shadow-light)}
        .label{font-size:18px}
        .results{margin-top:20px}
        .song{padding:12px 14px;border-radius:12px;background:var(--card);box-shadow:8px 8px 16px var(--shadow-dark),-8px -8px 16px var(--shadow-light);}
        .empty{color:var(--muted);text-align:center;margin-top:24px}
        .footer{position:absolute;left:24px;right:24px;bottom:14px;height:6px;border-radius:6px;background:linear-gradient(90deg,#e5e7eb,#d1d5db)}
        .pager{position:absolute;left:0;right:0;bottom:54px;display:flex;gap:28px;align-items:center;justify-content:center;color:#9ca3af}
        .dot{width:36px;height:36px;border-radius:50%;background:var(--card);box-shadow:inset 8px 8px 16px var(--shadow-dark),inset -8px -8px 16px var(--shadow-light)}
        a,button{color:inherit}
    </style>
</head>
<body>
    <div class="card">
        <h1>Search</h1>
        <form method="get" action="">
            <div class="search" role="search">
                <input type="text" name="q" placeholder="Şarkı, sanatçı..." value="<?php echo htmlspecialchars($query, ENT_QUOTES, 'UTF-8'); ?>" autocomplete="off" />
            </div>
            <button class="icon-btn" aria-label="Ara" type="submit">🔍</button>
        </form>

        <div class="list">
            <div class="item">
                <div class="left">
                    <div class="bullet">➤</div>
                    <div class="label">Listen</div>
                </div>
                <button class="icon-btn" aria-label="Seç">—</button>
            </div>
            <div class="item">
                <div class="left">
                    <div class="bullet">✦</div>
                    <div class="label">Watch Video</div>
                </div>
                <button class="icon-btn" aria-label="Seç">✓</button>
            </div>
            <div class="item">
                <div class="left">
                    <div class="bullet">✪</div>
                    <div class="label">Download</div>
                </div>
                <button class="icon-btn" aria-label="Seç">□</button>
            </div>
        </div>

        <div class="results">
            <?php
            echo '<div class="search-results">';
            foreach ($results as $result) {
                $title = isset($result['title']) ? $result['title'] : '';
                $videoId = isset($result['video_id']) ? $result['video_id'] : '';
                echo '<div class="song">'
                    . '<h3>' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . '</h3>'
                    . '<input type="hidden" name="v" value="' . htmlspecialchars($videoId, ENT_QUOTES, 'UTF-8') . '">'
                    . '</div>';
            }
            echo '</div>';

            if ($query !== '' && empty($results)) {
                echo '<div class="empty">Sonuç bulunamadı.</div>';
            }
            ?>
        </div>

        <div class="pager">
            <span>◀</span>
            <span class="dot"></span>
            <span>▶</span>
        </div>
        <div class="footer"></div>
    </div>

    <script>
        // Placeholder for future interactions
        // document.querySelectorAll('.item .icon-btn').forEach(btn => { ... })
    </script>
</body>
</html>

