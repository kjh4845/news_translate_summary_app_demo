import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class NewsItem {
  final String title;
  final String url;
  final String? image;
  final String summary;
  final String? translated;
  final String? original;

  NewsItem({
    required this.title,
    required this.url,
    this.image,
    required this.summary,
    this.translated,
    this.original,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'],
      url: json['url'],
      image: json['image'],
      summary: json['summary'],
      translated: json['translated'],
      original: json['original'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '뉴스 요약 앱',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String selectedCountry = "kr";
  int currentPage = 1;
  bool isLoading = false;
  List<NewsItem> newsItems = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNews(selectedCountry, page: 1);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !isLoading) {
        fetchNews(selectedCountry, page: currentPage + 1);
      }
    });
  }

  Future<void> fetchNews(String country, {int page = 1}) async {
    setState(() => isLoading = true);
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/news?country=$country&page=$page'));
    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      List<NewsItem> fetched = jsonList.map((item) => NewsItem.fromJson(item)).toList();
      setState(() {
        if (page == 1) newsItems.clear();
        newsItems.addAll(fetched);
        currentPage = page;
      });
    }
    setState(() => isLoading = false);
  }

  void updateCountry(String country) {
    setState(() {
      selectedCountry = country;
      currentPage = 1;
    });
    fetchNews(country, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("뉴스 요약"),
        actions: [
          DropdownButton<String>(
            value: selectedCountry,
            dropdownColor: Colors.white,
            underline: Container(),
            icon: const Icon(Icons.language, color: Colors.white),
            onChanged: (String? newValue) {
              if (newValue != null) updateCountry(newValue);
            },
            items: <String>['kr', 'us', 'jp', 'gb', 'fr']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: newsItems.length + 1,
        itemBuilder: (context, index) {
          if (index == newsItems.length) {
            return isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
                : const SizedBox.shrink();
          }
          final item = newsItems[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewsDetailPage(news: item),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.image != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: item.image!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const LinearProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.summary,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final NewsItem news;
  const NewsDetailPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(news.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.image != null)
                CachedNetworkImage(
                  imageUrl: news.image!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              Text("요약", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(news.summary),
              const SizedBox(height: 16),
              if (news.translated != null) ...[
                Text("번역된 내용", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(news.translated!)
              ] else if (news.original != null) ...[
                Text("원문", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(news.original!)
              ],
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => launchUrl(Uri.parse(news.url)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("원문 보기"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
