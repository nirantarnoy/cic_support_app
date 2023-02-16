import 'package:flutter/cupertino.dart';
import 'package:redis/redis.dart';

class AppCache extends StatefulWidget {
  const AppCache({Key? key}) : super(key: key);

  @override
  State<AppCache> createState() => _AppCacheState();
}

class _AppCacheState extends State<AppCache> {
  @override
  void initState() {
    // TODO: implement initState
    redisCon();
    super.initState();
  }

  dynamic redisCon() async {
    final conn = await RedisConnection();
    conn
        .connect("172.16.0.231", 6379)
        .then((Command command) => command.send_object(['SET', 'Key', []]).then(
            (value) => print("redis result is ${value}")))
        .onError((error, stackTrace) => null);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
