import 'package:flutter/services.dart';

class InputFormatterHelper {
  static List<TextInputFormatter> denyEmptySpace = [
    FilteringTextInputFormatter.deny(" "),
    // FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
  ];
  static TextInputFormatter onlyZeroIndex = FilteringTextInputFormatter.deny(
    " ",
  );

  static List<TextInputFormatter> allowCharactersAndSpace = [
    // FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z ]")),
    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')),
    // FilteringTextInputFormatter.deny(RegExp('(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'))
  ];

  static final RegExp hiddenEmojiRegex = RegExp(
    r'[\u{200D}\u{FE0F}]', // Zero Width Joiner and Variation Selector-16
    unicode: true,
  );
  static List<TextInputFormatter> allowCharactersNumbersAndSpace = [
    FilteringTextInputFormatter.allow(RegExp("[0-9 a-zA-Z ]")),
    FilteringTextInputFormatter.deny(
      RegExp(
        '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
      ),
    ),
  ];

  static List<TextInputFormatter> ibanOrNumberFormatter = [
    FilteringTextInputFormatter.allow(RegExp("[0-9 a-zA-Z-]")),
    FilteringTextInputFormatter.deny(
      RegExp(
        '(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
      ),
    ),
  ];

  static List<TextInputFormatter> emailFormatter = [
    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9@._-]")),
  ];

  static List<TextInputFormatter> addressFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9/\\\-, ]")),
  ];

  static List<TextInputFormatter> denySpaceAndOnlyAllowNumbers = [
    FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
    ...denyEmptySpace,
  ];

  // static List<TextInputFormatter> currencyFormatter = [
  //   CurrencyInputFormatter(
  //     thousandSeparator: ThousandSeparator.Comma,
  //   ),
  // ];

  // static List<TextInputFormatter> mobileNumberFormatter = [
  //   FourSpaceInputFormatter(),
  //   // ...denyEmptySpace,
  // ];
}

class CnicSlashFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 13) {
      digits = digits.substring(0, 13);
    }

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 5 || i == 12) {
        buffer.write('-');
      }
      buffer.write(digits[i]);
    }

    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String commaAmountFormatter(amount, {bool twoDecimal = false}) {
  if (amount == null) return "";
  if (amount.runtimeType == String) {
    amount = double.tryParse(amount.toString().replaceAll(",", ""));
  }
  // formattedAmount = amount.toString();
  String formattedAmount = "";
  if (amount == null || amount.toString().isEmpty) {
    return "";
  } else {
    formattedAmount = amount?.toStringAsFixed(2);
  }

  if (!twoDecimal && formattedAmount.endsWith('.00')) {
    formattedAmount = formattedAmount.substring(0, formattedAmount.length - 3);
  }
  formattedAmount = formattedAmount.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return formattedAmount;
}
