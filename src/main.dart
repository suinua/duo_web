import 'dart:html';

import 'audio.dart';
import 'script.dart';

void main() {
  var script = Script();
  script.fetchData().then((value){
    var audio = Audio(script);
    script.generateSectionHtmlElement(audio);
  });


  querySelector('.show-hidden-image')?.onClick.listen((event) {
    var bookScreen = querySelector('#book-screen');
    if (bookScreen?.style.display == 'none') {
      bookScreen?.style.display = '';

      querySelector('.image-wrap')?.removeAttribute('style');

      querySelector('.script-play-bar-wrap')?.removeAttribute('style');
    } else {
      if (window.screen!.width! < 640) {
        //ちいさく
        bookScreen?.style.display = 'none';
        querySelector('.image-wrap')
          ?..style.height = '2%'
          ..style.visibility = 'visible';

        //こっちをでかくする
        querySelector('.script-play-bar-wrap')?.style.height = '60%';
      } else {
        //ちいさく
        bookScreen?.style.display = 'none';
        querySelector('.image-wrap')
          ?..style.width = '2%'
          ..style.visibility = 'visible';

        //こっちをでかくする
        querySelector('.script-play-bar-wrap')?.style.width = '78%';
      }
    }
  });
}
