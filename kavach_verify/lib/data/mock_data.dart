import '../models/detection_item.dart';

final List<DetectionItem> mockDetections = [
  DetectionItem(
    id: '1',
    title: 'Viral WhatsApp Forward About Free Gov Scheme',
    description:
        'A message claiming the government is distributing free laptops to all students has been circulating on WhatsApp. Our AI analysis found no official source.',
    imageUrl: null,
    location: 'New Delhi, India',
    category: 'text',
    detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
    confidenceScore: 0.94,
    analysisDetails:
        '• No official government press release found matching this claim.\n'
        '• The registration link redirects to a phishing site.\n'
        '• Similar messages have been debunked by PIB Fact Check.\n'
        '• The formatting and language pattern matches known spam templates.',
    isFake: true,
  ),
  DetectionItem(
    id: '2',
    title: 'Manipulated Image of Celebrity Endorsement',
    description:
        'A doctored image showing a celebrity endorsing a cryptocurrency investment scheme has been shared widely on social media.',
    imageUrl: 'https://picsum.photos/seed/fake1/400/300',
    location: 'Mumbai, India',
    category: 'image',
    detectedAt: DateTime.now().subtract(const Duration(hours: 5)),
    confidenceScore: 0.97,
    analysisDetails:
        '• Error Level Analysis reveals inconsistent compression artifacts.\n'
        '• The celebrity\'s management has denied any such endorsement.\n'
        '• Reverse image search shows the original unedited photo.\n'
        '• Font used in the text overlay does not match official branding.',
    isFake: true,
  ),
  DetectionItem(
    id: '3',
    title: 'Deepfake Audio of Political Leader',
    description:
        'An audio clip purporting to be a political leader making controversial statements has been flagged as AI-generated.',
    imageUrl: null,
    location: 'Bangalore, India',
    category: 'voice',
    detectedAt: DateTime.now().subtract(const Duration(hours: 8)),
    confidenceScore: 0.89,
    analysisDetails:
        '• Spectral analysis shows unnatural frequency patterns.\n'
        '• Voice biometric comparison shows 34% deviation from genuine samples.\n'
        '• Background noise patterns are synthetically generated.\n'
        '• No official record of any such speech or statement exists.',
    isFake: true,
  ),
  DetectionItem(
    id: '4',
    title: 'Fake News Website Article on Health Cure',
    description:
        'A fake news article claiming a miracle cure for diabetes has been shared over 50,000 times on social media.',
    imageUrl: 'https://picsum.photos/seed/fake2/400/300',
    location: 'Chennai, India',
    category: 'link',
    detectedAt: DateTime.now().subtract(const Duration(days: 1)),
    confidenceScore: 0.92,
    analysisDetails:
        '• The website domain was registered just 3 days ago.\n'
        '• No medical studies support the claims made.\n'
        '• The "doctor" quoted does not exist in any medical registry.\n'
        '• The article uses common clickbait and fear-mongering patterns.',
    isFake: true,
  ),
  DetectionItem(
    id: '5',
    title: 'Altered Government Document Shared on Social Media',
    description:
        'A forged government notification about a new tax policy has been circulating across platforms.',
    imageUrl: 'https://picsum.photos/seed/fake3/400/300',
    location: 'Hyderabad, India',
    category: 'document',
    detectedAt: DateTime.now().subtract(const Duration(days: 2)),
    confidenceScore: 0.96,
    analysisDetails:
        '• The document header font does not match official templates.\n'
        '• The file number referenced does not exist in government records.\n'
        '• Metadata analysis shows the PDF was created with a consumer editor.\n'
        '• The seal and signature appear to be copied from another document.',
    isFake: true,
  ),
  DetectionItem(
    id: '6',
    title: 'Deepfake Video of Business Leader',
    description:
        'A deepfake video shows a well-known business leader announcing a fake product launch.',
    imageUrl: 'https://picsum.photos/seed/fake4/400/300',
    location: 'Pune, India',
    category: 'video',
    detectedAt: DateTime.now().subtract(const Duration(days: 3)),
    confidenceScore: 0.91,
    analysisDetails:
        '• Facial landmark analysis detects micro-expression anomalies.\n'
        '• Lip-sync accuracy is below natural speech threshold.\n'
        '• The company has officially denied any such announcement.\n'
        '• Frame-by-frame analysis reveals temporal artifacts at splice points.',
    isFake: true,
  ),
];

final List<ChatMessage> mockChatMessages = [
  ChatMessage(
    id: '1',
    text:
        'Hello! I\'m KavachVerify AI 🛡️ I can help you verify if any content is real or fake. Send me text, images, documents, or links and I\'ll analyze them for you!',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  ChatMessage(
    id: '2',
    text:
        'Hey! I found this message on WhatsApp saying the government is giving free laptops. Is it real?',
    isUser: true,
    timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
  ),
  ChatMessage(
    id: '3',
    text:
        '🔍 Analyzing your text...\n\n⚠️ **FAKE CONTENT DETECTED**\nConfidence: 94%\n\nThis is a known phishing scam. There is no official government program matching this description. The link in the message leads to a data-harvesting website. Please do not click any links or share personal information.',
    isUser: false,
    timestamp: DateTime.now().subtract(const Duration(minutes: 27)),
  ),
];

final UserProfile mockProfile = UserProfile(
  name: 'Alakshya Singh',
  email: 'alakshya@kavachverify.com',
  avatarUrl: '',
  totalVerified: 147,
  accuracyScore: 96.3,
  communityRank: 'Gold Defender',
);

final List<Map<String, String>> mockComments = [
  {
    'user': 'Arjun M.',
    'comment': 'I received the same message! Thanks for flagging it.',
    'time': '2 hours ago',
  },
  {
    'user': 'Priya S.',
    'comment':
        'My uncle almost fell for this. Shared this analysis with my family group.',
    'time': '5 hours ago',
  },
  {
    'user': 'Rahul K.',
    'comment': 'Great analysis! The phishing link was very convincing.',
    'time': '1 day ago',
  },
];
