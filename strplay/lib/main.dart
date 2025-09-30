import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.strplay.audio',
      androidNotificationChannelName: 'Strplay Music',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
    ),
  );
  
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strplay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
        Locale('es', ''),
        Locale('ru', ''),
      ],
      home: const MusicSearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicSearchScreen extends StatefulWidget {
  const MusicSearchScreen({super.key});
  
  @override
  State<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends State<MusicSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode _ytExplode = YoutubeExplode();
  final Dio _dio = Dio();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String _currentPlaying = '';
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Locale _currentLocale = const Locale('tr', '');
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isCameraInitialized = false;
  
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _setupDio();
    _initializeCamera();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    _ytExplode.close();
    _dio.close();
    _cameraController?.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });
    });

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });
  }

  void _setupDio() {
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    };
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleVideoRecording() async {
    if (!_isCameraInitialized || _cameraController == null) {
      _showErrorSnackBar('Kamera hazır değil');
      return;
    }

    try {
      if (_isRecording) {
        await _cameraController!.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });
        _showSuccessSnackBar('Video kaydı durduruldu');
      } else {
        await _cameraController!.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
        _showSuccessSnackBar('Video kaydı başlatıldı');
      }
    } catch (e) {
      _showErrorSnackBar('Video kayıt hatası: $e');
    }
  }

  Future<void> _searchMusic(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });

    try {
      final searchResults = await _ytExplode.search.search(query);
      
      List<Map<String, dynamic>> results = [];
      
      for (var video in searchResults.take(20)) {
        final skipVidsUrl = await _getSkipVidsIframeUrl(video.id.value);
        
        results.add({
          'video_id': video.id.value,
          'title': video.title,
          'author': video.author,
          'duration': video.duration?.toString().split('.').first ?? '00:00',
          'thumbnail': 'https://img.youtube.com/vi/${video.id.value}/0.jpg',
          'skipvids_url': 'https://skipvids.com/?v=${video.id.value}',
          'iframe_url': skipVidsUrl,
        });
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('${AppLocalizations.of(context)!.searchError}: ${e.toString()}');
    }
  }

  Future<String?> _getSkipVidsIframeUrl(String videoId) async {
    try {
      final response = await http.get(
        Uri.parse('https://skipvids.com/?v=$videoId'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final iframe = document.querySelector('iframe');
        
        if (iframe != null) {
          return iframe.attributes['src'];
        }
      }
    } catch (e) {
      // ignore
    }
    
    return 'https://www.youtube.com/embed/$videoId?enablejsapi=1&rel=0&fs=0&autoplay=0';
  }

  Future<void> _playAudio(Map<String, dynamic> song) async {
    try {
      final video = await _ytExplode.videos.get(song['video_id']);
      final manifest = await _ytExplode.videos.streamsClient.getManifest(video.id);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      
      if (audioStream != null) {
        await _audioPlayer.setUrl(audioStream.url.toString());
        await _audioPlayer.play();
        
        setState(() {
          _currentPlaying = '${song['title']} - ${song['author']}';
        });
        
        await AudioService.play();
        
        _showSuccessSnackBar('${AppLocalizations.of(context)!.playing}: ${song['title']}');
      } else {
        _showErrorSnackBar(AppLocalizations.of(context)!.audioStreamNotFound);
      }
    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.playbackError}: ${e.toString()}');
    }
  }

  Future<void> _playVideo(Map<String, dynamic> song) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: WebView(
            initialUrl: song['skipvids_url'],
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            navigationDelegate: (request) {
              if (request.url.contains('skipvids.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _downloadSong(Map<String, dynamic> song) async {
    try {
      final permission = await Permission.storage.request();
      if (permission != PermissionStatus.granted) {
        _showErrorSnackBar(AppLocalizations.of(context)!.permissionRequired);
        return;
      }

      _showSuccessSnackBar(AppLocalizations.of(context)!.downloadStarted);

      final video = await _ytExplode.videos.get(song['video_id']);
      final manifest = await _ytExplode.videos.streamsClient.getManifest(video.id);
      final audioStream = manifest.audioOnly.withHighestBitrate();

      if (audioStream == null) {
        _showErrorSnackBar(AppLocalizations.of(context)!.audioStreamNotFound);
        return;
      }

      final fileName = '${song['title']}_${song['author']}.mp3'
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      await _dio.download(
        audioStream.url.toString(),
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            _showSuccessSnackBar('İndiriliyor: $progress%');
          }
        },
      );

      _showSuccessSnackBar('${AppLocalizations.of(context)!.downloadCompleted}: $fileName');

    } catch (e) {
      _showErrorSnackBar('${AppLocalizations.of(context)!.downloadError}: ${e.toString()}');
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      await AudioService.pause();
    } else {
      await _audioPlayer.play();
      await AudioService.play();
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    await AudioService.stop();
    setState(() {
      _currentPlaying = '';
      _currentPosition = Duration.zero;
    });
  }

  void _changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return MaterialApp(
      locale: _currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
        Locale('es', ''),
        Locale('ru', ''),
      ],
      home: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          centerTitle: true,
          actions: [
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language),
              onSelected: _changeLanguage,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: const Locale('tr', ''),
                  child: Text(l10n.turkish),
                ),
                PopupMenuItem(
                  value: const Locale('en', ''),
                  child: Text(l10n.english),
                ),
                PopupMenuItem(
                  value: const Locale('es', ''),
                  child: Text(l10n.spanish),
                ),
                PopupMenuItem(
                  value: const Locale('ru', ''),
                  child: Text(l10n.russian),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchMusic(_searchController.text),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onSubmitted: _searchMusic,
              ),
            ),

            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(l10n.searching),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.searchMusicHint,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final song = _searchResults[index];
                        return _buildSongCard(song);
                      },
                    ),
            ),

            if (_currentPlaying.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    top: BorderSide(color: Colors.blue[200]!),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${l10n.playing}: $_currentPlaying',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: _togglePlayPause,
                        ),
                        Expanded(
                          child: Slider(
                            value: _currentPosition.inMilliseconds.toDouble(),
                            max: _totalDuration.inMilliseconds.toDouble(),
                            onChanged: (value) {
                              _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                        ),
                        Text(_formatDuration(_currentPosition)),
                        const Text(' / '),
                        Text(_formatDuration(_totalDuration)),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: _stopAudio,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongCard(Map<String, dynamic> song) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            song['thumbnail'],
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note),
              );
            },
          ),
        ),
        title: Text(
          song['title'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${song['author']} • ${song['duration']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () => _downloadSong(song),
              tooltip: l10n.download,
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.red),
              onPressed: () => _playVideo(song),
              tooltip: l10n.watchVideo,
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              onPressed: () => _playAudio(song),
              tooltip: l10n.listen,
            ),
            IconButton(
              icon: Icon(
                _isRecording ? Icons.videocam_off : Icons.videocam,
                color: _isRecording ? Colors.red : Colors.orange,
              ),
              onPressed: _toggleVideoRecording,
              tooltip: _isRecording ? 'Video Kaydını Durdur' : 'Video Kaydet',
            ),
          ],
        ),
      ),
    );
  }
}

class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.rewind,
          if (state.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.fastForward,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: AudioProcessingState.ready,
        playing: state.playing,
      ));
    });
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {}

  @override
  Future<void> setShuffleMode(bool enabled) async {}

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {}
}

