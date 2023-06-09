import 'package:flutter/material.dart';
import 'package:flutter_animator/animation/animation_preferences.dart';
import 'package:flutter_animator/animation/animator_play_states.dart';
import 'package:flutter_animator/widgets/animator_widget.dart';
import 'package:flutter_animator/widgets/attention_seekers/heart_beat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimatedHeart extends StatefulWidget {
  const AnimatedHeart({
    Key? key,
    required this.onPressed,
    required this.isServerConnected,
    required this.isCompassConnected,

  }) : super(key: key);
  final Function onPressed;
  final bool isServerConnected;
  final bool isCompassConnected;

  @override
  State<AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<AnimatedHeart> {

  String heartImage = 'assets/heart/heart-crossed.png';
  final GlobalKey<AnimatorWidgetState> _key = GlobalKey<AnimatorWidgetState>();
  bool heartClicked = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return  GestureDetector(
      onTap: () {
        toggleHeart();
      },
      child: SizedBox.fromSize(
        size: Size.square(width*0.20),
        child: HeartBeat(
          key: _key,
          preferences: const AnimationPreferences(
            autoPlay: AnimationPlayStates.None,
            duration: Duration(milliseconds: 1800),
            offset: Duration(milliseconds: 0),
            magnitude: 0.5,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Image.asset(
              heartImage,
              width: width*0.20,
              color: Theme.of(context).primaryColor,
              key: ValueKey<String>(heartImage),
            ),
          ),
        ),
      ),
    );
  }

  void toggleHeart() async {
    var prefs = await SharedPreferences.getInstance();
    var partnerId = prefs.getString('partner_id')??'';
    if (!widget.isServerConnected || (widget.isCompassConnected && partnerId.length!=6)) {
      var text = !widget.isServerConnected
          ? "server is not connected"
          : "partner isn't specified";
      ScaffoldMessenger.of(context)
          .showSnackBar(
          SnackBar(
            content: Text("Can't share location, $text"),
            duration: Duration(seconds: 2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            backgroundColor: Color.fromARGB(255, 187, 84, 84),
          ));
    }
    else {
      widget.onPressed();
      if (heartClicked) {
        _key.currentState?.reset();
      } else {
        _key.currentState?.loop();
      }
      setState(()
      {
        heartClicked = !heartClicked;
        heartImage = !heartClicked
            ?'assets/heart/heart-crossed.png'
            :'assets/heart/heart.png';
      });
    }
  }
}
