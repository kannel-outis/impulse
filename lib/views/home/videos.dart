part of 'home.dart';

class VideosPage extends StatelessWidget {
  const VideosPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
            child: Text("data 1"),
          ),
        ],
      ),
    );
  }
}
