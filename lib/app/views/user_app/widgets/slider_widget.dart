
import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              width: 250,
              child: Image.network(
                'https://via.placeholder.com/250x150',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
