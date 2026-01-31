import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

const prompt = '''
あなたは20年以上のキャリアがあるフルスタックエンジニアです。
今から渡されるコードの
・問題点の指摘
・問題点を修正し、より簡潔にしたコード
・修正点の説明
をそれぞれ別々でMarkdown形式かつ、タイトル部分を###で出力してください。
問題点の指摘や修正点の説明は、プログラミング初心者にもわかるように、詳しく背景を説明してください。
''';

void main() async {
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  runApp(const MaterialApp(title: 'Code Reviewer', home: CodeReviewer()));
}

class CodeReviewer extends StatefulWidget {
  const CodeReviewer({super.key});

  @override
  State<CodeReviewer> createState() => _CodeReviewerState();
}

class _CodeReviewerState extends State<CodeReviewer> {
  bool _isLoading = false;
  String _content = "";

  void _review() async {
    setState(() {
      _isLoading = true;
    });

    final result = await Gemini.instance.text(prompt + _content);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          width: MediaQuery.of(context).size.width,
          child: Markdown(data: result?.output ?? ""),
        );
      },
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Code Reviewer"),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        maxLines: null,
                        onChanged: (val) => setState(() {
                          _content = val;
                        }),
                        initialValue: _content,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
            ),
            ElevatedButton(
              onPressed: _isLoading || _content.isEmpty ? null : _review,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 0),
                backgroundColor: Colors.indigo[600],
                disabledBackgroundColor: Colors.indigo[600]!.withOpacity(0.5),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('レビューする'),
            ),
          ],
        ),
      ),
    );
  }
}
