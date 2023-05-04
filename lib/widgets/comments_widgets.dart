// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:workes_arabic/inner_screens/profile.dart';

class CommentWidget extends StatelessWidget {
  final String commentId;
  final String commentBody;
  final String commenterImageUrl;
  final String commenterName;
  final String commenterId;
  CommentWidget({
    required this.commentId,
    required this.commentBody,
    required this.commenterImageUrl,
    required this.commenterName,
    required this.commenterId,
  });

  List<Color> _colors = [
    Colors.orange,
    Colors.pink,
    Colors.amber,
    Colors.purple,
    Colors.brown,
    Colors.blue,
  ];
  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userID: commenterId,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 5,
          ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: _colors[0],
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(commenterImageUrl),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commenterName,
                    style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    commentBody,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
