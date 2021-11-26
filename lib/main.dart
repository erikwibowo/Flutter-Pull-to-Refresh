import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/user.dart';

void main() {
  var faker = new Faker();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<User> users = [];

  void initdata() {
    for (var i = 0; i < 15; i++) {
      users.add(User(nama: faker.person.name(), email: faker.internet.email()));
    }
  }

  void _onRefresh() async {
    users.clear();
    await Future.delayed(const Duration(milliseconds: 1000));
    initdata();
    setState(() {});
    _refreshController.refreshCompleted();
    _refreshController.loadComplete();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (users.length >= 35) {
      _refreshController.loadNoData();
    } else {
      initdata();
      if (mounted) setState(() {});
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    initdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pull to refresh"),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        controller: _refreshController,
        header: const WaterDropHeader(),
        footer: CustomFooter(
          builder: (context, mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = const CircularProgressIndicator();
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("release to load more");
            } else {
              body = const Text("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(users[index].nama),
            subtitle: Text(users[index].email),
            leading: CircleAvatar(
              child: Text("${index + 1}"),
            ),
          ),
        ),
      ),
    );
  }
}
