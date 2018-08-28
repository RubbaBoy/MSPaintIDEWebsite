import 'package:MSPaintIDEWebsite/info_card_data.dart';
import 'package:MSPaintIDEWebsite/review.dart';
import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/theme/dark_theme.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const [
    'app_component.css',
    'package:angular_components/app_layout/layout.scss.css',
  ],
  templateUrl: 'app_component.html',
  directives: const [
    DarkThemeDirective,
    CORE_DIRECTIVES,
    materialDirectives,
    MaterialExpansionPanel,
    MaterialButtonComponent,
    MaterialIconComponent
  ],
  providers: const [
    materialProviders
  ],
)
class AppComponent implements OnInit {
  var randomMessage;
  List<String> screenshots = List<String>();
  List<Review> reviews = List<Review>();
  List<Review> activeReviews = List<Review>();
  List<InfoCardData> features = List<InfoCardData>();
  List<InfoCardData> advantages = List<InfoCardData>();
  var index = 1;
  bool movingUp = false;
  bool paused = false;
  bool showReviewInfo = false;
  bool showShare = false;
  bool showAllReviews = false;
  bool darkTheme = false;
  String reviewInfoText = '';
  String reviewInfoAuthor = '';
  String reviewInfoUrl = '';
  String bigScreenshot = '';

  void toggleDarkTheme() {
    darkTheme = !darkTheme;

    if (darkTheme) {
      document.querySelector('html').classes.add('dark_body');
    } else {
      document.querySelector('html').classes.remove('dark_body');
    }
  }

  void routeTo(url) {
    window.location.assign(url);
  }

  Future getData() async {
    var path = 'https://ms-paint-i.de/data.json';
    try {
      return await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
    }
  }

  void processData(data) {
    var json = jsonDecode(data);

    for (var quote in json['quotes'].toList()) {
      reviews.add(new Review(quote['quote'], quote['author'], quote['url']));
    }

    randomMessage = (json['messages'].toList()..shuffle()).first;

    for (var feature in json['features'].toList()) {
      features.add(new InfoCardData(feature['title'], feature['text']));
    }

    for (var advantage in json['advantages'].toList()) {
      advantages.add(new InfoCardData(advantage['title'], advantage['text']));
    }

    for (var screenshot in json['screenshots'].toList()) {
      screenshots.add(screenshot['url']);
    }

    bigScreenshot = screenshots[0];

    removePreloader();

    startReviewCycle();
  }

  void showReviewInfoDialog(Review review) {
    reviewInfoText = review.message;
    reviewInfoAuthor = review.author;
    reviewInfoUrl = review.url;
    showReviewInfo = true;
    paused = true;

    new Future.delayed(const Duration(milliseconds: 10), () {
      document.activeElement.blur();
    });
  }

  void hideReviewInfoDialog() {
    showReviewInfo = false;
    paused = false;
  }

  void updateActiveReviews() {
    var first = reviews[getNext()];
    var second = activeReviews[2];
    var third = activeReviews[1];
    var fourth = activeReviews[0];

    first.rendered = true;
    second.rendered = true;
    third.rendered = true;
    fourth.rendered = true;

    fourth.startDisappearing(this);

    activeReviews.add(first);

    index++;
  }

  void removeLast() {
    activeReviews.removeAt(0);
    movingUp = false;
  }

  int getNext([var adding = 1]) {
    int temp = index + adding;
    temp = temp - ((temp ~/ reviews.length) * reviews.length);
    return temp;
  }

  void removePreloader() {
    new Future.delayed(const Duration(milliseconds: 500), () {
      var element = querySelector('my-app');
      if (element.classes.contains("completed")) {
        querySelector('#preloader-wrapper').classes.add("disappear-preloader");

        new Future.delayed(const Duration(seconds: 1), () {
          querySelector('#preloader-wrapper').remove();
        });
      } else {
        removePreloader();
      }
    });
  }

  @override
  ngOnInit() {
    getData().then(processData);
  }

  void startReviewCycle() {
    activeReviews.add(reviews[reviews.length - 1]..rendered = true);
    activeReviews.add(reviews[0]..rendered = true);
    activeReviews.add(reviews[1]..rendered = true);

    updateStuff();
  }

  void updateStuff() {
    new Future.delayed(const Duration(seconds: 2), () {
      void noDelay() {
        if (document.querySelector(".review-card:hover") == null && !paused) {
          updateActiveReviews();
          updateStuff();
        } else {
          new Future.delayed(const Duration(milliseconds: 250), noDelay);
        }
      }

      noDelay();
    });
  }
}
