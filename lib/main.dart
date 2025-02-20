import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Posición de la serpiente en la tabla en forma de lista
  static List<int> snakePosition = [45, 65, 85, 105, 125];
  //Número de cuadros en la tabla del juego
  int numberOfSquares = 760;

  static var randomNumber = Random();
  //Posicion de la comida en la tabla
  int food = randomNumber.nextInt(700);

  //Funcion para generar la comida en una posicion aleatoria
  void generateNewFood() {
    food = randomNumber.nextInt(700);
    //While que asegura que la comida no aparezca en la posicion de la serpiente
    while (snakePosition.contains(food)) {
      food = randomNumber.nextInt(700);
    }
  }

  //Funcion para iniciar el juego
  void startGame() {
    //Posicion incial de la serpiente
    snakePosition = [45, 65, 85, 105, 125];

    //Temporizador de duracion 100 ms para mover la serpiente
    const duration = Duration(milliseconds: 100);
    Timer.periodic(duration, (Timer timer) {
      updateSnake();
      if (gameOver()) {
        timer.cancel();
        //En caso de perder, el temporizador se detiene y muestra la pantalla de game over
        _showGameOverScreen();
      }
    });
  }

//Funcion para mover la serpiente en la direccion que se desee y de "teletransportarla" al pasar de los bordes de la pantalla
  var direction = 'down';
  void updateSnake() {
    setState(() {
      switch (direction) {
        //Se mueve hacia abajo
        case 'down':
          if (snakePosition.last > 740) {
            snakePosition.add(snakePosition.last + 20 - 760);
          } else {
            snakePosition.add(snakePosition.last + 20);
          }

          break;
        //Se mueve hacia arriba
        case 'up':
          if (snakePosition.last < 20) {
            snakePosition.add(snakePosition.last - 20 + 760);
          } else {
            snakePosition.add(snakePosition.last - 20);
          }
          break;
        //Se mueve hacia la izquierda
        case 'left':
          if (snakePosition.last % 20 == 0) {
            snakePosition.add(snakePosition.last - 1 + 20);
          } else {
            snakePosition.add(snakePosition.last - 1);
          }
          break;
        //Se mueve hacia la derecha
        case 'right':
          if ((snakePosition.last + 1) % 20 == 0) {
            snakePosition.add(snakePosition.last + 1 - 20);
          } else {
            snakePosition.add(snakePosition.last + 1);
          }
          break;

        default:
      }
      // Si la serpiente come la comida, se genera una nueva, de lo contrario, se elimina la ultima posición de la serpiente
      if (snakePosition.last == food) {
        generateNewFood();
      } else {
        snakePosition.removeAt(0);
      }
    });
  }

  //Se verifica si la serpiente se come a si misma, y en ese caso se detiene el juego
  bool gameOver() {
    for (int i = 0; i < snakePosition.length; i++) {
      int count = 0;
      for (int j = 0; j < snakePosition.length; j++) {
        if (snakePosition[i] == snakePosition[j]) {
          count += 1;
        }
        if (count == 2) {
          return true;
        }
      }
    }
    return false;
  }

  //Pantalla de game over, muestra cuantas manzanas se comieron y un boton para volver a jugar
  void _showGameOverScreen() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('GAME OVER'),
            content: Text(
              'You ate ${snakePosition.length} apples',
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
                  startGame();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: appBar(),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              // Detecta el gesto tactil vertical para cambiar la dirección de la serpiente
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              // Detecta el gesto tactil horizontal para cambiar la dirección de la serpiente
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },

              child: Container(
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: numberOfSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 20),
                    itemBuilder: (BuildContext context, int index) {
                      //Se utiliza verde para cada cuadro en la tabla que representa la serpiente, de rojo la comida y de gris los cuadros vacios
                      if (snakePosition.contains(index)) {
                        return Center(
                          child: Container(
                            padding: EdgeInsets.all(2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                color: const Color.fromARGB(255, 0, 255, 26),
                              ), //Container
                            ), //ClipRRect
                          ), //Container
                        ); //Center
                      }
                      if (index == food) {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                  color: const Color.fromARGB(
                                      255, 230, 0, 0))), //ClipRRect
                        );
                      } else {
                        return Container(
                          padding: EdgeInsets.all(2),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                  color: Colors.grey[900])), //ClipRRect
                        ); //Container
                      }
                    }), //GridView.builder
              ), //Container
            ), //GestureDetector
          ), //Expanded
          //Franja en la parte inferior de la pantalla que muestra el boton de start game y el nombre del juego
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: startGame,
                  child: Text(
                    'START GAME',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 238, 255),
                        fontSize: 20),
                  ), //Text
                ), //GestureDetector
                Text(
                  'SNAKE GAME',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 21, 0, 255),
                      fontSize: 20),
                ) //Text
              ], //<Widget>[]
            ), //Row
          ) //Padding
        ], //<Widget>[]
      ), //Column
    ); //Scaffold
  }
}
