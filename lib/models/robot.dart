// En Dart, no necesitas importar nada complejo para crear una clase básica.
// Esto es solo una plantilla de datos.

class Robot {
  final String id;      // Un identificador único (ej: "robot_1")
  final String name;    // El nombre para mostrar en pantalla
  int x;                // Su posición horizontal en la cuadrícula
  int y;                // Su posición vertical en la cuadrícula
  int hp;               // Sus puntos de vida (Health Points)
  int actionPoints;     // Cuántas acciones puede hacer por turno

  // Este es el "Constructor". Sirve para crear un robot nuevo dándole estos datos.
  // La palabra 'required' significa que es obligatorio darle ese dato al crearlo.
  Robot({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.hp = 100,          // Si no le pasamos HP, por defecto tendrá 100
    this.actionPoints = 3,  // Por defecto tendrá 3 puntos de acción
  });
}