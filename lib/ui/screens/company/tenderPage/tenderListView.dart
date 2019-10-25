import 'package:flutter/material.dart';
import 'package:flutter_my_chat/constants/const.dart';
import 'package:flutter_my_chat/models/tender.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../chat_company.dart';

class TendersListView extends StatelessWidget {
  final VoidCallback callback;
  final Tender tender;
  final AnimationController animationController;
  final Animation animation;
  final String userId;
  final String userName;

  const TendersListView(
      {Key key,
      this.tender,
      this.animationController,
      this.animation,
      this.callback,
      this.userId,
      this.userName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 50 * (1.0 - animation.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () {
                  callback();
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.6),
                          offset: Offset(4, 4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      // When the child is tapped, show a snackbar.
                      onTap: () {
                        if (DateTime.now().isAfter(DateTime.parse(
                            tender.dueDate + ' ' + tender.dueTime + ':00'))) {
                          final snackBar = SnackBar(
                              content: Text(
                                  "Pleasenote that this bid has closed, you can nolonger bid on this tender, wait for other ones"));
                          Scaffold.of(context).showSnackBar(snackBar);
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatCompany(
                                        peerId: tender.id,
                                        tender: tender,
                                        userId: userId,
                                        userName: userName,
                                      )));
                        }
                      },
                      // The custom button
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                        child: Stack(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Row(),
                                AspectRatio(
                                  aspectRatio: 2,
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/loading.gif',
                                    image: tender.imageUrl,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16, top: 8, bottom: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  tender.title,
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      tender.description +
                                                          '\nCategory: ' +
                                                          tender.category +
                                                          '\nDue Date: ' +
                                                          tender.dueDate +
                                                          '  ' +
                                                          tender.dueTime,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.8)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Row(
                                                    children: <Widget>[
                                                      SmoothStarRating(
                                                          allowHalfRating: true,
                                                          starCount: 5,
                                                          rating: 7,
                                                          size: 20,
                                                          color: meroonColor,
                                                          borderColor:
                                                              meroonColor),
                                                      Text(
                                                        " 3 Reviews",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.8)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(32.0),
                                  ),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.favorite_border,
                                      color: meroonColor,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            ),
          ),
        );
      },
    );
  }
}
