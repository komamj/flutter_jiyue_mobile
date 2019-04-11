class User {
  final String id;
  final String ownerId;
  final String name;
  final String logo;
  final String address;
  final bool online;

  User(
      {this.id, this.ownerId, this.name, this.logo, this.address, this.online});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        ownerId: json['ownerId'],
        name: json['name'],
        logo: json['logo'],
        address: json['address'],
        online: json['online']);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'logo': logo,
        'address': address,
        'online': online
      };
}
