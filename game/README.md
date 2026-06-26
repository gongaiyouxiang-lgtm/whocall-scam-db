# Flutter 2048

Classic 2048 tile game built with Flutter.

## Features

- 4×4 grid with smooth animations
- Swipe (mobile) and arrow-key (desktop/web) controls
- Score tracking with all-time best score
- **Save & resume** — progress is saved automatically; close and reopen to continue
- Background music support (add your own file)
- Mute/unmute toggle

## Getting Started

```bash
cd game
flutter pub get
flutter run
```

## Background Music

Drop any MP3/OGG file at `assets/music/bg_loop.mp3`, then uncomment the
`assets` section in `pubspec.yaml`. The game will loop it automatically.

## Build for Web

```bash
flutter build web
# Output is in build/web/ — deploy to GitHub Pages or any static host
```

## Project Structure

```
lib/
  main.dart                  — app entry point
  game/
    game_state.dart          — ChangeNotifier: state, save/load, music
    slide_logic.dart         — pure slide-and-merge algorithm
  widgets/
    game_board.dart          — 4×4 board, swipe & keyboard input, overlays
    game_tile.dart           — animated tile widget
    score_bar.dart           — title, scores, mute & new-game buttons
test/
  slide_logic_test.dart      — unit tests for the core algorithm
```
