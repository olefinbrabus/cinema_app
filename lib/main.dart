import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Кінотеатр',
      home: MovieListScreen(),
    );
  }
}

class Movie {
  final String title;
  final List<String> showtimes;
  final String imageUrl;

  Movie(this.title, this.showtimes, this.imageUrl);
}

class MovieListScreen extends StatelessWidget {
  final List<Movie> movies = [
    Movie('Боже Вiльнi', ['12:00', '15:00', '18:00'],
        'https://multiplex.ua/images/33/71/3371392ba52cbfa125a11524c4435aa9.jpeg'),
    Movie('Веном 3', ['13:00', '16:00', '19:00'],
        'https://multiplex.ua/images/86/94/8694a5f64fdb5f116593cb53ac952a96.jpeg'),
    Movie('Жахаючий 3', ['14:00', '17:00', '20:00'],
        'https://multiplex.ua/images/b7/36/b736933608bef6ba422684adf5c6a35b.jpeg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Каталог фільмів')),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return Container(
            color: index % 2 == 1 ? Colors.redAccent : Colors.white,
            child: ListTile(
              title: Center(child: Text(movies[index].title)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowtimeSelectionScreen(movies[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ShowtimeSelectionScreen extends StatelessWidget {
  final Movie movie;

  ShowtimeSelectionScreen(this.movie);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: Column(
        children: [
          Image.network(
            movie.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: movie.showtimes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Center(child: Text(movie.showtimes[index])),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SeatingChart(movie.title, movie.showtimes[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SeatingChart extends StatefulWidget {
  final String movieTitle;
  final String showtime;

  SeatingChart(this.movieTitle, this.showtime);

  @override
  _SeatingChartState createState() => _SeatingChartState();
}

class _SeatingChartState extends State<SeatingChart> {
  final int rows = 8;
  final int seatsPerRow = 30;
  late List<List<bool>> _seats;
  List<String> selectedSeats = [];
  double _scaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _seats = List.generate(rows, (_) => List.generate(seatsPerRow, (_) => false));
  }

  void _toggleSeat(int row, int seat) {
    setState(() {
      _seats[row][seat] = !_seats[row][seat];
      String seatPosition = '${row + 1}-${seat + 1}';
      if (_seats[row][seat]) {
        selectedSeats.add(seatPosition);
      } else {
        selectedSeats.remove(seatPosition);
      }
    });
  }

  void _confirmSelection(BuildContext context) {
    if (selectedSeats.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouScreen(
            movieTitle: widget.movieTitle,
            showtime: widget.showtime,
            selectedSeats: selectedSeats,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Будь ласка, оберіть хоча б одне місце.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.movieTitle} - ${widget.showtime}'),
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scaleFactor = details.scale.clamp(1.0, 2.0);
          });
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                Container(
                  transform: Matrix4.diagonal3Values(_scaleFactor, _scaleFactor, 1.0),
                  child: Column(
                    children: [
                      for (int row = 0; row < rows; row++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int seat = 0; seat < seatsPerRow; seat++)
                              GestureDetector(
                                onTap: () => _toggleSeat(row, seat),
                                child: Container(
                                  margin: EdgeInsets.all(4.0),
                                  width: 30 * _scaleFactor,
                                  height: 30 * _scaleFactor,
                                  color: _seats[row][seat] ? Colors.green : Colors.grey,
                                  child: Center(
                                    child: Text(
                                      '${row + 1}-${seat + 1}',
                                      style: TextStyle(color: Colors.white, fontSize: 10 * _scaleFactor),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _confirmSelection(context),
                  child: Text('Обрати'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThankYouScreen extends StatelessWidget {
  final String movieTitle;
  final String showtime;
  final List<String> selectedSeats;

  ThankYouScreen({
    required this.movieTitle,
    required this.showtime,
    required this.selectedSeats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Дякуємо за покупку!')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Дякуємо за вибір!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Фільм: $movieTitle',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Час: $showtime',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Місця: ${selectedSeats.join(', ')}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: Text('Повернутися до головного екрану'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
