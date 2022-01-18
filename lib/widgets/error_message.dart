import 'dart:math' as math;
import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({Key? key, required this.error}) : super(key: key);

  final Object error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/images/oops.jpg',
              fit: BoxFit.cover,
              height: 30,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            'ЁК МАКАРЕК',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: Image.asset(
                'assets/images/oops.jpg',
                fit: BoxFit.cover,
                height: 30,
              ),
            ),
          ),
        ],
      ),
      content: Text(
          'Опять какая-то фигня не работает. Вот причина: ${error.toString()}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
