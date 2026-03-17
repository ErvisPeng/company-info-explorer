import 'package:url_launcher/url_launcher.dart';

Future<void> openWebsite(String url) async {
  String target = url;
  if (!target.startsWith('http://') && !target.startsWith('https://')) {
    target = 'https://$target';
  }
  final uri = Uri.parse(target);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
