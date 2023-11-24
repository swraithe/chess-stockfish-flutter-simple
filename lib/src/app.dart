import 'package:flutter/material.dart';
import 'package:stockfish/stockfish.dart';

// import 'src/output_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<MyApp> {
  late Stockfish stockfish;
  late String bestmove = '';
  ValueNotifier<String> bestmoveNotifier = ValueNotifier<String>('');
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    stockfish = Stockfish();
    _controller.text = 'position startpos moves e2e4';
    stockfish.stdout.listen((line) {
      // do something useful
      print(line);
      if (line.startsWith('bestmove')) {
        // Extract the best move and save it to the bestmove variable
        bestmove = line.split(' ')[1]; // Assuming the format is "bestmove e7e5 ponder g1f3"
        bestmoveNotifier.value = bestmove;
        print("The best move calculated by Stockfish is: $bestmove");
        _controller.text += ' ' + bestmove;
      } else {
        bestmove = line; // Assuming the format is "bestmove e7e5 ponder g1f3"
        bestmoveNotifier.value = bestmove;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stockfish UCI Command app'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: stockfish.state,
                builder: (_, __) => Text(
                  'stockfish.state=${stockfish.state.value}',
                  key: const ValueKey('stockfish.state'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedBuilder(
                animation: stockfish.state,
                builder: (_, __) => ElevatedButton(
                  onPressed: stockfish.state.value == StockfishState.disposed
                      ? () {
                          final newInstance = Stockfish();
                          setState(() => stockfish = newInstance);
                        }
                      : null,
                  child: const Text('Reset Stockfish instance'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Custom UCI command',
                  hintText: 'go infinite',
                ),
                onSubmitted: (value) => stockfish.stdin = value,
                textInputAction: TextInputAction.send,
              ),
            ),
            Wrap(
              children: [
                'd',
                'uci',
                'isready',
                'ucinewgame',
                'position startpos',
                'position startpos moves e2e4 e7e5',
                'setoption name Skill Level value 0',
                'go infinite',
                'setoption name Skill Level value 20',
                'go depth 10 movetime 3000',
                'go',
                'go depth 15 movetime 4000',
                'stop',
                'go movetime 3000',
                'quit',
                'ponderhit',
              ]
                  .map(
                    (command) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          stockfish.stdin = command;
                          print('press button $command');
                        },
                        child: Text(command),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder(
                valueListenable: bestmoveNotifier,
                builder:
                    (BuildContext context, String bestmove, Widget? child) {
                  return Text(
                    'stockfish.output=$bestmove',
                    key: const ValueKey('stockfish.bestmove'),
                  );
                },
              ),
            )
            // Expanded(
            //   child: OutputWidget(stockfish.stdout),
            // ),
          ],
        ),
      ),
    );
  }
}
