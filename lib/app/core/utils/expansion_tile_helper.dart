import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExpandableText extends StatefulWidget {
  final String text;

  const ExpandableText({super.key, required this.text});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool expanded = false;
  bool isOverflow = false;

  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOverflow();
    });
  }

  void _checkOverflow() {
    final context = _textKey.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final maxWidth = renderBox.constraints.maxWidth;

    final span = TextSpan(
      text: widget.text,
      style: TextStyle(
        fontSize: 13.sp,
        fontFamily: "BalooBhai2",
      ),
    );

    final tp = TextPainter(
      text: span,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    tp.layout(maxWidth: maxWidth);

    if (mounted) {
      setState(() {
        isOverflow = tp.didExceedMaxLines;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          key: _textKey,
          maxLines: expanded ? null : 2,
          overflow:
              expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: "BalooBhai2",
          ),
        ),

        /// 👉 Show button only if text exceeds 2 lines
        if (isOverflow)
          GestureDetector(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                expanded ? "...less" : "...more",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}