import 'dart:math';

import 'package:flutter/material.dart';

class VerticalFlipPageTurn extends StatefulWidget {
  VerticalFlipPageTurn({
    Key? key,
    required this.children,
    required this.controller,
    required this.cellSize,
  }) : super(key: key);

  final List<Widget> children;

  final Size cellSize;

  final VerticalFlipPageTurnController controller;

  @override
  VerticalFlipPageTurnState createState() => VerticalFlipPageTurnState();
}

class VerticalFlipPageTurnState extends State<VerticalFlipPageTurn>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  int position = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);
    _animation = _animationController
        .drive(Tween(begin: 0.0, end: widget.children.length - 1));

    widget.controller._toTopCallback = (duration) {
      if (position > 0) {
        position = position - 1;
        _animationController.animateTo(position / (widget.children.length - 1),
            duration: duration);
      }
    };

    widget.controller.updatePageCallback = (int page) {
      setState(() {
        position = page;
        _animationController.value = position / (widget.children.length - 1);
      });
    };

    // Add this line to set the initial position
    position = widget.controller.currentPage;

    widget.controller._toBottomCallback = (duration) {
      if (position < widget.children.length - 1) {
        position = position + 1;
        _animationController.animateTo(position / (widget.children.length - 1),
            duration: duration);
      }
    };

    widget.controller.updatePositionCallback = (percentage) {
      if (percentage >= -1 && percentage <= 1) {
        _animationController.value =
            position / (widget.children.length - 1) + percentage;
      }
    };
  }

  @override
  void didUpdateWidget(covariant VerticalFlipPageTurn oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animation = _animationController
        .drive(Tween(begin: 0.0, end: widget.children.length - 1));
    if (this.position > widget.children.length - 1) {
      this.position = widget.children.length - 1;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = (_animation.value - _animation.value ~/ 1) * pi;
        final maskOpacity = _animation.value - _animation.value ~/ 1;
        final cellWidth = widget.cellSize.width;
        final cellHeight = widget.cellSize.height;

        return Container(
          width: cellWidth,
          height: cellHeight,
          child: Stack(
            children: <Widget>[
              //geçiş yaptığındaki üst kısım
              Offstage(
                offstage: !(angle >= pi / 2),
                child: Container(
                  width: cellWidth,
                  height: cellHeight,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipRect(
                      child: Align(
                        heightFactor: 0.5,
                        alignment: Alignment.topCenter,
                        child: getTopWidget(),
                      ),
                    ),
                  ),
                ),
              ),
              //alt kısım
              Offstage(
                offstage: angle == 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: cellWidth,
                    height: cellHeight / 2,
                    child: OverflowBox(
                      minHeight: cellHeight / 2,
                      maxHeight: cellHeight,
                      child: ClipRect(
                        child: Align(
                          heightFactor: 0.5,
                          alignment: Alignment.bottomCenter,
                          child: getBottomWidget(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //ğüs
              Offstage(
                offstage: !(angle >= pi / 2),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0001)
                    ..rotateX(angle),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(pi),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: cellWidth,
                        height: cellHeight / 2,
                        child: OverflowBox(
                          minHeight: cellHeight / 2,
                          maxHeight: cellHeight,
                          child: ClipRect(
                            child: Align(
                              heightFactor: 0.5,
                              alignment: Alignment.topCenter,
                              child: Stack(
                                children: [
                                  getBottomWidget() ?? SizedBox(),
                                  if (getBottomWidget() != null)
                                    Offstage(
                                      offstage: 1 - maskOpacity == 0,
                                      child: Container(
                                        color: Colors.black12
                                            .withOpacity(1 - maskOpacity),
                                        constraints: BoxConstraints.expand(),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: angle >= pi / 2,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0001)
                    ..rotateX(angle),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: angle >= pi / 2 ? 0.0 : cellWidth,
                      height: angle >= pi / 2 ? 0.0 : cellHeight / 2,
                      child: OverflowBox(
                        minHeight: cellHeight / 2,
                        maxHeight: cellHeight,
                        child: ClipRect(
                          child: Align(
                            heightFactor: 0.5,
                            alignment: Alignment.bottomCenter,
                            child: Stack(
                              children: [
                                getTopWidget(),
                                Offstage(
                                  offstage: maskOpacity == 0,
                                  child: Container(
                                    color:
                                        Colors.black12.withOpacity(maskOpacity),
                                    constraints: BoxConstraints.expand(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: angle >= pi / 2,
                child: Container(
                  width: cellWidth,
                  height: cellHeight,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ClipRect(
                      child: Align(
                        heightFactor: 0.5,
                        alignment: Alignment.topCenter,
                        child: getTopWidget(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getTopWidget() {
    return widget.children[_animation.value.toInt()];
  }

  Widget? getBottomWidget() {
    if (_animation.value.toInt() < widget.children.length - 1) {
      return widget.children[_animation.value.toInt() + 1];
    } else {
      return null;
    }
  }
}

class VerticalFlipPageTurnController {
  ValueChanged<Duration>? _toTopCallback;
  ValueChanged<Duration>? _toBottomCallback;
  void Function(double)? _updatePositionCallback;

  void Function(int)? _updatePageCallback;
  void Function(int)? get updatePageCallback => _updatePageCallback;
  int currentPage = 0;

  void animToTopWidget(
      {Duration duration = const Duration(milliseconds: 1000)}) {
    if (_toTopCallback != null) {
      _toTopCallback!(duration);
    }
  }

  void animToBottomWidget(
      {Duration duration = const Duration(milliseconds: 1000)}) {
    if (_toBottomCallback != null) {
      _toBottomCallback!(duration);
    }
  }

  void updatePosition(double percentage) {
    if (_updatePositionCallback != null) {
      _updatePositionCallback!(-percentage);
    }
  }

  set updatePageCallback(void Function(int)? callback) {
    _updatePageCallback = callback;
  }

  set updatePositionCallback(void Function(double)? callback) {
    _updatePositionCallback = callback;
  }
}
