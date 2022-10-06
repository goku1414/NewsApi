// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:newsapi2/search_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'cubit.dart';
import 'network_request.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'newsModel.dart';
import 'webView.dart';

void main() async {
  Hive.initFlutter();
  runApp(BlocProvider(
    create: (context) => VisibleCubit(),
    child: MaterialApp(
      theme: ThemeData.from(colorScheme: ColorScheme.dark()),
      home: MyApp(),),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Color(0xff212429),
        appBar: AppBar(
          actions: [IconButton(icon: Icon(Icons.search), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          },)],
          title: Text("NewsPage"),
          backgroundColor: Color(0xff2D3035),
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: NewsBody()),
    );
  }
}

class NewsBody extends StatefulWidget {
  @override
  State<NewsBody> createState() => _NewsBodyState();
}

class _NewsBodyState extends State<NewsBody> {

  Future openBox() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    box = await Hive.openBox('name');
    return;
  }

  Box? box;

  bool isVisible = false;

  NewsModel? posts;

  List<Articles>? newsArticles;
  List<Articles> searchArticles = [];

  @override
  Widget build(BuildContext context) {
    getData(context);
    return RefreshIndicator(
      onRefresh: () async {
        getData(context);
      },
      child: Column(
        children: [

          Expanded(
            child: BlocBuilder<VisibleCubit, bool>(
              builder: (context, state) {
                return Visibility(
                  visible: state,
                  replacement: ListView(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        Container(
                            height: MediaQuery.of(context).size.height,
                            padding: EdgeInsets.only(bottom: 200),
                            child: Center(
                                child: LoadingIndicator(
                              indicatorType: Indicator.ballRotate,
                              colors: const [Colors.red, Colors.orange, Colors.yellow],
                            ))),
                      ]),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                        url: "${newsArticles![index].url}",
                                      )),
                            );
                          },
                          tileColor: Color(0xff4D5258),
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                "${newsArticles![index].urlToImage}"),
                          ),
                          title: Text(
                            "${newsArticles![index].title}",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${newsArticles![index].description}",
                            style: TextStyle(color: Color(0xffAFB4BA)),
                          ),
                        ),
                      );
                    },
                    itemCount: newsArticles?.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  getData(BuildContext context) async {
    await openBox();
    var postsJson;

    try {
      postsJson = await fetchPost();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Internet Not Available"),
      ));
    }
    if (box!.get("PostJson") != null) {
      posts = NewsModel.fromJson(box!.get("PostJson"));
      newsArticles = posts?.articles;
      BlocProvider.of<VisibleCubit>(context).visible();
    }
    if (postsJson != null) {
      box!.put("PostJson", postsJson);
      // posts = NewsModel.fromJson(postsJson);
      // newsArticles = posts?.articles;
      // BlocProvider.of<VisibleCubit>(context).visible();
    }

  }

}
