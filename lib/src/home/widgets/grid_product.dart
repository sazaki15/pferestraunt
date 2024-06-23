import 'package:flutter/material.dart';
import 'package:pfe2024/src/home/screens/details.dart';
import 'package:pfe2024/src/home/util/const.dart';
import 'package:pfe2024/src/home/widgets/smooth_star_rating.dart';

class GridProduct extends StatelessWidget {
  final String id;
  final String name;
  final String img; // This will now be a URL
  final bool isFav;
  final double rating;
  final int raters;
  final String cuisine;
  final String hours;
  final String phone;
  final String website;
  final String description;

  GridProduct({
    required key,
    required this.id,
    required this.name,
    required this.img,
    required this.isFav,
    required this.rating,
    required this.raters,
    required this.cuisine,
    required this.hours,
    required this.phone,
    required this.website,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ListView(
        shrinkWrap: true,
        primary: false,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 3.6,
                width: MediaQuery.of(context).size.width / 2.2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    img, // Use Image.network for URL
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.error));
                    },
                  ),
                ),
              ),
              Positioned(
                right: -10.0,
                bottom: 3.0,
                child: RawMaterialButton(
                  onPressed: () {},
                  fillColor: Colors.white,
                  shape: CircleBorder(),
                  elevation: 4.0,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 2.0, top: 8.0),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 2,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 5.0, top: 2.0),
            child: Row(
              children: <Widget>[
                SmoothStarRating(
                  starCount: 5,
                  color: Constants.ratingBG,
                  allowHalfRating: true,
                  rating: rating,
                  size: 10.0,
                  onRatingChanged: (double rating) {},
                  borderColor: Colors.black,
                ),
                Text(
                  " $rating ($raters Reviews)",
                  style: TextStyle(
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ProductDetails(
                id: id,
                cuisine: cuisine,
                name: name,
                hours: hours,
                img: img,
                isFav: isFav,
                 phone: phone,
                 raters:raters ,
                 rating: rating,
                 website: website,
                  description: description,
              );
            },
          ),
        );
      },
    );
  }
}
