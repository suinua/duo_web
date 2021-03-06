import 'dart:convert';
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;

import 'audio.dart';

class Script {
  final _phraseList = <Phrase>[];

  Future fetchData() async {
    fb.initializeApp(
        apiKey: 'AIzaSyDSyk_9YhfFaAzg7fV4ic4QJfsBXuNe1rU',
        authDomain: '',
        databaseURL: '',
        projectId: 'duo-web-dc39d',
        storageBucket: 'duo-web-dc39d.appspot.com');

    var storage = fb.storage();
    var value = await storage.ref('script.json').getDownloadURL();
    var request = await HttpRequest.request(Uri.decodeFull(value.toString()));

    var json = jsonDecode(request.response);
    json.forEach((sectionNumber, sections) {
      sections.forEach((phraseNumber, phrase) {
        var jp = phrase['jp'].replaceFirst(RegExp('^[0-9]* *'), '');
        var en = phrase['en'].replaceFirst(RegExp('^[0-9]* *'), '');

        _phraseList.add(
            Phrase(int.parse(sectionNumber), int.parse(phraseNumber), jp, en));
      });
    });
  }

  Phrase getScriptContext({required int phraseNumber}) {
    var candidate = _phraseList
        .firstWhere((element) => element.phraseNumber == phraseNumber);
    return candidate;
  }

  Phrase getSectionFirst(int sectionNumber) {
    var candidateList =
        _phraseList.where((element) => element.sectionNumber == sectionNumber);

    Phrase? scriptContext;

    candidateList.forEach((element) {
      if (scriptContext != null) {
        if (element.phraseNumber < scriptContext!.phraseNumber) {
          scriptContext = element;
        }
      } else {
        scriptContext = element;
      }
    });

    assert(scriptContext != null);
    return scriptContext!;
  }

  List<Phrase> findPhrasesBySectionNumber(int sectionNumber) {
    return _phraseList
        .where((element) => element.sectionNumber == sectionNumber)
        .toList();
  }

  void generateSectionHtmlElement(Audio audio) {
    for (var section = 1; section < 46; section++) {
      var list = findPhrasesBySectionNumber(section);

      //セクション表示ボタン
      var sectionSelectButton = DivElement()
        ..text = section.toString()
        ..id = 'not-selected-button'
        ..className = 'section-select-button';

      var sectionSelectorButtonListElement = querySelector('.section-selector-button-list');
      sectionSelectorButtonListElement?.children.add(sectionSelectButton);

      //そのセクションのフレーズリスト
      var phraseListWrap = DivElement()..className = 'phrase-list-wrap-hidden';

      //セクション表示ボタンでフレーズリストの表示、非表示
      sectionSelectButton.onClick.listen((event) {
        querySelectorAll('.phrase-list-wrap').forEach((e) {
          print(e.className);
          e.className = 'phrase-list-wrap-hidden';
        });
        phraseListWrap.className = 'phrase-list-wrap';

        querySelectorAll('#selected-button').forEach((e) {
          e.id = 'not-selected-button';
        });
        sectionSelectButton.id = 'selected-button';
      });
      for (var index = 0; index < list.length; index++) {
        var phrase = list[index];
        var phraseElement = DivElement()..className = 'phrase';
        var phraseSelectButton = DivElement()
          ..className = 'phrase-select'
          ..innerHtml = '<span class="material-icons">west</span>';
        var phraseContextElement = DivElement()
          ..className = 'phrase-context'
          ..text = phrase.engText;

        phraseSelectButton.onClick.listen((event) {
          audio.toPhrase(phrase.phraseNumber);
        });

        phraseElement.children.add(phraseSelectButton);
        phraseElement.children.add(phraseContextElement);
        phraseListWrap.children.add(phraseElement);

        var sectionItemList = querySelector('.phrase-list');
        sectionItemList?.children.add(phraseListWrap);
      }
    }
  }
}

class Phrase {
  final int sectionNumber;
  final int phraseNumber;

  final String jpText;
  final String engText;

  Phrase(this.sectionNumber, this.phraseNumber, this.jpText, this.engText);
}
