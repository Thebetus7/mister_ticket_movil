class ProductModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int stock;

  ProductModel({
    required this.id, 
    required this.nombre, 
    required this.descripcion, 
    required this.precio,
    required this.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'] ?? '',
      precio: double.parse(json['precio'].toString()),
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'stock': stock,
    };
  }
}
