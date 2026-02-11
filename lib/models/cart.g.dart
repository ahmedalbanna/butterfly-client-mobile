// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CartItemImpl _$$CartItemImplFromJson(Map<String, dynamic> json) =>
    _$CartItemImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toInt(),
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartItemImplToJson(_$CartItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'quantity': instance.quantity,
      'product': instance.product,
    };

_$CartImpl _$$CartImplFromJson(Map<String, dynamic> json) => _$CartImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CartImplToJson(_$CartImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'items': instance.items,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$CartResponseImpl _$$CartResponseImplFromJson(Map<String, dynamic> json) =>
    _$CartResponseImpl(
      success: json['success'] as bool,
      data: Cart.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartResponseImplToJson(_$CartResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$CartItemResponseImpl _$$CartItemResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$CartItemResponseImpl(
      success: json['success'] as bool,
      data: CartItem.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CartItemResponseImplToJson(
        _$CartItemResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$AddToCartRequestImpl _$$AddToCartRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AddToCartRequestImpl(
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$AddToCartRequestImplToJson(
        _$AddToCartRequestImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
    };

_$UpdateCartItemRequestImpl _$$UpdateCartItemRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateCartItemRequestImpl(
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$$UpdateCartItemRequestImplToJson(
        _$UpdateCartItemRequestImpl instance) =>
    <String, dynamic>{
      'quantity': instance.quantity,
    };
