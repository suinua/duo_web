import 'dart:convert';
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;

var currentSection = 1;
int playingAudioNumber = 1;

Map scripts = <String, Map<String, dynamic>>{};

fb.Storage storage = fb.storage();
bool nowPlaying = false;
AudioElement audioElement = AudioElement();

void main() {
  fb.initializeApp(
      apiKey: 'AIzaSyDSyk_9YhfFaAzg7fV4ic4QJfsBXuNe1rU',
      authDomain: '',
      databaseURL: '',
      projectId: 'duo-web-dc39d',
      storageBucket: 'duo-web-dc39d.appspot.com');

  loadScripts();

  audioElement.onTimeUpdate.listen((event) {
    var percentage = (audioElement.currentTime / audioElement.duration) * 100;
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
    audioElement.currentTime = audioElement.duration * (x / width);
  });

  var element = querySelector('.play-button');
  element?.onClick.listen((_e) {
    if (nowPlaying) {
      audioElement.pause();
      nowPlaying = false;

      element.innerHtml = '<span class="material-icons">play_arrow</span>';
    } else {
      play(currentSection, playingAudioNumber,
          time: audioElement.currentTime as double);

      element.innerHtml = '<span class="material-icons">pause</span>';
    }
  });

  audioElement.onEnded.listen((_e) {
    if (nowPlaying) {
      ++playingAudioNumber;

      if (!scripts[currentSection.toString()].containsKey(playingAudioNumber.toString())) {
        currentSection++;
      }

      play(currentSection, playingAudioNumber);
    }
  });

  querySelector('.show-hidden-image')?.onClick.listen((event) {
    var bookScreen = querySelector('#book-screen');
    if (bookScreen?.style.display == 'none') {
      bookScreen?.style.display = '';

      querySelector('.image-wrap')?.removeAttribute('style');

      querySelector('.script-play-bar-wrap')?.removeAttribute('style');
    } else {
      bookScreen?.style.display = 'none';
      querySelector('.image-wrap')
        ?..style.width = '2%'
        ..style.visibility = 'visible';

      querySelector('.script-play-bar-wrap')?.style.width = '78%';
    }
  });

  querySelector('.skip-pre-button')?.onClick.listen((event) {
    playingAudioNumber--;
    if (!scripts[currentSection.toString()].containsKey
      (playingAudioNumber.toString())) {
      currentSection--;
    }

    if (nowPlaying) {
      play(currentSection, playingAudioNumber);
    } else {
      updateImage(playingAudioNumber);
      updateScript(currentSection, playingAudioNumber);
    }
  });

  querySelector('.skip-next-button')?.onClick.listen((event) {
    playingAudioNumber++;
    if (!scripts[currentSection.toString()].containsKey(playingAudioNumber.toString())) {
      currentSection++;
    }

    if (nowPlaying) {
      play(currentSection, playingAudioNumber);
    } else {
      updateImage(playingAudioNumber);
      updateScript(currentSection, playingAudioNumber);
    }

  });
}

void play(int section, int number, {double time = 0}) {
  updateImage(number);
  updateScript(section, number);

  nowPlaying = true;

  audioElement.src = 'resources/sound_sources/$number.mp3';
  audioElement.currentTime = time;
  audioElement.play();
}

void generateSectionElement() {
  var html = '';
  var sectionSelectorElement = querySelector('.section-selector');
  scripts.forEach((sectionNumber, phrases) {
    html +=
        '''<div class="section-item" id="$sectionNumber">$sectionNumber</div>''';

    phrases.forEach((phraseNumber, phrase) {
      html += '''
          <div class="phrase-hidden" id="parent-section-is-$sectionNumber">
              <div class="phrase-select" id="$phraseNumber"><span class="material-icons">west</span></div>
              <div class="phrase-context">${phrase['en']}</div>
          </div>
        ''';
    });
  });

  sectionSelectorElement?.innerHtml = html;

  querySelectorAll('.section-item').forEach((sectionItem) {
    sectionItem.onClick.listen((event) {
      querySelectorAll('#parent-section-is-${sectionItem.id}')
          .forEach((element) {
        element.className =
            element.className == 'phrase' ? 'phrase-hidden' : 'phrase';
      });
    });
  });

  querySelectorAll('.phrase-select').forEach((element) {
    element.onClick.listen((event) {
      var phraseNumber = element.id;
      var sectionNumber =
          element.parent?.id.replaceFirst('parent-section-is-', '');

      if (sectionNumber != null) {
        currentSection = int.parse(sectionNumber);
        playingAudioNumber = int.parse(phraseNumber);

        if (nowPlaying) {
          play(currentSection, playingAudioNumber);
        } else {
          updateImage(playingAudioNumber);
          updateScript(currentSection, playingAudioNumber);
        }
      }
    });
  });
}

void loadScripts() {
  fb.Storage storage;

  storage = fb.storage();
  storage.ref('script.json').getDownloadURL().then((value) {
    HttpRequest.request(Uri.decodeFull(value.toString())).then((data) {
      scripts = jsonDecode(data.response);
      generateSectionElement();
    });
  });
}

void updateImage(int number) {
  var imageElement = querySelector('#book-screen') as ImageElement;
  imageElement.srcset = 'resources/images/$number.png';
}

void updateScript(int section, int number) {
  var scriptEnElement = querySelector('.script-en') as DivElement;
  var scriptJpElement = querySelector('.script-jp') as DivElement;
  var context = scripts[section.toString()][number.toString()];
  String scriptEn = context['en'];
  String scriptJp = context['jp'];

  var pattern = scriptJp.split(' ')[0];

  scriptEnElement.text = scriptEn.replaceFirst(pattern, '').trimLeft();
  scriptJpElement.text = scriptJp.replaceFirst(pattern, '').trimLeft();
}
