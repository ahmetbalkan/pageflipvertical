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
  bool _visible = false;
  late int currentPage;
  late List<Widget> list;

  @override
  void initState() {
    super.initState();

    currentPage = 0;
    list = [
      Container(color: Colors.red, child: Center(child: Text('1'))),
      Container(color: Colors.green, child: Center(child: Text('2'))),
      Container(color: Colors.blue, child: Center(child: Text('3'))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        setState(() {
          _visible = true;
        });
        _initialVerticalDrag = details.localPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        if (currentPage == 0 && details.primaryDelta! > 0) {
          return;
        }
        if (currentPage == list.length - 1 && details.primaryDelta! < 0) {
          return;
        }

        // Add this condition to check if moving to next or previous page is allowed
        if ((currentPage == 0 && details.primaryDelta! > 0) ||
            (currentPage == list.length - 1 && details.primaryDelta! < 0)) {
          return;
        }

        _currentVerticalDrag = details.localPosition.dy;
        double dragDistance = _currentVerticalDrag! - _initialVerticalDrag!;
        double dragPercentage =
            (dragDistance / MediaQuery.of(context).size.height) * 0.5;
        _pageTurnController.updatePosition(dragPercentage);
      },
      onVerticalDragEnd: (details) {
        setState(() {
          _visible = false;
        });

        if (details.primaryVelocity! > 0) {
          if (currentPage > 0) {
            setState(() {
              currentPage--;
            });
            _pageTurnController.animToTopWidget();
          }
        } else {
          if (currentPage < list.length - 1) {
            setState(() {
              currentPage++;
            });
            _pageTurnController.animToBottomWidget();
          } else {
            setState(() {
              currentPage = list.length - 1;
            });
          }
        }
        if (currentPage < 0) {
        } else if (currentPage > list.length - 1) {
          currentPage = list.length - 1;
        }

        _pageTurnController.updatePageCallback!(currentPage);
        _pageTurnController.currentPage = currentPage;
        _pageTurnController.updatePageCallback!(currentPage);

        print(currentPage);
      },
      child: Stack(
        children: [
          VerticalFlipPageTurn(
            children: list,
            cellSize: MediaQuery.of(context).size,
            controller: _pageTurnController,
          ),
          Visibility(visible: !_visible, child: list[currentPage]),
        ],
      ),
    );
  }
}
