import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'http_client.dart';

final logger = Logger();

/// User model for admin management
class AdminUser {
  final String id;
  final String email;
  final String? name;
  final bool isAdmin;
  final bool isLegacyFirebaseUser;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int orderCount;

  AdminUser({
    required this.id,
    required this.email,
    this.name,
    required this.isAdmin,
    required this.isLegacyFirebaseUser,
    required this.createdAt,
    required this.updatedAt,
    required this.orderCount,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isLegacyFirebaseUser: json['isLegacyFirebaseUser'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orderCount: json['_count']?['orders'] as int? ?? 0,
    );
  }

  String get roleDisplay => isAdmin ? 'Admin' : 'Customer';
}

/// Detailed user with statistics
class UserDetail extends AdminUser {
  final List<UserOrder> orders;
  final UserStats stats;

  UserDetail({
    required super.id,
    required super.email,
    super.name,
    required super.isAdmin,
    required super.isLegacyFirebaseUser,
    required super.createdAt,
    required super.updatedAt,
    required super.orderCount,
    required this.orders,
    required this.stats,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    final baseUser = AdminUser.fromJson(json);
    return UserDetail(
      id: baseUser.id,
      email: baseUser.email,
      name: baseUser.name,
      isAdmin: baseUser.isAdmin,
      isLegacyFirebaseUser: baseUser.isLegacyFirebaseUser,
      createdAt: baseUser.createdAt,
      updatedAt: baseUser.updatedAt,
      orderCount: baseUser.orderCount,
      orders: (json['orders'] as List<dynamic>?)
              ?.map((o) => UserOrder.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// User order summary
class UserOrder {
  final String id;
  final double total;
  final String status;
  final DateTime createdAt;
  final int itemCount;

  UserOrder({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.itemCount,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      itemCount: (json['items'] as List<dynamic>?)?.length ?? 0,
    );
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

/// User statistics
class UserStats {
  final int totalOrders;
  final double totalSpent;
  final int chatSessions;

  UserStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.chatSessions,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      chatSessions: json['chatSessions'] as int? ?? 0,
    );
  }
}

/// Paginated users response
class PaginatedUsers {
  final List<AdminUser> data;
  final Pagination pagination;

  PaginatedUsers({
    required this.data,
    required this.pagination,
  });

  factory PaginatedUsers.fromJson(Map<String, dynamic> json) {
    return PaginatedUsers(
      data: (json['data'] as List<dynamic>)
          .map((item) => AdminUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      pages: json['pages'] as int,
    );
  }
}

/// User query parameters
class UserQueryParams {
  final int page;
  final int limit;
  final String? search;
  final String? role; // 'admin' or 'customer'

  UserQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.role,
  });

  UserQueryParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? role,
  }) {
    return UserQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      role: role ?? this.role,
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search!.isNotEmpty) {
      params['search'] = search!;
    }
    if (role != null && role!.isNotEmpty) {
      params['role'] = role!;
    }
    return params;
  }
}

/// Custom exception for user-related errors
class UserException implements Exception {
  final String message;

  UserException(this.message);

  @override
  String toString() => message;
}

/// User management service
class UserService {
  final HttpClient _httpClient;

  UserService(this._httpClient);

  /// Get paginated list of users
  Future<PaginatedUsers> getUsers(UserQueryParams params) async {
    try {
      logger.d('[UserService] Fetching users: ${params.toQueryParams()}');
      
      final queryString = params.toQueryParams().entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await _httpClient.get('/admin/users?$queryString');

      if (response.data['success'] == true) {
        return PaginatedUsers.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw UserException(response.data['error'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      logger.e('[UserService] Error fetching users: $e');
      if (e is UserException) rethrow;
      throw UserException('Failed to fetch users: ${e.toString()}');
    }
  }

  /// Get detailed user information
  Future<UserDetail> getUserDetail(String userId) async {
    try {
      logger.d('[UserService] Fetching user detail: $userId');
      final response = await _httpClient.get('/admin/users/$userId');

      if (response.data['success'] == true) {
        return UserDetail.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw UserException(response.data['error'] ?? 'Failed to fetch user details');
      }
    } catch (e) {
      logger.e('[UserService] Error fetching user detail: $e');
      if (e is UserException) rethrow;
      throw UserException('Failed to fetch user details: ${e.toString()}');
    }
  }

  /// Update user information
  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
    bool? isAdmin,
  }) async {
    try {
      logger.d('[UserService] Updating user: $userId');
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (isAdmin != null) data['isAdmin'] = isAdmin;

      final response = await _httpClient.put(
        '/admin/users/$userId',
        data: data,
      );

      if (response.data['success'] == true) {
        return AdminUser.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw UserException(response.data['error'] ?? 'Failed to update user');
      }
    } catch (e) {
      logger.e('[UserService] Error updating user: $e');
      if (e is UserException) rethrow;
      throw UserException('Failed to update user: ${e.toString()}');
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    try {
      logger.d('[UserService] Deleting user: $userId');
      final response = await _httpClient.delete('/admin/users/$userId');

      if (response.data['success'] != true) {
        throw UserException(response.data['error'] ?? 'Failed to delete user');
      }
    } catch (e) {
      logger.e('[UserService] Error deleting user: $e');
      if (e is UserException) rethrow;
      throw UserException('Failed to delete user: ${e.toString()}');
    }
  }
}

/// Provider for UserService
final userServiceProvider = Provider<UserService>((ref) {
  final httpClient = HttpClient();
  return UserService(httpClient);
});

/// Provider for fetching users list
final usersProvider = FutureProvider.family<PaginatedUsers, UserQueryParams>(
  (ref, params) async {
    final userService = ref.watch(userServiceProvider);
    return userService.getUsers(params);
  },
);

/// Provider for fetching user detail
final userDetailProvider = FutureProvider.family<UserDetail, String>(
  (ref, userId) async {
    final userService = ref.watch(userServiceProvider);
    return userService.getUserDetail(userId);
  },
);
