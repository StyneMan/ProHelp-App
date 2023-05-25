import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/forms/education/add_edu_form.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/about.dart';

/// Inspiration taken from [modal_bottom_sheet](https://github.com/jamesblasco/modal_bottom_sheet)
class _CupertinoBottomSheetContainer extends StatelessWidget {
  /// Widget to render
  final Widget? child;
  final Color? backgroundColor;

  /// Add padding to the top of [child], this is also the height of visible
  /// content behind [child]
  ///
  /// Defaults to 10
  final double topPadding;
  const _CupertinoBottomSheetContainer(
      {Key? key, this.child, this.backgroundColor, this.topPadding = 10})
      : assert(topPadding != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSafeAreaPadding = MediaQuery.of(context).padding.top;
    final topPadding = this.topPadding + topSafeAreaPadding;
    final radius = Radius.circular(12);
    final shadow =
        BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 5);
    final backgroundColor = this.backgroundColor ??
        CupertinoTheme.of(context).scaffoldBackgroundColor;

    final decoration =
        BoxDecoration(color: backgroundColor, boxShadow: [shadow]);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        child: Container(
          decoration: decoration,
          width: double.infinity,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true, // Remove top Safe Area
            child: child!,
          ),
        ),
      ),
    );
  }
}

/// Inspiration taken from [modal_bottom_sheet](https://github.com/jamesblasco/modal_bottom_sheet)
class CupertinoModalTransition extends StatelessWidget {
  /// Animation that [child] will use for entry or leave
  final Animation<double> animation;

  /// Animation curve to be applied to [animation]
  ///
  /// Defaults to [Curves.easeOut]
  Curve? animationCurve;

  /// Widget that will be displayed at the top
  final Widget child;

  /// Widget that will be displayed behind [child]
  ///
  /// Usually this is the route that shows this model
  final Widget behindChild;

  CupertinoModalTransition({
    Key? key,
    required this.animation,
    required this.child,
    required this.behindChild,
    this.animationCurve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var startRoundCorner = 0.0;
    final paddingTop = MediaQuery.of(context).padding.top;
    if (Theme.of(context).platform == TargetPlatform.iOS && paddingTop > 20) {
      startRoundCorner = 38.5;
      // See: https://kylebashour.com/posts/finding-the-real-iphone-x-corner-radius
    }

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: animationCurve ?? Curves.easeOut,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      /// Because the first element of the stack below is a black coloured
      /// container, this is required
      value: SystemUiOverlayStyle.light,
      child: AnimatedBuilder(
        animation: curvedAnimation,
        child: child,
        builder: (context, child) {
          final progress = curvedAnimation.value;
          final yOffset = progress * paddingTop;
          final scale = 1 - progress / 10;
          final radius = progress == 0
              ? 0.0
              : (1 - progress) * startRoundCorner + progress * 12;
          return Stack(
            children: [
              GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Container(color: Colors.black),
              ),
              GestureDetector(
                onTap: Navigator.of(context).pop,
                child: Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(radius),
                      child: behindChild,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          );
        },
      ),
    );
  }
}

class CupertinoDialogBody extends StatefulWidget {
  final String title;
  final PreferenceManager manager;
  final Widget child;
  const CupertinoDialogBody({
    Key? key,
    required this.child,
    required this.title,
    required this.manager,
  }) : super(key: key);

  @override
  _CupertinoDialogBodyState createState() => _CupertinoDialogBodyState();
}

class _CupertinoDialogBodyState extends State<CupertinoDialogBody> {
  /// Prevent further popping of navigator stack once dialog is popped
  bool isDialogPopped = false;
  final _controller = Get.find<StateController>();

  _init() {
    if (_controller.shouldExitExpEdu.value) {
      Navigator.pop(context);
    } 
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        child: DraggableScrollableSheet(
          /// Only allow to be scrolled down up to half size of the child
          minChildSize: 0.50,

          /// Show full screen by default
          initialChildSize: 1,
          builder: (context, controller) {
            if(_controller.shouldExitExpEdu.value) {
              Navigator.of(context).pop();
            }
            return _CupertinoBottomSheetContainer(
              child: NotificationListener<DraggableScrollableNotification>(
                onNotification: (DraggableScrollableNotification notification) {
                  if (!isDialogPopped &&
                      notification.extent == notification.minExtent) {
                    isDialogPopped = true;
                    Navigator.of(context).pop();
                  }
                  return false;
                },
                child: CupertinoApp(
                  debugShowCheckedModeBanner: false,
                  home: CustomScrollView(
                    controller: controller,
                    shrinkWrap: false,
                    slivers: [
                      CupertinoSliverNavigationBar(
                        backgroundColor: Colors.grey[200],
                        largeTitle: Text(
                          widget.title,
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navLargeTitleTextStyle,
                        ),
                        trailing: CupertinoButton(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Cancel',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .navActionTextStyle,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
