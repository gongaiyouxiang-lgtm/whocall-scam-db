import 'package:flutter/material.dart';
import 'game/game_state.dart';
import 'widgets/game_board.dart';
import 'widgets/score_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App2048());
}

class App2048 extends StatelessWidget {
  const App2048({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: '2048',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8F7A66)),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _game = GameState();

  @override
  void initState() {
    super.initState();
    _game.load();
  }

  @override
  void dispose() {
    _game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFAF8EF),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScoreBar(game: _game),
                    const SizedBox(height: 12),
                    GameBoard(game: _game),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
