import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class imageview extends StatefulWidget {
  List<dynamic> images;
  imageview({super.key, required this.images});

  @override
  State<imageview> createState() => _imageviewState(images);
}

class _imageviewState extends State<imageview> {
  List<dynamic> images;
  _imageviewState(this.images);

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        title: Text(
          'Images',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: images.isNotEmpty
          ? Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.easeIn,
                    pauseAutoPlayOnTouch: true,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    viewportFraction: 1,
                    aspectRatio: 2.0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                  items: images.map((images) {
                    return Builder(
                      builder: (BuildContext context) {
                        return PhotoView(
                          imageProvider: NetworkImage(images['url']!),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                          backgroundDecoration: BoxDecoration(
                            color: Colors.white,
                          ),
                        );
                      },
                    );
                  }).toList(),
                )),
                SizedBox(
                  height: 10,
                ),
                buildIndicator(),
              ],
            )
          : Text('No images'),
    );
  }

  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: _currentPage,
      count: images.length,
      effect: ExpandingDotsEffect(
        activeDotColor: Colors.blue.shade900,
        dotColor: Colors.grey,
        dotHeight: 8,
        dotWidth: 7,
        spacing: 2,
        expansionFactor: 2,
      ),
    );
  }
}
