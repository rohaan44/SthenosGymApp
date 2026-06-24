import 'dart:html' as html;

class AppPrinter {
  static Future<void> printReceipt(
    Map<String, dynamic> memberData,
    double amount,
    String method,
  ) async {
    // 1. Format current date & time
    final now = DateTime.now();
    final formattedDate =
        "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}";
    int displayHour = now.hour % 12;
    if (displayHour == 0) displayHour = 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime =
        "${displayHour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period";

    // 2. Format valid-thru date
    String expiryDate = memberData['expiryDate']?.toString() ?? '';
    if (expiryDate.contains('T')) {
      expiryDate = expiryDate.split('T')[0];
    }
    if (expiryDate.contains('-')) {
      final parts = expiryDate.split('-');
      if (parts.length == 3) {
        expiryDate = "${parts[1]}/${parts[2]}/${parts[0]}";
      }
    }

    // 3. Extract membership plan name
    final planRaw = memberData['membership']?.toString() ?? 'Monthly';
    final planName = planRaw.split('-')[0].trim().toUpperCase();
    final itemLine = "MEMBERSHIP $planName";

    // 4. Handle payment details
    String paymentType = method.toUpperCase();
    String cardRow = '';
    if (paymentType.contains('CREDIT') || paymentType.contains('CARD')) {
      paymentType = 'VISA';
      cardRow = '''
        <div class="row">
          <span>CARD #</span>
          <span>****2222</span>
        </div>
      ''';
    }

    // 5. Generate HTML content matching design layout
    final htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>Sthenos Gym Receipt</title>
        <style>
          @page {
            size: 80mm auto;
            margin: 0;
          }
          @media print {
            html, body {
              margin: 0;
              padding: 0;
              height: auto;
              min-height: auto;
            }
          }
          html {
            margin: 0;
            padding: 0;
            height: auto;
          }
          body {
            font-family: 'Arial', Courier, monospace;
            width: 80mm;
            margin: 0 auto;
            padding: 3mm;
            padding-bottom: 0; /* Remove bottom padding to save paper */
            box-sizing: border-box;
            text-align: center;
            color: #000;
            font-size: 12px;
            height: auto;
          }
          .logo {
            max-width: 35mm;
            margin: 0 auto 10px auto;
            display: block;
          }
          .title {
            font-weight: bold;
            font-size: 18px;
            margin-bottom: 2px;
          }
          .subtitle {
            font-size: 13px;
            margin-bottom: 10px;
          }
          .row {
            display: flex;
            justify-content: space-between;
            margin: 4px 0;
          }
          .row-center {
            margin: 4px 0;
            text-align: center;
          }
          .divider {
            border-top: 1px dashed #000;
            margin: 10px 0;
          }
          .double-divider {
            border-top: 1px solid #000;
            margin: 10px 0;
          }
          .total {
            font-weight: bold;
            font-size: 16px;
          }
          .footer {
            margin-top: 20px;
            font-weight: bold;
          }
        </style>
      </head>
      <body>
        <img class="logo" src="assets/assets/images/receipt_logo.png" onerror="this.src='assets/images/receipt_logo.png'" alt="Gym Logo" />
        <div class="title">STHENOS GYM</div>
        <div class="subtitle">(555) 444-LIFT</div>
        
        <div class="row">
          <span>DATE: $formattedDate</span>
          <span>TIME: $formattedTime</span>
        </div>
        
        <div class="divider"></div>
        
        <div class="row-center">MEMBER: ${memberData["name"] ?? ""}</div>
        <div class="row-center">MEMBER ID: ${memberData["gymId"] ?? ""}</div>
        <div class="row-center">MEMBERSHIP: ${memberData["membership"] ?? ""}</div>
        
        <div class="divider"></div>
        
        <div class="row">
          <span>$itemLine</span>
          <span>\$${amount.toStringAsFixed(2)}</span>
        </div>
        
        <div class="double-divider"></div>
        
        <div class="row total">
          <span>TOTAL</span>
          <span>\$${amount.toStringAsFixed(2)}</span>
        </div>
        
        <div class="row">
          <span>PAYMENT</span>
          <span>$paymentType</span>
        </div>
        $cardRow
        <div class="row">
          <span>AMOUNT</span>
          <span>\$${amount.toStringAsFixed(2)}</span>
        </div>
        
        <div class="row-center" style="margin-top: 15px;">
          MEMBERSHIP VALID THRU: $expiryDate
        </div>
        
        <div class="footer">
          KEEP PUSHING YOUR LIMITS!
        </div>
        
        <script>
          window.onload = function() {
            window.print();
          }
        </script>
      </body>
      </html>
    ''';

    // 6. Create hidden iframe containing only the receipt
    final iframe = html.IFrameElement();
    iframe.style.position = 'absolute';
    iframe.style.width = '0px';
    iframe.style.height = '0px';
    iframe.style.border = 'none';
    iframe.srcdoc = htmlContent;
    html.document.body?.append(iframe);

    // 7. Remove the iframe once printing is done
    iframe.onLoad.listen((_) {
      // Remove iframe after print action has initiated
      Future.delayed(const Duration(seconds: 30), () {
        iframe.remove();
      });
    });
  }
}
