import 'package:angular/angular.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:angular_components/angular_components.dart';

import 'review.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: const [
    'app_component.css',
    'package:angular_components/app_layout/layout.scss.css'
  ],
  templateUrl: 'app_component.html',
  directives: const [CORE_DIRECTIVES, materialDirectives],
  providers: const [materialProviders],
)
class AppComponent implements OnInit {
  var randomMessage;
  List<Review> reviews;
  List<Review> activeReviews = new List<Review>();
  var index = -1;
  bool movingUp = false;

  void routeTo(url) {
    window.location.assign(url);
  }

  Future getMessages() async {
    var path = 'https://ms-paint-i.de/messages.json';
    try {
      return await HttpRequest.getString(path);
    } catch (e) {
      print('Couldn\'t open $path');
    }
  }

  void processMessages(messages) {
    randomMessage = (JSON.decode(messages)..shuffle()).first;
  }

  void updateActiveReviews() {
    var first = reviews[getNext(4)];
    var second = reviews[getNext(3)];
    var third = reviews[getNext(2)];
    var fourth = reviews[getNext()];

    first.rendered = true;
//    first.suppressed = true;

    second.rendered = true;
    third.rendered = true;
    fourth.rendered = true;

    fourth.startDisappearing(this);

    activeReviews.add(first);

    print(activeReviews);

    index++;
  }

  void removeLast() {
    activeReviews.removeAt(0);
    movingUp = false;
  }

  int getNext([var adding = 1]) {
    int temp = index + adding;
    print("Result for $temp is ${temp -
        ((temp ~/ reviews.length) * reviews.length)}");
    temp = temp - ((temp ~/ reviews.length) * reviews.length);
    return temp;
  }

  @override
  ngOnInit() {
    print("Getting messages...");
    getMessages().then(processMessages);

    reviews = [
      new Review("Message 1", "Author 1", "https://ms-paint-i.de/"),
      new Review("Message 2", "Author 2", "https://ms-paint-i.de/"),
      new Review("Message 3", "Author 3", "https://ms-paint-i.de/"),
      new Review("Message 4", "Author 4", "https://ms-paint-i.de/"),
      new Review("Message 5", "Author 5", "https://ms-paint-i.de/"),
      new Review("Message 6", "Author 6", "https://ms-paint-i.de/"),
      new Review("Message 7", "Author 7", "https://ms-paint-i.de/"),
      new Review("Message 8", "Author 8", "https://ms-paint-i.de/"),
      new Review("Message 9", "Author 9", "https://ms-paint-i.de/"),
      new Review("Message 10", "Author 10", "https://ms-paint-i.de/")
    ];

    reviews = reviews.reversed.toList();

//    var first = reviews[getNext(4)];
    var second = reviews[getNext(3)];
    var third = reviews[getNext(2)];
    var fourth = reviews[getNext()];

//    activeReviews.add(first);
    activeReviews.add(second);
    activeReviews.add(third);
    activeReviews.add(fourth);

    void updateStuff() {
      new Future.delayed(const Duration(seconds: 2), () {
        void noDelay() {
          if (document.querySelector(".review-card:hover") ==
              null) {
            updateActiveReviews();
            updateStuff();
          } else {
            new Future.delayed(const Duration(milliseconds: 250), noDelay);
          }
        }

        noDelay();
      });
    }

    updateStuff();

    for (var review in reviews) {
      print(review);
    }
  }
}
