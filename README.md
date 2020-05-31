<h1 align="center">
  <img alt="Karbarab" src="https://raw.githubusercontent.com/arisros/karbarab/master/assets/images/character.png" width="180">
</h1>

<p align="center">An Arabic card guessing game for 🇮🇩 people, built with Flutter.</p>

<p align="center">
  <img alt="Karbarab home screen" src="https://raw.githubusercontent.com/arisros/karbarab/master/flutter_01.png" width="240">
  <img alt="Karbarab quiz screen" src="https://raw.githubusercontent.com/arisros/karbarab/master/flutter_02.png" width="240">
</p>

Karbarab is a guessing Arabic card game for 🇮🇩 people. This project is my starting point with Flutter. iOS is not published yet.

### Features 🥳🥳🥳🥳
- [x] Google sign in
- [x] Guest sign in
- [x] Sync with Google after signup
- [x] Choose a card game mode
- [x] Answer: there are 4 options and 1 is the right answer. You start with 30 points, they decrease when you choose a wrong answer, and when you get the right answer you keep what is left
- [x] Hints with AdMob rewarded video
- [x] Save score on your account
- [x] Send a card to a friend or an unknown user and let them answer the question. If they get it wrong, you get the points. Every user starts with 15 chances
- [x] Notifications when a card is sent and when a quiz is answered
- [x] Global score (watch an ad first)
- [x] AdMob for hints, global score (15 minutes), and refilling the send card limit (15 chances)

##### Next features 😎
- [ ] Quiz sentences
- [ ] Nearby

##### Todo 👻👻
- [ ] Add more quizzes
- [ ] iOS sync 😴😴
- [ ] Cleaning! 👻👻
- [ ] Request from API with Firebase Functions

### Run with flavor

```bash
flutter run --flavor development -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_stag.dart
flutter run --flavor production -t lib/main_prod.dart
```

### Release with flavor

```bash
flutter run --release --flavor development -t lib/main_dev.dart
flutter run --release --flavor staging -t lib/main_stag.dart
flutter run --release --flavor production -t lib/main_prod.dart
```

### Release app bundle with flavor 🤘

🤘 Don't forget to update the version 🤘

```bash
flutter build appbundle --release --flavor production -t lib/main_prod.dart
```

### CLI on development

Generate launcher icons:

```bash
flutter pub run flutter_launcher_icons:main
```

Watch and generate `*.g.dart` from models:

```bash
flutter pub run build_runner watch
```
