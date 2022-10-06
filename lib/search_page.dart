import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:newsapi2/webView.dart';
import 'package:path_provider/path_provider.dart';

import 'cubit.dart';
import 'network_request.dart';
import 'newsModel.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

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
    
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            getData(context);
          },
          child: Column(
            children: [
              TextField(
                  onChanged: (value) => onSearchTextChanged(value),
                  decoration: const InputDecoration(labelText: 'Search',)
              ),
              Expanded(
                child: BlocBuilder<VisibleCubit, bool>(
                  builder: (context, state) {
                    return Visibility(
                      visible: state,
                      replacement: ListView(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Container(
                                height: MediaQuery.of(context).size.height,
                                padding: const EdgeInsets.only(bottom: 200),
                                child: const Center(
                                    child: LoadingIndicator(
                                      indicatorType: Indicator.ballRotate,
                                      colors: [Colors.red, Colors.orange, Colors.yellow],
                                    ))),
                          ]),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WebViewPage(
                                        url: "${searchArticles[index].url}",
                                      )),
                                );
                              },
                              tileColor: const Color(0xff4D5258),
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(
                                    "${searchArticles[index].urlToImage}"),
                              ),
                              title: Text(
                                "${searchArticles[index].title}",
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "${searchArticles[index].description}",
                                style: const TextStyle(color: Color(0xffAFB4BA)),
                              ),
                            ),
                          );
                        },
                        itemCount: searchArticles.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getData(BuildContext context) async {
    await openBox();
    dynamic postsJson;

    try {
      postsJson = await fetchPost();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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

  onSearchTextChanged(String text) {
    searchArticles.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for(int i=0;i<newsArticles!.length;i++)
    {
      if(newsArticles![i].title!.contains(text))
      {
        searchArticles.add(newsArticles![i]);
      }
    }

    print("Total Seach.${searchArticles.length}");

    setState(() {});
  }
}
