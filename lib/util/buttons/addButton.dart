import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool fontWeight;

  AddButton({
    required this.text,
    required this.onPressed,
    required this.fontWeight,
  });

  FontWeight isBold(bool fontWeight) {
    if (fontWeight) {
      return FontWeight.bold;
    } else {
      return FontWeight.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      height: 35,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
        ),
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double buttonWidth = constraints.maxWidth;
              double buttonHeight = constraints.maxHeight;
              double buttonTextSize = (buttonWidth + buttonHeight) * 0.09; // adjust this value as needed
              return Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: buttonTextSize,
                  fontWeight: isBold(fontWeight),
                  color: Colors.white,
                ),
              );
            },
          ),
        ),

    );
  }
}