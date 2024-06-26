import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class SmoothStarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final Color borderColor;
  final double size;
  final bool allowHalfRating;
  final double spacing;

  SmoothStarRating(
      {this.starCount = 5,
        this.rating = 0.0,
        required this.onRatingChanged,
        required this.color,
        required this.borderColor,
        required this.size,
        this.spacing = 0.0,
        this.allowHalfRating = true}) {
    assert(this.rating != null);
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: borderColor ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else if (index > rating - (allowHalfRating ? 0.5 : 1.0) &&
        index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: size ?? 25.0,
      );
    }

    return GestureDetector(
      onTap: () {
        if (this.onRatingChanged != null) onRatingChanged(index + 1.0);
      },
      
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Material(
      color: Colors.transparent,
      child: new Wrap(
          alignment: WrapAlignment.start,
          spacing: spacing,
          children: new List.generate(
              starCount, (index) => buildStar(context, index))),
    );
  }
}