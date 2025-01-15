import 'package:http/http.dart';
import 'package:pain_pay/services/api_service.dart';
import 'package:pain_pay/services/notification_service.dart';

final ApiService apiService = ApiService();
final NotificationService _notificationService = NotificationService();

Future<List<Map<String, dynamic>>> fetchWallets() async {
  try {
    final data = await apiService.get('', type: ApiEndpoint.wallet);
    print('These are your wallets: $data');

    return List<Map<String, dynamic>>.from(data['results']);
  } catch (error) {
    print('Error fetching wallets: $error');
    return [];
  }
}

Future<Map<String, dynamic>> getTransactions() async {
  try {
    final response = await apiService.get('', type: ApiEndpoint.transaction);
    print('Transactions: $response');

    return Map<String, dynamic>.from(response);
  } catch (e) {
    print('Error fetching transactions: $e');
    return {'results': []};
  }
}

// First, modify your createWallet function to return more useful information
Future<Map<String, dynamic>> createWallet({
  required String currency,
  required String wallet_type,
  required bool can_disburse,
  required String label,
}) async {
  print('tried creating an account');
  try {
    final response = await apiService.post('', type: ApiEndpoint.wallet, {
      'currency': currency,
      'wallet_type': wallet_type,
      'can_disburse': can_disburse,
      'label': label,
    });

    print('first response$response');

    if (response != null && response['status'] == 201) {
      print('second $response');
      return {
        'success': true,
        'message': 'Wallet created successfully.',
        'data': response['data']
      };
    } else if (response != null) {
      print('three $response');

      return {
        'success': false,
        'message': response['message'] ?? 'Failed to create wallet.'
      };
    } else {
      print('fourth response');
      return {'success': false, 'message': 'Error: Null response from server.'};
    }
  } catch (e) {
    print('error $e');
    return {'success': false, 'message': 'Error creating wallet: $e'};
  }
}

Future<void> intraTransfer({
  required String id,
  required String wallet_id,
  required String narrative,
  required double amount,
}) async {
  try {
    final response = await apiService.post('$id/intra_transfer/', {
      'id': id,
      'wallet_id': wallet_id,
      'narrative': narrative,
      'amount': amount,
    });
    print('Transfer response: $response');
  } catch (e) {
    print('Error performing intra-transfer: $e');
  }
}

// Y4DK2ZR

Future<Map<String, dynamic>> currencyExchange({
  required String id,
  required String currency,
  required String amount,
  required String action,
}) async {
  try {
    final response =
        await apiService.post('$id/exchange/', type: ApiEndpoint.wallet, {
      'currency': currency,
      'action': action,
      'amount': amount,
    });

    print('Exchange response: $response');
    if (response != null) {
      return response;
    }
    throw Exception('Null response from server');
  } catch (e) {
    print('Error performing currency exchange: $e');
    rethrow;
  }
}

Future fundWallet({
  required String amount,
  required String phone_number,
  required String wallet_id,
}) async {
  try {
    final response = await apiService.post(
        'mpesa-stk-push/',
        type: ApiEndpoint.payment,
        {
          'amount': amount,
          'phone_number': phone_number,
          'wallet_id': wallet_id
        });

    if (response != null) {
      return response;
    }
    throw Exception('Error processing your request');
  } catch (e) {
    print(e);
    return {'$e 1090'};
    // rethrow;
  }
}

Future<Map<String, dynamic>> checkStatus({
  required invoice_id,
}) async {
  try {
    print('checking status');
    final response = await apiService
        .post('status/', type: ApiEndpoint.payment, {'invoice_id': invoice_id});

    return response;
  } catch (e) {
    print(e);
    rethrow;
  }
}
