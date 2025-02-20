import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

// Punto de entrada de la aplicación Flutter
void main() => runApp(MyApp());

// Widget principal de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la marca de depuración
      home: HomePage(), // Establece la página principal del juego
    );
  }
}

// Widget con estado para la página principal del juego
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista que almacena la posición de cada segmento de la serpiente en la cuadrícula
  static List<int> snakePosition = [45, 65, 85, 105, 125];

  // Número total de cuadros en la cuadrícula del juego (20x38)
  int numberOfSquares = 760;

  // Generador de números aleatorios para la posición de la comida
  static var randomNumber = Random();

  // Posición inicial de la comida en la cuadrícula
  int food = randomNumber.nextInt(700);

  // Función para generar una nueva posición de comida aleatoria
  void generateNewFood() {
    food = randomNumber.nextInt(700);
    // Asegura que la comida no aparezca en la posición de la serpiente
    while (snakePosition.contains(food)) {
      food = randomNumber.nextInt(700);
    }
  }

  // Función para iniciar el juego
  void startGame() {
    // Restablece la posición inicial de la serpiente
    snakePosition = [45, 65, 85, 105, 125];

    // Temporizador para mover la serpiente cada 100 milisegundos
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (Timer timer) {
      updateSnake(); // Actualiza la posición de la serpiente
      if (gameOver()) {
        timer.cancel(); // Detiene el temporizador si el juego termina
        _showGameOverScreen(); // Muestra la pantalla de fin de juego
      }
    });
  }

  // Variable para controlar la dirección actual de la serpiente
  var direction = 'down';

  // Función para actualizar la posición de la serpiente
  void updateSnake() {
    setState(() {
      // Determina la nueva posición según la dirección actual
      switch (direction) {
        case 'down':
          // Si la serpiente alcanza el borde inferior, "teletransporta" a la parte superior
          if (snakePosition.last > 740) {
            snakePosition.add(snakePosition.last + 20 - 760);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }
          break;
        case 'up':
          // Si alcanza el borde superior, "teletransporta" a la parte inferior
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + 760);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        case 'left':
          // Si cruza el borde izquierdo, reaparece en el derecho
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        case 'right':
          // Si cruza el borde derecho, reaparece en el izquierdo
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;
        default:
      }

      // Verifica si la serpiente comió la comida
      if (snakePosition.last == food) {
        generateNewFood(); // Genera nueva comida si la serpiente la come
      } else {
        snakePosition.removeAt(0); // Elimina la última posición si no come
      }
    });
  }

  // Verifica si el juego ha terminado (colisión de la serpiente consigo misma)
  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count += 1;
        }
        if (count == 2) {
          return true; // Termina el juego si hay colisión
        }
      }
    }
    return false;
  }

  // Muestra la pantalla de "Game Over" con la cantidad de manzanas comidas
  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'), // Título del cuadro de diálogo
            content: Text(
              'You ate ${snakePosition.length - 5} apples',
              style: TextStyle(
                  color: const Color.fromARGB(255, 230, 0, 0), fontSize: 20),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Play Again',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 0, 238, 255),
                      fontSize: 20),
                ),
                onPressed: () {
                  startGame(); // Reinicia el juego
                  Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para la interfaz principal
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              // Detecta deslizamientos verticales para cambiar la dirección
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              // Detecta deslizamientos horizontales para cambiar la dirección
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: Container(
                child: GridView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // Evita el desplazamiento
                  itemCount:
                      numberOfSquares, // Total de cuadros en la cuadrícula
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 20), // 20 cuadros por fila
                  itemBuilder: (BuildContext context, int index) {
                    // Determina el color de cada celda: serpiente, comida o vacío
                    if (snakePosition.contains(index)) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: const Color.fromARGB(255, 0, 255, 26),
                            ),
                          ),
                        ),
                      );
                    }
                    if (index == food) {
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: const Color.fromARGB(255, 230, 0, 0),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.all(2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            color: Colors.grey[900], // Cuadros vacíos
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          // Barra inferior con botón para iniciar el juego y el nombre del juego
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: startGame, // Inicia el juego al presionar
                  child: Text(
                    'START GAME',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 238, 255),
                        fontSize: 20),
                  ),
                ),
                Text(
                  'SNAKE GAME', // Nombre del juego en la parte inferior
                  style: TextStyle(
                      color: const Color.fromARGB(255, 21, 0, 255),
                      fontSize: 20),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
