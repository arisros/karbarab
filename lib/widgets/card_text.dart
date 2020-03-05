import 'package:flutter/material.dart';
import 'package:karbarab/config/game_mode.dart';
import 'package:karbarab/widgets/typography.dart';
import 'package:karbarab/config/colors.dart';
import 'package:flutter_audio_player/flutter_audio_player.dart';

class CardText extends StatefulWidget {
  final int point;
  final String text;
  final double height;
  final bool loading;
  final CardAnswerMode answerMode;

  CardText({
    @required this.point,
    @required this.text,
    @required this.height,
    @required this.loading,
    @required this.answerMode,
  });

  @override
  _CardTextState createState() => _CardTextState();
}

class _CardTextState extends State<CardText> {

  @override
  void initState() {
    super.initState();
  }

  void _play() {
    if (!widget.loading) {
      SoundPlayerUtil.addSoundName(widget.text);
    }
  }

  @override
  void dispose() {
    super.dispose();
    SoundPlayerUtil.removeAllSound();
  }

  Widget _buildText() {
    if (widget.answerMode == CardAnswerMode.Arab) {
      return BiggerArabicText(text: widget.text ,dark: true,);
    }
    return LargerText(text: widget.text, dark: true, bold: true, );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: widget.height - 40,
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 20),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.loading
                  ? RegularText(text: 'Loading', dark: true)
                  : _buildText()
            ],
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3.0),
            decoration: BoxDecoration(
              color: redColor,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: SmallerText(
              text: widget.point.toString(),
              dark: false,
            ),
          ),
        ),
        Positioned(
          top: 20.0,
          right: 20.0,
          child: widget.answerMode == CardAnswerMode.Arab ? GestureDetector(
            onTap: _play,
            child: Icon(
              Icons.volume_up,
              color: greyColor,
              size: 40.0,
            ),
          ) : Text(''),
        )
      ],
    );
  }
}

class SoundPlayerUtil {
  static void addSoundName(String name, {int count = 1}) {
    for (var i = 0; i < count; i++) {
      AudioPlayer.addSound('lib/assets/voices/' + name);
    }
  }

  static void removeAllSound() {
    AudioPlayer.removeAllSound();
  }
}