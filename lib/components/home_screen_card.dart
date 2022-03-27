import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreenCard extends StatefulWidget {
  final String? cardTitle, cardSubtitle, cardImage;
  final GestureTapCallback? onTap;
  const HomeScreenCard({
    Key? key,
    required this.cardTitle,
    this.cardSubtitle,
    this.cardImage,
    this.onTap,
  }) : super(key: key);

  @override
  State<HomeScreenCard> createState() => _HomeScreenCardState();
}

class _HomeScreenCardState extends State<HomeScreenCard> {
  bool _showFrontSide = true;
  bool _isAnimating = false;

  @override
  void initState() {
    _showFrontSide = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: __transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        child: _showFrontSide ? _buildFront() : _buildRear(),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
      ),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tap!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  void _switchCard() {
    if (!_isAnimating) {
      setState(() {
        _showFrontSide = !_showFrontSide;
        _isAnimating = true;
      });
    }
  }

  Widget _buildFront() {
    return _buildLayout(
      key: const ValueKey(true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Image.asset(
              widget.cardImage ?? "assets/images/logo.png",
            ),
          ),
          Text(
            widget.cardTitle!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRear() {
    return _buildLayout(
      key: const ValueKey(false),
      child: Center(
        child: Text(
          widget.cardSubtitle!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
        ),
      ),
    );
  }

  Widget _buildLayout({required Key key, required Widget child}) {
    return Stack(
      key: key,
      children: [
        Card(
          color: Colors.red,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            padding: const EdgeInsets.all(10.0),
            width: double.maxFinite,
            height: double.maxFinite,
            child: child,
          ),
        ),
        Positioned(
          child: GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
            ),
            onTap: _switchCard,
          ),
          top: 0.0,
          right: 0.0,
        )
      ],
    );
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    rotateAnim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
      }
    });
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_showFrontSide) != widget!.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }
}
