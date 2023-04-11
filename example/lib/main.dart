import 'package:better_page_turn/vertical_flip_page_turn.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Vertical Flip PageView')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final VerticalFlipPageTurnController _pageTurnController =
      VerticalFlipPageTurnController();
  double? _initialVerticalDrag;
  double? _currentVerticalDrag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _initialVerticalDrag = details.localPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        _currentVerticalDrag = details.localPosition.dy;
        double dragDistance = _currentVerticalDrag! - _initialVerticalDrag!;
        double dragPercentage =
            dragDistance / MediaQuery.of(context).size.height;
        _pageTurnController.updatePosition(dragPercentage);
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _pageTurnController.animToTopWidget();
        } else {
          _pageTurnController.animToBottomWidget();
        }
      },
      child: VerticalFlipPageTurn(
        children: [
          Container(color: Colors.red, child: Center(child: Text('1'))),
          Container(color: Colors.green, child: Center(child: Text('2'))),
          Container(color: Colors.blue, child: Center(child: Text('3'))),
        ],
        cellSize: MediaQuery.of(context).size,
        controller: _pageTurnController,
      ),
    );
  }
}
