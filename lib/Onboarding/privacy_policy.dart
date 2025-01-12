import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  PrivacyPolicy({super.key});

  final TocController _controller = TocController();

  void _handleLinks(String url) {
    if (url.contains('#')) {
      _controller.jumpToIndex(
        switch (url) {
          '#table-of-contents' => 6,
          '#1-what-information-do-we-collect' => 8,
          '#personal-information-you-disclose-to-us' => 9,
          '#2-how-do-we-process-your-information' => 12,
          '#3-what-are-your-privacy-rights' => 14,
          _ => 14
        },
      );
    } else {
      launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    const headerTextStyle = TextStyle(height: 2, fontWeight: FontWeight.w100);
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 1000,
          child: FutureBuilder(
              future: rootBundle.loadString('assets/privacy_policy.md'),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: MarkdownWidget(
                      config: MarkdownConfig(configs: [
                        H1Config(style: headerTextStyle.copyWith(fontSize: 26)),
                        H2Config(style: headerTextStyle.copyWith(fontSize: 22)),
                        H3Config(style: headerTextStyle.copyWith(fontSize: 18)),
                        H4Config(style: headerTextStyle.copyWith(fontSize: 17)),
                        const TableConfig(
                          columnWidths: {0: FractionColumnWidth(0.25)},
                        ),
                        ListConfig(
                          marker: (isOrdered, depth, index) => const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                            ),
                          ),
                        ),
                        LinkConfig(onTap: (url) => _handleLinks(url)),
                      ]),
                      data: snapshot.data!,
                      tocController: _controller,
                    ),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
      ),
    );
  }
}
