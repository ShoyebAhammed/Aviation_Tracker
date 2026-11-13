import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/flight_model.dart';
import '../models/pagination_model.dart';

class ApiResponse<T> {
  final T data;
  final PaginationModel pagination;

  ApiResponse({required this.data, required this.pagination});
}

class AviationApiException implements Exception {
  final String message;
  final String? code;

  AviationApiException(this.message, {this.code});

  @override
  String toString() => message;
}

class FlightRemoteDataSource {
  final http.Client client;

  FlightRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

  /// Fetch flights from Aviationstack API
  Future<ApiResponse<List<FlightModel>>> getFlights({
    required String apiKey,
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
    String? flightStatus,
    String? searchQuery,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw AviationApiException('Aviationstack API Key is required for live API calls.', code: 'missing_key');
    }

    final queryParams = <String, String>{
      'access_key': apiKey.trim(),
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (flightStatus != null && flightStatus.isNotEmpty && flightStatus != 'all') {
      queryParams['flight_status'] = flightStatus.toLowerCase();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim();
      // Aviationstack allows searching by flight_iata or airline_name
      if (RegExp(r'^[A-Za-z0-9]{2,8}$').hasMatch(query)) {
        queryParams['flight_iata'] = query.toUpperCase();
      } else {
        queryParams['airline_name'] = query;
      }
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.flightsEndpoint}').replace(queryParameters: queryParams);

    try {
      final response = await client.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        // Check if Aviationstack returned an API error inside 200 OK
        if (decoded.containsKey('error')) {
          final errorObj = decoded['error'] as Map<String, dynamic>;
          final code = errorObj['code']?.toString() ?? 'api_error';
          final message = errorObj['message']?.toString() ??
              errorObj['info']?.toString() ??
              'Aviationstack API error occurred.';
          throw AviationApiException(message, code: code);
        }

        final dataList = (decoded['data'] as List<dynamic>? ?? [])
            .map((item) => FlightModel.fromJson(item as Map<String, dynamic>))
            .toList();

        final pagination = decoded['pagination'] != null
            ? PaginationModel.fromJson(decoded['pagination'] as Map<String, dynamic>)
            : PaginationModel(limit: limit, offset: offset, count: dataList.length, total: dataList.length);

        return ApiResponse(data: dataList, pagination: pagination);
      } else if (response.statusCode == 429) {
        throw AviationApiException(
          'Aviationstack monthly API quota reached or rate limit exceeded.',
          code: 'rate_limit',
        );
      } else {
        throw AviationApiException(
          'Server returned error code ${response.statusCode}: ${response.reasonPhrase}',
          code: 'http_${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is AviationApiException) rethrow;
      throw AviationApiException('Network connection error: $e', code: 'network_error');
    }
  }
}

