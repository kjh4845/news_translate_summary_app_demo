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
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF8BB6E8), // 연한 파스텔 블루
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // 매우 연한 그레이-블루
        textTheme: GoogleFonts.notoSansTextTheme().copyWith(
          headlineLarge: GoogleFonts.notoSans(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.5,
          ),
          titleLarge: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.3,
          ),
          titleMedium: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF2D3748),
            letterSpacing: -0.2,
          ),
          bodyLarge: GoogleFonts.notoSans(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF4A5568),
            letterSpacing: -0.1,
            height: 1.6,
          ),
          bodyMedium: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF718096),
            letterSpacing: -0.1,
            height: 1.5,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8BB6E8),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shadowColor: const Color(0xFF8BB6E8).withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8BB6E8),
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: const Color(0xFF8BB6E8).withOpacity(0.3),
          ),
        ),
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
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !isLoading) {
        fetchNews(selectedCountry, page: currentPage + 1);
      }
    });
  }

  Future<void> fetchNews(String country, {int page = 1}) async {
    setState(() => isLoading = true);
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/news?country=$country&page=$page'),
    );
    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      List<NewsItem> fetched =
      jsonList.map((item) => NewsItem.fromJson(item)).toList();
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

  String _getCountryName(String code) {
    switch (code) {
      case 'kr':
        return '🇰🇷 한국';
      case 'us':
        return '🇺🇸 미국';
      case 'jp':
        return '🇯🇵 일본';
      case 'gb':
        return '🇬🇧 영국';
      case 'fr':
        return '🇫🇷 프랑스';
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📰 뉴스 요약"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8BB6E8), Color(0xFFA8C8EC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: selectedCountry,
              dropdownColor: Colors.white,
              underline: Container(),
              icon: const Icon(Icons.expand_more, color: Colors.white),
              borderRadius: BorderRadius.circular(12),
              onChanged: (String? newValue) {
                if (newValue != null) updateCountry(newValue);
              },
              items:
              <String>[
                'kr',
                'us',
                'jp',
                'gb',
                'fr',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _getCountryName(value),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: newsItems.length + 1,
          itemBuilder: (context, index) {
            if (index == newsItems.length) {
              return isLoading
                  ? Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8BB6E8).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF8BB6E8),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              )
                  : const SizedBox.shrink();
            }
            final item = newsItems[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailPage(news: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.image != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: item.image!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                        Color(0xFF8BB6E8),
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget:
                                    (context, url, error) => Container(
                                  height: 200,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Color(0xFF8BB6E8),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getCountryName(
                                      selectedCountry,
                                    ).split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8BB6E8,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    "자세히 보기",
                                    style: TextStyle(
                                      color: const Color(0xFF8BB6E8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: const Color(0xFF8BB6E8),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
      appBar: AppBar(
        title: const Text("📖 뉴스 상세"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8BB6E8), Color(0xFFA8C8EC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.image != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: news.image!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                        height: 220,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8BB6E8),
                            ),
                          ),
                        ),
                      ),
                      errorWidget:
                          (context, url, error) => Container(
                        height: 220,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 50,
                            color: Color(0xFF8BB6E8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8BB6E8).withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(height: 1.3),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BB6E8).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            size: 16,
                            color: const Color(0xFF8BB6E8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "📝 요약",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8BB6E8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      news.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (news.translated != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8E6B8).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.translate_outlined,
                              size: 16,
                              color: const Color(0xFF48BB78),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "🌐 번역된 내용",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF48BB78),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB8E6B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB8E6B8).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          news.translated!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ] else if (news.original != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 16,
                              color: const Color(0xFF718096),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "📄 원문",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          news.original!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(news.url)),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text(
                      "원문 보러가기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BB6E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 3,
                      shadowColor: const Color(0xFF8BB6E8).withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
