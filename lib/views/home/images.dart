part of 'home.dart';

class ImagesPage extends StatelessWidget {
  const ImagesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.pink,
      child: const Row(
        children: [
          Expanded(
            child: Text("data 1"),
          ),
        ],
      ),
    );
  }
}
