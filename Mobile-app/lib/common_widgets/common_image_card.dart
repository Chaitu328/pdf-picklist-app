import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:inventory/common_widgets/show_more_text.dart';
import '../app/routes/app_routes.dart';

class CommonImageCard extends StatefulWidget {
  final String imageUrl;
  final String text;
  final String description;

  // Constructor to accept
  const CommonImageCard({
    Key? key,
    required this.imageUrl,
    required this.text,
    required this.description,
  }) : super(key: key);

  @override
  State<CommonImageCard> createState() => _CommonImageCardState();
}

class _CommonImageCardState extends State<CommonImageCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.expandInfo,arguments: [widget.imageUrl,widget.text,widget.description]);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Text
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 5,
            ),
            // Card with Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              height: 200,
              width: double.maxFinite,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Apply the same border radius to the image
                child: Image.asset(
                  widget.imageUrl,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // Show More Text Widget
            ShowMoreTextWidget(text: widget.description),
          ],
        ),
      ),
    );
  }
}
