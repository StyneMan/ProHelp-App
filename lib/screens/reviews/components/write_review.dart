import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/inputfield/textarea.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class WriteReview extends StatefulWidget {
  final PreferenceManager manager;
  var data;

  WriteReview({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<WriteReview> {
  double _rating = 0.0;
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();
  final _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 530,
      child: ListView(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  Constants.padding,
                ),
                topRight: Radius.circular(
                  Constants.padding,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextInter(
                  text:
                      "Review ${widget.data['bio']['fullname'].toString().capitalize?.split(' ')[0]}",
                  fontSize: 16,
                  color: Colors.white,
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
          Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              children: [
                const TextInter(
                  text:
                      "Please note that your profile will be visible to the public to enable others make informed decisions.",
                  fontSize: 15,
                  align: TextAlign.center,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RatingBar.builder(
                      minRating: 1,
                      initialRating: _rating,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: _controller.isLoading.value,
                      itemCount: 5,
                      itemSize: 36,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        size: 18,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        debugPrint("$rating");
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    TextPoppins(
                      text: "$_rating",
                      fontSize: 18,
                      color:
                          _rating == 0.0 ? Colors.red : Constants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                CustomTextArea(
                  hintText: "Write Message",
                  autoFocus: true,
                  onChanged: (val) {},
                  maxLength: 150,
                  maxLines: 10,
                  isEnabled: !_controller.isLoading.value,
                  controller: _reviewController,
                  validator: (val) {
                    if (val == null || val.toString().isEmpty) {
                      return "Review message is required";
                    }
                    return null;
                  },
                  inputType: TextInputType.text,
                  capitalization: TextCapitalization.sentences,
                ),
                const SizedBox(
                  height: 24,
                ),
                CustomButton(
                  bgColor: _controller.isLoading.value
                      ? Colors.grey.shade400
                      : Constants.primaryColor,
                  child: TextPoppins(
                    text: "Submit review",
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  borderColor: Colors.transparent,
                  foreColor: Colors.white,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() &&
                              _rating > 0.0) {
                            Get.back();
                            _createReview();
                          } else {
                            Constants.toast(
                              "Rating and comment are both required",
                            );
                          }
                        },
                  variant: "Filled",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _createReview() async {
    _controller.setLoading(true);
    Map _payload = {
      "rating": "$_rating".contains(".") ? _rating : _rating.toDouble(),
      "comment": _reviewController.text,
      "userId": widget.data['id'],
      "reviewer": {
        "id": widget.manager.getUser()['id'],
        "name": widget.manager.getUser()['bio']['fullname'],
        "photo": widget.manager.getUser()['bio']['image'],
        "email": widget.manager.getUser()['email'],
      }
    };

    try {
      final resp = await APIService().postReview(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          payload: _payload);
      _controller.setLoading(false);

      debugPrint("REVIEW RESPONSE >> ${resp.body}");
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}
