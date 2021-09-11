import 'dart:html';

import 'script.dart';

class Audio {
  final Script _script;

  int _currentSection;
  int _currentPhrase;


  late AudioElement _audioElement;
  bool nowPlaying = false;

  Audio(this._script, {int currentSection = 1, int currentPhrase = 1})
      : _currentSection = currentSection,
        _currentPhrase = currentPhrase {

    //audio
    _audioElement = AudioElement();
    _audioElement.onEnded.listen((event) {
      if (nowPlaying) {
        toPhrase(_currentPhrase + 1);
        play();
      }
    });

    //シークバー
    _audioElement.onTimeUpdate.listen((event) {
      var percentage = (_audioElement.currentTime / _audioElement.duration) * 100;
      querySelector('.seekbar-gauge')?.style.width = '$percentage%';
    });

    var seekbar = querySelector('.seekbar');
    seekbar?.onClick.listen((MouseEvent event) {
      var clickX = event.client.x;

      var clientRect = seekbar.getBoundingClientRect();
      var positionX = clientRect.left + window.pageXOffset;

      var x = clickX - positionX;

      var width = seekbar.clientWidth;
      querySelector('.seekbar-gauge')?.style.width = '${(x / width)*100}%';
      _audioElement.currentTime = _audioElement.duration * (x / width);
    });

    //再生ボタン
    var playButton = querySelector('.play-button');
    playButton?.onClick.listen((event) {
        if (nowPlaying) {
          pause();
          playButton.innerHtml = '<span class="material-icons">play_arrow</span>';
        } else {
          play(time: _audioElement.currentTime as double);
          playButton.innerHtml = '<span class="material-icons">pause</span>';
        }
    });

    //スキップネクストボタン
    querySelector('.skip-next-button')?.onClick.listen((event) => skipNext());
    //スッキプ１個前ボタン
    querySelector('.skip-pre-button')?.onClick.listen((event) => skipPrevious());
  }

  void toSection(int section) {
    _currentSection = section;

    var phrase = _script.getSectionFirst(_currentSection);
    _currentPhrase = phrase.phraseNumber;
    _audioElement.currentTime = 0;

    _BookImageController.update(_currentPhrase);
    _ScriptContextController.update(phrase);
  }

  void toPhrase(int phraseNumber) {
    var phrase = _script.getScriptContext(phraseNumber: phraseNumber);

    _currentSection = phrase.sectionNumber;
    _currentPhrase = phrase.phraseNumber;
    _audioElement.currentTime = 0;

    _BookImageController.update(_currentPhrase);
    _ScriptContextController.update(phrase);
  }

  void play({double time = 0}) {
    nowPlaying = true;

    _audioElement.src = 'resources/sound_sources/$_currentPhrase.mp3';
    _audioElement.currentTime = time;
    _audioElement.play();
  }

  void pause() {
    _audioElement.pause();
    nowPlaying = false;
  }

  void skipNext() {
    toPhrase(_currentPhrase + 1);
    if (nowPlaying) play();
  }

  void skipPrevious() {
    if (_currentPhrase == 1 || _audioElement.currentTime > 1) {
      _audioElement.currentTime = 0;
      return;
    }

    toPhrase(_currentPhrase - 1);
    if (nowPlaying) play();
  }
}

class _BookImageController {

  static void update(int phraseNumber) {
    var imageElement = querySelector('#book-screen') as ImageElement;
    imageElement.srcset = 'resources/images/$phraseNumber.png';
  }
}

class _ScriptContextController {

  static void update(Phrase phrase) {
    querySelector('.script-en')?.text = phrase.engText;
    querySelector('.script-jp')?.text = phrase.jpText;
    querySelector('.section-number')?.text = 'Section ${phrase.sectionNumber}';
    querySelector('.phrase-number')?.text = 'No ${phrase.phraseNumber}';
  }
}
