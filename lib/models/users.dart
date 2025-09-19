class Users {
  int userId;
  String name;
  String password;
  String email;
  String avatar;
  double buyerCredit;
  double sellerCredit;
  List<int> itemSold;
  List<int> itemBought;

  Users({
    required this.userId,
    required this.name, 
    required this.password, 
    required this.email, 
    required this.avatar, 
    required this.buyerCredit, 
    required this.sellerCredit, 
    required this.itemSold, 
    required this.itemBought
  });

  Users.fromJson(Map<String, Object?> json) 
      : this(
        userId: json['userId'] as int,
        name: json['name'] as String, 
        password: json['password'] as String, 
        email: json['email'] as String, 
        avatar: json['avatar'] as String, 
        buyerCredit: json['buyerCredit'] as double, 
        sellerCredit: json['sellerCredit'] as double, 
        itemSold: json['itemSold'] as List<int>, 
        itemBought: json['itemBought'] as List<int>
      );
  
  Users copyWith({
    int? userId,
    String? name,
    String? password,
    String? email,
    String? avatar,
    double? buyerCredit,
    double? sellerCredit,
    List<int>? itemSold,
    List<int>? itemBought,
  }) {
    return Users(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      password: password ?? this.password,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      buyerCredit: buyerCredit ?? this.buyerCredit,
      sellerCredit: sellerCredit ?? this.sellerCredit,
      itemSold: itemSold ?? this.itemSold,
      itemBought: itemBought ?? this.itemBought,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'userId': userId,
      'name': name,
      'password': password,
      'email': email,
      'avatar': avatar,
      'buyerCredit': buyerCredit,
      'sellerCredit': sellerCredit,
      'itemSold': itemSold,
      'itemBought': itemBought,
    };
  }
}