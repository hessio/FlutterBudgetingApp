import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 90, // set maximum height for the button
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double buttonWidth = constraints.maxWidth;
              double buttonHeight = constraints.maxHeight;
              double buttonTextSize = (buttonWidth + buttonHeight) * 0.055; // adjust this value as needed
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.028,
                  horizontal: MediaQuery.of(context).size.height * 0.055,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}