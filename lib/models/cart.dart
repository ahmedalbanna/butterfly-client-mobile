import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class CartItem with _$CartItem {
  const CartItem._();
  
  const factory CartItem({
    required String id,
    required String productId,
    required int quantity,
    required Product product,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  double get subtotal => product.price * quantity;
}

@freezed
class Cart with _$Cart {
  const Cart._();
  
  const factory Cart({
    String? id,
    required String userId,
    @Default([]) List<CartItem> items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

@freezed
class CartResponse with _$CartResponse {
  const factory CartResponse({
    required bool success,
    required Cart data,
  }) = _CartResponse;

  factory CartResponse.fromJson(Map<String, dynamic> json) =>
      _$CartResponseFromJson(json);
}

@freezed
class CartItemResponse with _$CartItemResponse {
  const factory CartItemResponse({
    required bool success,
    required CartItem data,
  }) = _CartItemResponse;

  factory CartItemResponse.fromJson(Map<String, dynamic> json) =>
      _$CartItemResponseFromJson(json);
}

@freezed
class AddToCartRequest with _$AddToCartRequest {
  const factory AddToCartRequest({
    required String productId,
    @Default(1) int quantity,
  }) = _AddToCartRequest;

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToCartRequestFromJson(json);
}

@freezed
class UpdateCartItemRequest with _$UpdateCartItemRequest {
  const factory UpdateCartItemRequest({
    required int quantity,
  }) = _UpdateCartItemRequest;

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCartItemRequestFromJson(json);
}
