// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/utils.dart';

class FormInput extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final String? title;
  final bool? long;
  final bool? num;
  final bool? mail;
  final bool? pass;
  final bool? edit;
  final bool? disabled;

  const FormInput({
    super.key,
    required this.textEditingController,
    required this.label,
    this.title,
    this.long,
    this.num,
    this.mail,
    this.pass,
    this.edit,
    this.disabled,
  });

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.screenHeight * kSpacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text(
                widget.title!,
                style: SafeGoogleFont(
                  'Ubuntu',
                  fontSize: context.screenWidth * kFontS,
                  fontWeight: FontWeight.w400,
                  color: kBlackColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          TextFormField(
            minLines: widget.long == true ? 3 : 1,
            maxLines: widget.long == true ? 10 : 1,
            enabled: widget.disabled == true ? false : true,
            textAlign: TextAlign.start,
            obscureText: widget.pass == true ? _isObscure : false,
            keyboardType: widget.num == true
                ? TextInputType.number
                : widget.mail == true
                ? TextInputType.emailAddress
                : TextInputType.text,
            cursorColor: kBlackColor,
            controller: widget.textEditingController,
            inputFormatters: [
              widget.long == true
                  ? LengthLimitingTextInputFormatter(150)
                  : LengthLimitingTextInputFormatter(50),
            ],
            style: SafeGoogleFont(
              'Ubuntu',
              fontSize: context.screenWidth * kFontS,
              fontWeight: FontWeight.w500,
              color: kBlackColor,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: context.screenHeight * kSpacingM,
                horizontal: context.screenWidth * kSpacingM,
              ),
              label: Text(
                widget.label,
                style: SafeGoogleFont(
                  'Ubuntu',
                  fontSize: context.screenWidth * kFontS,
                  fontWeight: FontWeight.w500,
                  color: kBlackColor.withOpacity(0.3),
                  decoration: TextDecoration.none,
                ),
              ),
              filled: true,
              fillColor: Colors.transparent,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: kBlackColor.withOpacity(0.1),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: kBlackColor.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: kBlackColor.withOpacity(0.1),
                  width: 1.2,
                ),
              ),
              suffixIcon: widget.pass == true
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: _isObscure
                          ? const Icon(Icons.visibility_off, color: kBlackColor)
                          : const Icon(Icons.visibility, color: kBlackColor),
                    )
                  : widget.edit == true
                  ? Icon(Icons.edit)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
