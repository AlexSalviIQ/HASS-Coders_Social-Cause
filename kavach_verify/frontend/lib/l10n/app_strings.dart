/// Centralized translations for English (en), Hindi (hi), Marathi (mr).
/// Usage: AppStrings.get('key', locale)  where locale is 'en'/'hi'/'mr'.
class AppStrings {
  AppStrings._();

  static String get(String key, String locale) {
    return _strings[key]?[locale] ?? _strings[key]?['en'] ?? key;
  }

  static const Map<String, Map<String, String>> _strings = {
    // ─── Navigation / Shell ───
    'nav_home': {'en': 'Home', 'hi': 'होम', 'mr': 'होम'},
    'nav_chat': {'en': 'Chat', 'hi': 'चैट', 'mr': 'चॅट'},
    'nav_library': {'en': 'Library', 'hi': 'लाइब्रेरी', 'mr': 'लायब्ररी'},
    'nav_whatsapp': {
      'en': 'WhatsApp Bot',
      'hi': 'व्हाट्सएप बॉट',
      'mr': 'व्हॉट्सअ‍ॅप बॉट',
    },
    'nav_community': {'en': 'Community', 'hi': 'समुदाय', 'mr': 'समुदाय'},
    'nav_report': {'en': 'Report', 'hi': 'रिपोर्ट', 'mr': 'रिपोर्ट'},
    'nav_profile': {'en': 'Profile', 'hi': 'प्रोफ़ाइल', 'mr': 'प्रोफाइल'},
    'nav_details': {'en': 'Details', 'hi': 'विवरण', 'mr': 'तपशील'},
    'tagline': {
      'en': 'Truth Shield for the Digital Age',
      'hi': 'डिजिटल युग के लिए सत्य कवच',
      'mr': 'डिजिटल युगासाठी सत्य कवच',
    },

    // ─── Home Screen ───
    'quick_access': {
      'en': 'Quick Access',
      'hi': 'त्वरित पहुँच',
      'mr': 'जलद प्रवेश',
    },
    'pick_content_type': {
      'en': 'Pick a content type to verify',
      'hi': 'सत्यापन के लिए सामग्री चुनें',
      'mr': 'पडताळणीसाठी सामग्री निवडा',
    },
    'image_video': {
      'en': 'Image / Video',
      'hi': 'चित्र / वीडियो',
      'mr': 'चित्र / व्हिडिओ',
    },
    'photos_clips': {
      'en': 'Photos & clips',
      'hi': 'फ़ोटो और क्लिप',
      'mr': 'फोटो आणि क्लिप',
    },
    'document_verify': {
      'en': 'Document Verify',
      'hi': 'दस्तावेज़ सत्यापन',
      'mr': 'दस्तऐवज पडताळणी',
    },
    'pdfs_docs': {
      'en': 'PDFs & docs',
      'hi': 'पीडीएफ और डॉक्स',
      'mr': 'पीडीएफ आणि डॉक्स',
    },
    'gov_id_check': {
      'en': 'Gov ID Check',
      'hi': 'सरकारी ID जाँच',
      'mr': 'शासकीय ID तपासणी',
    },
    'id_verification': {
      'en': 'ID verification',
      'hi': 'ID सत्यापन',
      'mr': 'ID पडताळणी',
    },
    'report': {'en': 'Report', 'hi': 'रिपोर्ट', 'mr': 'रिपोर्ट'},
    'report_fake_content': {
      'en': 'Report fake content',
      'hi': 'फर्जी सामग्री रिपोर्ट करें',
      'mr': 'बनावट सामग्री रिपोर्ट करा',
    },
    'latest_detections': {
      'en': 'Latest Detections',
      'hi': 'नवीनतम पहचान',
      'mr': 'ताज्या शोध',
    },
    'view_all': {'en': 'View All', 'hi': 'सभी देखें', 'mr': 'सर्व पहा'},
    'no_detections': {
      'en': 'No detections yet. Start verifying content!',
      'hi': 'अभी तक कोई पहचान नहीं। सामग्री सत्यापित करना शुरू करें!',
      'mr': 'अद्याप कोणताही शोध नाही. सामग्री पडताळणे सुरू करा!',
    },
    'camera': {'en': 'Camera', 'hi': 'कैमरा', 'mr': 'कॅमेरा'},
    'gallery': {'en': 'Gallery', 'hi': 'गैलरी', 'mr': 'गॅलरी'},
    'video': {'en': 'Video', 'hi': 'वीडियो', 'mr': 'व्हिडिओ'},
    'capture_id': {
      'en': 'Capture ID',
      'hi': 'ID कैप्चर करें',
      'mr': 'ID कॅप्चर करा',
    },
    'upload_id': {
      'en': 'Upload ID',
      'hi': 'ID अपलोड करें',
      'mr': 'ID अपलोड करा',
    },
    'remember_me': {
      'en': 'Remember me',
      'hi': 'मुझे याद रखें',
      'mr': 'मला लक्षात ठेवा',
    },

    // ─── Chat Screen ───
    'attach_content': {
      'en': 'Attach Content',
      'hi': 'सामग्री संलग्न करें',
      'mr': 'सामग्री जोडा',
    },
    'image_video_short': {
      'en': 'Image/Video',
      'hi': 'चित्र/वीडियो',
      'mr': 'चित्र/व्हिडिओ',
    },
    'document': {'en': 'Document', 'hi': 'दस्तावेज़', 'mr': 'दस्तऐवज'},
    'gov_id': {'en': 'Gov ID', 'hi': 'सरकारी ID', 'mr': 'शासकीय ID'},
    'recording': {
      'en': 'Recording...',
      'hi': 'रिकॉर्डिंग...',
      'mr': 'रेकॉर्डिंग...',
    },
    'tap_mic_stop': {
      'en': 'Tap mic to stop',
      'hi': 'रोकने के लिए माइक टैप करें',
      'mr': 'थांबवण्यासाठी माइक टॅप करा',
    },
    'type_message': {
      'en': 'Type a message or attach media...',
      'hi': 'संदेश टाइप करें या मीडिया संलग्न करें...',
      'mr': 'संदेश टाइप करा किंवा मीडिया जोडा...',
    },
    'camera_unavailable': {
      'en': 'Camera unavailable',
      'hi': 'कैमरा उपलब्ध नहीं',
      'mr': 'कॅमेरा उपलब्ध नाही',
    },
    'cannot_access_gallery': {
      'en': 'Cannot access gallery',
      'hi': 'गैलरी तक पहुँच नहीं',
      'mr': 'गॅलरी उपलब्ध नाही',
    },
    'cannot_pick_video': {
      'en': 'Cannot pick video',
      'hi': 'वीडियो चुन नहीं सकते',
      'mr': 'व्हिडिओ निवडता येत नाही',
    },
    'cannot_pick_document': {
      'en': 'Cannot pick document',
      'hi': 'दस्तावेज़ चुन नहीं सकते',
      'mr': 'दस्तऐवज निवडता येत नाही',
    },
    'cannot_pick_file': {
      'en': 'Cannot pick file',
      'hi': 'फ़ाइल चुन नहीं सकते',
      'mr': 'फाइल निवडता येत नाही',
    },
    'microphone_denied': {
      'en': 'Microphone permission denied',
      'hi': 'माइक्रोफ़ोन अनुमति अस्वीकृत',
      'mr': 'मायक्रोफोन परवानगी नाकारली',
    },
    'recording_failed': {
      'en': 'Recording failed',
      'hi': 'रिकॉर्डिंग विफल',
      'mr': 'रेकॉर्डिंग अयशस्वी',
    },
    'server_error': {
      'en': '❌ Could not reach the server. Please check your connection.',
      'hi': '❌ सर्वर से संपर्क नहीं हो सका। कृपया अपना कनेक्शन जाँचें।',
      'mr': '❌ सर्व्हरशी संपर्क होत नाही. कृपया तुमचे कनेक्शन तपासा.',
    },
    'analysis_complete': {
      'en': 'Analysis complete.',
      'hi': 'विश्लेषण पूर्ण।',
      'mr': 'विश्लेषण पूर्ण.',
    },
    'analysis_failed': {
      'en': 'Analysis failed. Please try again.',
      'hi': 'विश्लेषण विफल। कृपया पुन: प्रयास करें।',
      'mr': 'विश्लेषण अयशस्वी. कृपया पुन्हा प्रयत्न करा.',
    },
    'report_generated': {
      'en':
          '\n\n📄 An official verification report has been generated. Tap the button below to download it.',
      'hi':
          '\n\n📄 एक आधिकारिक सत्यापन रिपोर्ट तैयार की गई है। डाउनलोड करने के लिए नीचे बटन दबाएं।',
      'mr':
          '\n\n📄 अधिकृत पडताळणी अहवाल तयार झाला आहे. डाउनलोड करण्यासाठी खाली बटण दाबा.',
    },
    'download_report': {
      'en': '📥 Download Official Report',
      'hi': '📥 आधिकारिक रिपोर्ट डाउनलोड करें',
      'mr': '📥 अधिकृत अहवाल डाउनलोड करा',
    },
    'opening_report': {
      'en': 'Opening report…',
      'hi': 'रिपोर्ट खोल रहे हैं…',
      'mr': 'अहवाल उघडत आहे…',
    },
    'could_not_open': {
      'en': 'Could not open the report',
      'hi': 'रिपोर्ट खोल नहीं सकते',
      'mr': 'अहवाल उघडता आला नाही',
    },
    'media_verification': {
      'en': 'Media Verification',
      'hi': 'मीडिया सत्यापन',
      'mr': 'मीडिया पडताळणी',
    },
    'copy': {'en': 'Copy', 'hi': 'कॉपी करें', 'mr': 'कॉपी करा'},
    'speak': {'en': 'Speak', 'hi': 'बोलें', 'mr': 'बोला'},
    'copied': {
      'en': 'Copied to clipboard 📋',
      'hi': 'क्लिपबोर्ड पर कॉपी हो गया 📋',
      'mr': 'क्लिपबोर्डवर कॉपी केले 📋',
    },
    'today': {'en': 'Today', 'hi': 'आज', 'mr': 'आज'},
    'yesterday': {'en': 'Yesterday', 'hi': 'कल', 'mr': 'काल'},
    'welcome_message': {
      'en':
          '👋 Welcome to KavachVerify!\n\nSend me any text claim, image, video, document, voice note, or government ID — I\'ll analyze it for manipulation, deepfakes, and misinformation.\n\nTry sending a screenshot of a news article to get started! 🔍',
      'hi':
          '👋 KavachVerify में आपका स्वागत है!\n\nमुझे कोई भी टेक्स्ट दावा, चित्र, वीडियो, दस्तावेज़, वॉइस नोट, या सरकारी ID भेजें — मैं इसे हेरफेर, डीपफेक और गलत सूचना के लिए विश्लेषण करूँगा।\n\nशुरू करने के लिए एक समाचार लेख का स्क्रीनशॉट भेजें! 🔍',
      'mr':
          '👋 KavachVerify मध्ये स्वागत आहे!\n\nमला कोणताही मजकूर दावा, चित्र, व्हिडिओ, दस्तऐवज, व्हॉइस नोट किंवा शासकीय ID पाठवा — मी ते हेरफेर, डीपफेक आणि चुकीच्या माहितीसाठी विश्लेषण करेन.\n\nसुरू करण्यासाठी एखाद्या बातमीचा स्क्रीनशॉट पाठवा! 🔍',
    },

    // ─── Profile Screen ───
    'account': {'en': 'Account', 'hi': 'खाता', 'mr': 'खाते'},
    'username': {
      'en': 'Username',
      'hi': 'उपयोगकर्ता नाम',
      'mr': 'वापरकर्ता नाव',
    },
    'email': {'en': 'Email', 'hi': 'ईमेल', 'mr': 'ईमेल'},
    'phone': {'en': 'Phone', 'hi': 'फ़ोन', 'mr': 'फोन'},
    'member_since': {
      'en': 'Member Since',
      'hi': 'सदस्य बने',
      'mr': 'सदस्य झाले',
    },
    'edit_profile': {
      'en': 'Edit Profile',
      'hi': 'प्रोफ़ाइल संपादित करें',
      'mr': 'प्रोफाइल संपादित करा',
    },
    'verified': {'en': 'Verified', 'hi': 'सत्यापित', 'mr': 'पडताळलेले'},
    'rank': {'en': 'Rank', 'hi': 'रैंक', 'mr': 'रँक'},
    'top_5_community': {
      'en': 'Top 5% of community verifiers',
      'hi': 'शीर्ष 5% समुदाय सत्यापनकर्ता',
      'mr': 'शीर्ष 5% समुदाय पडताळणीकर्ते',
    },
    'recent_activity': {
      'en': 'Recent Activity',
      'hi': 'हालिया गतिविधि',
      'mr': 'अलीकडील क्रियाकलाप',
    },
    'settings': {'en': 'Settings', 'hi': 'सेटिंग्स', 'mr': 'सेटिंग्ज'},
    'dark_mode': {'en': 'Dark Mode', 'hi': 'डार्क मोड', 'mr': 'डार्क मोड'},
    'notifications': {'en': 'Notifications', 'hi': 'सूचनाएँ', 'mr': 'सूचना'},
    'notifications_enabled': {
      'en': 'Notifications enabled',
      'hi': 'सूचनाएँ चालू',
      'mr': 'सूचना चालू',
    },
    'notifications_disabled': {
      'en': 'Notifications disabled',
      'hi': 'सूचनाएँ बंद',
      'mr': 'सूचना बंद',
    },
    'language': {'en': 'Language', 'hi': 'भाषा', 'mr': 'भाषा'},
    'privacy_security': {
      'en': 'Privacy & Security',
      'hi': 'गोपनीयता और सुरक्षा',
      'mr': 'गोपनीयता आणि सुरक्षा',
    },
    'support': {'en': 'Support', 'hi': 'सहायता', 'mr': 'मदत'},
    'app_feedback': {
      'en': 'App Feedback',
      'hi': 'ऐप प्रतिक्रिया',
      'mr': 'अ‍ॅप अभिप्राय',
    },
    'help_faq': {
      'en': 'Help & FAQ',
      'hi': 'सहायता और FAQ',
      'mr': 'मदत आणि FAQ',
    },
    'about_app': {
      'en': 'About KavachVerify',
      'hi': 'KavachVerify के बारे में',
      'mr': 'KavachVerify बद्दल',
    },
    'log_out': {'en': 'Log Out', 'hi': 'लॉग आउट', 'mr': 'लॉग आउट'},
    'profile_photo': {
      'en': 'Profile Photo',
      'hi': 'प्रोफ़ाइल फ़ोटो',
      'mr': 'प्रोफाइल फोटो',
    },
    'take_photo': {'en': 'Take Photo', 'hi': 'फ़ोटो लें', 'mr': 'फोटो काढा'},
    'choose_gallery': {
      'en': 'Choose from Gallery',
      'hi': 'गैलरी से चुनें',
      'mr': 'गॅलरीतून निवडा',
    },
    'remove_photo': {
      'en': 'Remove Photo',
      'hi': 'फ़ोटो हटाएं',
      'mr': 'फोटो काढा',
    },
    'photo_updated': {
      'en': 'Profile photo updated! 📸',
      'hi': 'प्रोफ़ाइल फ़ोटो अपडेट हो गई! 📸',
      'mr': 'प्रोफाइल फोटो अपडेट झाला! 📸',
    },
    'photo_removed': {
      'en': 'Profile photo removed',
      'hi': 'प्रोफ़ाइल फ़ोटो हटा दी गई',
      'mr': 'प्रोफाइल फोटो काढला',
    },
    'full_name': {'en': 'Full Name', 'hi': 'पूरा नाम', 'mr': 'पूर्ण नाव'},
    'enter_full_name': {
      'en': 'Enter full name',
      'hi': 'पूरा नाम दर्ज करें',
      'mr': 'पूर्ण नाव प्रविष्ट करा',
    },
    'email_address': {
      'en': 'Email Address',
      'hi': 'ईमेल पता',
      'mr': 'ईमेल पत्ता',
    },
    'enter_email': {
      'en': 'Enter email',
      'hi': 'ईमेल दर्ज करें',
      'mr': 'ईमेल प्रविष्ट करा',
    },
    'phone_number': {'en': 'Phone Number', 'hi': 'फ़ोन नंबर', 'mr': 'फोन नंबर'},
    'phone_10_digit': {
      'en': '10-digit number',
      'hi': '10 अंकों का नंबर',
      'mr': '10 अंकी क्रमांक',
    },
    'bio': {'en': 'Bio', 'hi': 'बायो', 'mr': 'बायो'},
    'write_short_bio': {
      'en': 'Write a short bio',
      'hi': 'एक छोटा बायो लिखें',
      'mr': 'एक लहान बायो लिहा',
    },
    'cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'mr': 'रद्द करा'},
    'save_changes': {
      'en': 'Save Changes',
      'hi': 'बदलाव सहेजें',
      'mr': 'बदल जतन करा',
    },
    'profile_updated': {
      'en': 'Profile updated! ✨',
      'hi': 'प्रोफ़ाइल अपडेट हो गई! ✨',
      'mr': 'प्रोफाइल अपडेट झाली! ✨',
    },
    'phone_10_digits_error': {
      'en': 'Phone number must be 10 digits',
      'hi': 'फ़ोन नंबर 10 अंकों का होना चाहिए',
      'mr': 'फोन नंबर 10 अंकी असणे आवश्यक आहे',
    },
    'select_language': {
      'en': 'Select Language',
      'hi': 'भाषा चुनें',
      'mr': 'भाषा निवडा',
    },
    'apply': {'en': 'Apply', 'hi': 'लागू करें', 'mr': 'लागू करा'},
    'confirm_logout': {
      'en': 'Confirm Logout',
      'hi': 'लॉग आउट की पुष्टि करें',
      'mr': 'लॉग आउट पुष्टी करा',
    },
    'logout_confirm_msg': {
      'en': 'Are you sure you want to log out?',
      'hi': 'क्या आप लॉग आउट करना चाहते हैं?',
      'mr': 'तुम्हाला लॉग आउट करायचे आहे का?',
    },

    // ─── Profile Activity Items ───
    'verified_image': {
      'en': 'Verified an image',
      'hi': 'एक चित्र सत्यापित किया',
      'mr': 'एक चित्र पडताळले',
    },
    'detected_manipulated': {
      'en': 'Detected as Manipulated',
      'hi': 'हेरफेर के रूप में पहचाना',
      'mr': 'हेरफेर म्हणून ओळखले',
    },
    'analyzed_document': {
      'en': 'Analyzed a document',
      'hi': 'एक दस्तावेज़ का विश्लेषण किया',
      'mr': 'एक दस्तऐवजाचे विश्लेषण केले',
    },
    'authentic': {'en': 'Authentic', 'hi': 'प्रामाणिक', 'mr': 'प्रामाणिक'},
    'verified_video': {
      'en': 'Verified a video',
      'hi': 'एक वीडियो सत्यापित किया',
      'mr': 'एक व्हिडिओ पडताळला',
    },
    'deepfake_detected': {
      'en': 'Deepfake Detected',
      'hi': 'डीपफेक पहचाना गया',
      'mr': 'डीपफेक ओळखला',
    },
    'checked_gov_id': {
      'en': 'Checked Gov ID',
      'hi': 'सरकारी ID जाँची',
      'mr': 'शासकीय ID तपासली',
    },
    'verified_authentic': {
      'en': 'Verified Authentic',
      'hi': 'प्रामाणिक सत्यापित',
      'mr': 'प्रामाणिक पडताळले',
    },
    'reported_fake': {
      'en': 'Reported fake content',
      'hi': 'फर्जी सामग्री रिपोर्ट की',
      'mr': 'बनावट सामग्री रिपोर्ट केली',
    },
    'report_submitted': {
      'en': 'Report Submitted',
      'hi': 'रिपोर्ट सबमिट हो गई',
      'mr': 'रिपोर्ट सबमिट झाली',
    },
    'analyzed_voice': {
      'en': 'Analyzed voice message',
      'hi': 'वॉइस मैसेज का विश्लेषण किया',
      'mr': 'व्हॉइस मेसेजचे विश्लेषण केले',
    },
    'ai_generated_voice': {
      'en': 'AI-Generated Voice',
      'hi': 'AI-जनित आवाज़',
      'mr': 'AI-जनित आवाज',
    },

    // ─── Community Screen ───
    'fact_checker': {
      'en': 'Fact Checker',
      'hi': 'तथ्य जाँचकर्ता',
      'mr': 'तथ्य तपासक',
    },
    'verifications': {'en': 'verifications', 'hi': 'सत्यापन', 'mr': 'पडताळणी'},
    'accuracy': {'en': 'accuracy', 'hi': 'सटीकता', 'mr': 'अचूकता'},
    'top_5_percent': {'en': 'Top 5%', 'hi': 'शीर्ष 5%', 'mr': 'शीर्ष 5%'},
    'text_checks': {
      'en': 'Text Checks',
      'hi': 'टेक्स्ट जाँच',
      'mr': 'मजकूर तपासणी',
    },
    'media_checks': {
      'en': 'Media Checks',
      'hi': 'मीडिया जाँच',
      'mr': 'मीडिया तपासणी',
    },
    'doc_checks': {
      'en': 'Doc Checks',
      'hi': 'दस्तावेज़ जाँच',
      'mr': 'दस्तऐवज तपासणी',
    },
    'safety_guidelines': {
      'en': 'Safety Guidelines',
      'hi': 'सुरक्षा दिशा-निर्देश',
      'mr': 'सुरक्षा मार्गदर्शक तत्त्वे',
    },
    'guideline_1_title': {
      'en': 'Verify Before Sharing',
      'hi': 'साझा करने से पहले सत्यापित करें',
      'mr': 'शेअर करण्यापूर्वी पडताळा',
    },
    'guideline_1_desc': {
      'en':
          'Always fact-check information through multiple credible sources before forwarding messages, posts, or news to others.',
      'hi':
          'संदेश, पोस्ट या समाचार दूसरों को भेजने से पहले हमेशा कई विश्वसनीय स्रोतों से तथ्य-जाँच करें।',
      'mr':
          'संदेश, पोस्ट किंवा बातम्या इतरांना पाठवण्यापूर्वी नेहमी अनेक विश्वसनीय स्रोतांमधून तथ्य-तपासणी करा.',
    },
    'guideline_2_title': {
      'en': 'Check URLs Carefully',
      'hi': 'URL ध्यान से जाँचें',
      'mr': 'URL काळजीपूर्वक तपासा',
    },
    'guideline_2_desc': {
      'en':
          'Look for misspellings in domain names, missing HTTPS, and unusual domain extensions. Hover over links before clicking.',
      'hi':
          'डोमेन नामों में गलत वर्तनी, HTTPS की कमी और असामान्य डोमेन एक्सटेंशन देखें। क्लिक करने से पहले लिंक पर होवर करें।',
      'mr':
          'डोमेन नावांमधील चुकीचे स्पेलिंग, HTTPS नसणे आणि असामान्य डोमेन एक्सटेंशन तपासा. क्लिक करण्यापूर्वी लिंकवर होवर करा.',
    },
    'guideline_3_title': {
      'en': 'Reverse Image Search',
      'hi': 'रिवर्स इमेज सर्च',
      'mr': 'रिव्हर्स इमेज सर्च',
    },
    'guideline_3_desc': {
      'en':
          'Use Google Reverse Image Search to check if photos have been manipulated or taken out of context from older events.',
      'hi':
          'Google रिवर्स इमेज सर्च का उपयोग करके जाँचें कि क्या तस्वीरें बदली गई हैं या पुरानी घटनाओं से संदर्भ से बाहर ली गई हैं।',
      'mr':
          'Google रिव्हर्स इमेज सर्च वापरून तपासा की फोटो बदलले गेले आहेत किंवा जुन्या घटनांमधून संदर्भाबाहेर घेतले गेले आहेत.',
    },
    'guideline_4_title': {
      'en': 'Be Wary of Audio Clips',
      'hi': 'ऑडियो क्लिप से सावधान रहें',
      'mr': 'ऑडिओ क्लिपबद्दल सावध रहा',
    },
    'guideline_4_desc': {
      'en':
          'AI-generated voice clones are increasingly realistic. Verify audio claims through official channels before believing them.',
      'hi':
          'AI-जनित आवाज़ क्लोन तेजी से यथार्थवादी हो रहे हैं। विश्वास करने से पहले आधिकारिक चैनलों के माध्यम से ऑडियो दावों को सत्यापित करें।',
      'mr':
          'AI-जनित आवाज क्लोन वाढत्या प्रमाणात वास्तववादी होत आहेत. विश्वास ठेवण्यापूर्वी अधिकृत चॅनेलद्वारे ऑडिओ दावे पडताळा.',
    },
    'guideline_5_title': {
      'en': 'Inspect Documents',
      'hi': 'दस्तावेज़ों की जाँच करें',
      'mr': 'दस्तऐवज तपासा',
    },
    'guideline_5_desc': {
      'en':
          'Check official documents for proper letterheads, file numbers, consistent fonts, and valid digital signatures.',
      'hi':
          'सही लेटरहेड, फ़ाइल नंबर, सुसंगत फ़ॉन्ट और वैध डिजिटल हस्ताक्षर के लिए आधिकारिक दस्तावेज़ जाँचें।',
      'mr':
          'योग्य लेटरहेड, फाइल नंबर, सुसंगत फॉन्ट आणि वैध डिजिटल स्वाक्षरीसाठी अधिकृत दस्तऐवज तपासा.',
    },
    'guideline_6_title': {
      'en': 'Spot Deepfake Videos',
      'hi': 'डीपफेक वीडियो पहचानें',
      'mr': 'डीपफेक व्हिडिओ ओळखा',
    },
    'guideline_6_desc': {
      'en':
          'Look for unnatural blinking, lip-sync issues, blurry edges around faces, and inconsistent lighting in video content.',
      'hi':
          'वीडियो में अप्राकृतिक पलक झपकना, लिप-सिंक समस्याएं, चेहरों के चारों ओर धुंधले किनारे और असंगत प्रकाश देखें।',
      'mr':
          'व्हिडिओमध्ये अनैसर्गिक डोळे मिचकावणे, लिप-सिंक समस्या, चेहऱ्यांभोवतील अस्पष्ट कडा आणि असंगत प्रकाश यांकडे लक्ष द्या.',
    },
    'guideline_7_title': {
      'en': 'Don\'t Spread Panic',
      'hi': 'घबराहट न फैलाएं',
      'mr': 'घबराट पसरवू नका',
    },
    'guideline_7_desc': {
      'en':
          'If content evokes extreme emotion (fear, anger, outrage), it\'s more likely to be designed to manipulate. Pause and verify.',
      'hi':
          'यदि सामग्री अत्यधिक भावना (भय, क्रोध, आक्रोश) पैदा करती है, तो इसे हेरफेर के लिए बनाया गया हो सकता है। रुकें और सत्यापित करें।',
      'mr':
          'जर सामग्री अत्यंत भावना (भीती, राग, संताप) निर्माण करत असेल तर ती हेरफेर करण्यासाठी बनवलेली असू शकते. थांबा आणि पडताळा.',
    },
    'guideline_8_title': {
      'en': 'Use KavachVerify',
      'hi': 'KavachVerify वापरा',
      'mr': 'KavachVerify वापरा',
    },
    'guideline_8_desc': {
      'en':
          'Submit any suspicious content to KavachVerify for AI-powered analysis. Be part of the solution against misinformation.',
      'hi':
          'AI-संचालित विश्लेषण के लिए किसी भी संदिग्ध सामग्री को KavachVerify में सबमिट करें। गलत सूचना के खिलाफ समाधान का हिस्सा बनें।',
      'mr':
          'AI-संचालित विश्लेषणासाठी कोणतीही संशयास्पद सामग्री KavachVerify मध्ये सबमिट करा. चुकीच्या माहितीविरुद्ध उपायाचा भाग व्हा.',
    },

    // ─── Report Screen ───
    'report_fake_title': {
      'en': 'Report Fake Content',
      'hi': 'फर्जी सामग्री रिपोर्ट करें',
      'mr': 'बनावट सामग्री रिपोर्ट करा',
    },
    'report_subtitle': {
      'en': 'Help us fight misinformation by reporting suspicious content',
      'hi':
          'संदिग्ध सामग्री रिपोर्ट करके गलत सूचना से लड़ने में हमारी मदद करें',
      'mr':
          'संशयास्पद सामग्री रिपोर्ट करून चुकीच्या माहितीविरुद्ध लढण्यात मदत करा',
    },
    'description': {'en': 'Description', 'hi': 'विवरण', 'mr': 'वर्णन'},
    'describe_fake_content': {
      'en': 'Describe the fake content you want to report...',
      'hi': 'आप जो फर्जी सामग्री रिपोर्ट करना चाहते हैं उसका विवरण दें...',
      'mr': 'तुम्हाला रिपोर्ट करायच्या बनावट सामग्रीचे वर्णन करा...',
    },
    'documentation': {
      'en': 'Documentation',
      'hi': 'दस्तावेज़ीकरण',
      'mr': 'दस्तऐवजीकरण',
    },
    'upload_docs_hint': {
      'en': 'Upload supporting documents (PDFs, Word docs, etc.)',
      'hi': 'सहायक दस्तावेज़ अपलोड करें (पीडीएफ, वर्ड डॉक्स, आदि)',
      'mr': 'सहाय्यक दस्तऐवज अपलोड करा (पीडीएफ, वर्ड डॉक्स, इ.)',
    },
    'upload_document': {
      'en': 'Upload Document',
      'hi': 'दस्तावेज़ अपलोड करें',
      'mr': 'दस्तऐवज अपलोड करा',
    },
    'proof': {'en': 'Proof', 'hi': 'सबूत', 'mr': 'पुरावा'},
    'upload_proof_hint': {
      'en': 'Upload images, videos, or documents as evidence',
      'hi': 'सबूत के रूप में चित्र, वीडियो या दस्तावेज़ अपलोड करें',
      'mr': 'पुरावा म्हणून चित्रे, व्हिडिओ किंवा दस्तऐवज अपलोड करा',
    },
    'add_proof': {'en': 'Add Proof', 'hi': 'सबूत जोड़ें', 'mr': 'पुरावा जोडा'},
    'submit_report': {
      'en': 'Submit Report',
      'hi': 'रिपोर्ट सबमिट करें',
      'mr': 'रिपोर्ट सबमिट करा',
    },
    'add_desc_or_proof': {
      'en': 'Please add a description or upload proof',
      'hi': 'कृपया विवरण जोड़ें या सबूत अपलोड करें',
      'mr': 'कृपया वर्णन जोडा किंवा पुरावा अपलोड करा',
    },
    'report_success': {
      'en': 'Report submitted successfully! 🛡️',
      'hi': 'रिपोर्ट सफलतापूर्वक सबमिट हो गई! 🛡️',
      'mr': 'रिपोर्ट यशस्वीरित्या सबमिट झाली! 🛡️',
    },
    'report_failed': {
      'en': 'Failed to submit report',
      'hi': 'रिपोर्ट सबमिट करने में विफल',
      'mr': 'रिपोर्ट सबमिट करण्यात अयशस्वी',
    },
    'image': {'en': 'Image', 'hi': 'चित्र', 'mr': 'चित्र'},

    // ─── WhatsApp Bot Screen ───
    'whatsapp_title': {
      'en': 'WhatsApp Bot',
      'hi': 'व्हाट्सएप बॉट',
      'mr': 'व्हॉट्सअ‍ॅप बॉट',
    },
    'whatsapp_subtitle': {
      'en': 'Verify content directly on WhatsApp',
      'hi': 'सीधे व्हाट्सएप पर सामग्री सत्यापित करें',
      'mr': 'थेट व्हॉट्सअ‍ॅपवर सामग्री पडताळा',
    },
    'scan_qr': {
      'en': 'Scan this QR code with your phone camera',
      'hi': 'अपने फ़ोन कैमरे से इस QR कोड को स्कैन करें',
      'mr': 'तुमच्या फोन कॅमेऱ्याने हा QR कोड स्कॅन करा',
    },
    'or_tap_button': {
      'en': 'Or tap the button below',
      'hi': 'या नीचे बटन दबाएं',
      'mr': 'किंवा खाली बटण दाबा',
    },
    'open_whatsapp': {
      'en': 'Open WhatsApp',
      'hi': 'व्हाट्सएप खोलें',
      'mr': 'व्हॉट्सअ‍ॅप उघडा',
    },
    'how_it_works': {
      'en': 'How It Works',
      'hi': 'यह कैसे काम करता है',
      'mr': 'हे कसे काम करते',
    },
    'step_1_text': {
      'en': 'Send "join typical-nest" to activate the bot',
      'hi': '"join typical-nest" भेजकर बॉट सक्रिय करें',
      'mr': '"join typical-nest" पाठवून बॉट सक्रिय करा',
    },
    'step_2_text': {
      'en': 'Send any image, text, or voice note',
      'hi': 'कोई भी चित्र, टेक्स्ट या वॉइस नोट भेजें',
      'mr': 'कोणतेही चित्र, मजकूर किंवा व्हॉइस नोट पाठवा',
    },
    'step_3_text': {
      'en': 'Receive instant AI-powered analysis',
      'hi': 'तुरंत AI-संचालित विश्लेषण प्राप्त करें',
      'mr': 'तात्काळ AI-संचालित विश्लेषण प्राप्त करा',
    },
    'capabilities': {'en': 'Capabilities', 'hi': 'क्षमताएं', 'mr': 'क्षमता'},
    'text_fact_check': {
      'en': 'Text Fact-Check',
      'hi': 'टेक्स्ट तथ्य-जाँच',
      'mr': 'मजकूर तथ्य-तपासणी',
    },
    'image_deepfake': {
      'en': 'Image Deepfake',
      'hi': 'चित्र डीपफेक',
      'mr': 'चित्र डीपफेक',
    },
    'voice_analysis': {
      'en': 'Voice Analysis',
      'hi': 'आवाज़ विश्लेषण',
      'mr': 'आवाज विश्लेषण',
    },
    'video_scan': {
      'en': 'Video Scan',
      'hi': 'वीडियो स्कैन',
      'mr': 'व्हिडिओ स्कॅन',
    },
    'id_forensics': {
      'en': 'ID Forensics',
      'hi': 'ID फॉरेंसिक',
      'mr': 'ID फॉरेन्सिक',
    },

    // ─── Library Screen ───
    'library_title': {
      'en': 'Detection Library',
      'hi': 'पहचान लाइब्रेरी',
      'mr': 'शोध लायब्ररी',
    },
    'library_subtitle': {
      'en': 'Browse all verification results',
      'hi': 'सभी सत्यापन परिणाम ब्राउज़ करें',
      'mr': 'सर्व पडताळणी निकाल ब्राउज करा',
    },
    'all': {'en': 'All', 'hi': 'सभी', 'mr': 'सर्व'},
    'fake': {'en': 'Fake', 'hi': 'नकली', 'mr': 'बनावट'},
    'real': {'en': 'Real', 'hi': 'असली', 'mr': 'खरे'},
    'no_results': {
      'en': 'No results found',
      'hi': 'कोई परिणाम नहीं मिला',
      'mr': 'कोणताही निकाल सापडला नाही',
    },
    'search_detections': {
      'en': 'Search detections...',
      'hi': 'पहचान खोजें...',
      'mr': 'शोध शोधा...',
    },
    'confidence': {
      'en': 'Confidence',
      'hi': 'विश्वसनीयता',
      'mr': 'विश्वासार्हता',
    },

    // ─── Login Screen ───
    'welcome_back': {
      'en': 'Welcome Back',
      'hi': 'वापसी पर स्वागत',
      'mr': 'पुन्हा স्वागत',
    },
    'sign_in_continue': {
      'en': 'Sign in to continue protecting truth',
      'hi': 'सत्य की रक्षा जारी रखने के लिए साइन इन करें',
      'mr': 'सत्याचे रक्षण सुरू ठेवण्यासाठी साइन इन करा',
    },
    'email_or_username': {
      'en': 'Email or Username',
      'hi': 'ईमेल या उपयोगकर्ता नाम',
      'mr': 'ईमेल किंवा वापरकर्ता नाव',
    },
    'password': {'en': 'Password', 'hi': 'पासवर्ड', 'mr': 'पासवर्ड'},
    'sign_in': {'en': 'Sign In', 'hi': 'साइन इन करें', 'mr': 'साइन इन करा'},
    'no_account': {
      'en': "Don't have an account?",
      'hi': 'खाता नहीं है?',
      'mr': 'खाते नाही?',
    },
    'create_one': {'en': 'Create one', 'hi': 'बनाएं', 'mr': 'तयार करा'},
    'demo_credentials': {
      'en': 'Demo Credentials',
      'hi': 'डेमो क्रेडेंशियल',
      'mr': 'डेमो क्रेडेंशियल',
    },

    // ─── Register Screen ───
    'create_account': {
      'en': 'Create Account',
      'hi': 'खाता बनाएं',
      'mr': 'खाते तयार करा',
    },
    'join_shield': {
      'en': 'Join the truth shield network',
      'hi': 'सत्य कवच नेटवर्क में शामिल हों',
      'mr': 'सत्य कवच नेटवर्कमध्ये सामील व्हा',
    },
    'choose_username': {
      'en': 'Choose a username',
      'hi': 'उपयोगकर्ता नाम चुनें',
      'mr': 'वापरकर्ता नाव निवडा',
    },
    'confirm_password': {
      'en': 'Confirm Password',
      'hi': 'पासवर्ड की पुष्टि करें',
      'mr': 'पासवर्ड पुष्टी करा',
    },
    'create_account_btn': {
      'en': 'Create Account',
      'hi': 'खाता बनाएं',
      'mr': 'खाते तयार करा',
    },
    'already_have_account': {
      'en': 'Already have an account?',
      'hi': 'पहले से खाता है?',
      'mr': 'आधीच खाते आहे?',
    },
    'sign_in_link': {
      'en': 'Sign in',
      'hi': 'साइन इन करें',
      'mr': 'साइन इन करा',
    },

    // ─── Feedback Dialog ───
    'send_feedback': {
      'en': 'Send Feedback',
      'hi': 'प्रतिक्रिया भेजें',
      'mr': 'अभिप्राय पाठवा',
    },
    'rate_experience': {
      'en': 'Rate your experience',
      'hi': 'अपने अनुभव को रेट करें',
      'mr': 'तुमच्या अनुभवाला रेट करा',
    },
    'feedback_placeholder': {
      'en': 'Tell us what you think...',
      'hi': 'हमें बताएं आप क्या सोचते हैं...',
      'mr': 'तुम्हाला काय वाटते ते सांगा...',
    },
    'submit': {'en': 'Submit', 'hi': 'सबमिट करें', 'mr': 'सबमिट करा'},
    'feedback_success': {
      'en': 'Thanks for your feedback! 🙏',
      'hi': 'आपकी प्रतिक्रिया के लिए धन्यवाद! 🙏',
      'mr': 'तुमच्या अभिप्रायाबद्दल धन्यवाद! 🙏',
    },
    'feedback_failed': {
      'en': 'Could not submit feedback',
      'hi': 'प्रतिक्रिया सबमिट नहीं हो सकी',
      'mr': 'अभिप्राय सबमिट करता आला नाही',
    },

    // ─── Time Ago ───
    'm_ago': {'en': 'm ago', 'hi': 'मिनट पहले', 'mr': 'मिनिटांपूर्वी'},
    'h_ago': {'en': 'h ago', 'hi': 'घंटे पहले', 'mr': 'तासांपूर्वी'},
    'd_ago': {'en': 'd ago', 'hi': 'दिन पहले', 'mr': 'दिवसांपूर्वी'},
    'hours_ago': {'en': 'hours ago', 'hi': 'घंटे पहले', 'mr': 'तासांपूर्वी'},

    // ─── Privacy / Help / About (section titles) ───
    'privacy_title': {
      'en': 'Privacy & Security',
      'hi': 'गोपनीयता और सुरक्षा',
      'mr': 'गोपनीयता आणि सुरक्षा',
    },
    'help_title': {
      'en': 'Help & FAQ',
      'hi': 'सहायता और FAQ',
      'mr': 'मदत आणि FAQ',
    },

    // ─── Chat Screen (remaining) ───
    'image_video_title': {
      'en': 'Image / Video',
      'hi': 'चित्र / वीडियो',
      'mr': 'चित्र / व्हिडिओ',
    },
    'recording_indicator': {
      'en': 'Recording...',
      'hi': 'रिकॉर्डिंग...',
      'mr': 'रेकॉर्डिंग...',
    },
    'cannot_start_recording': {
      'en': 'Cannot start recording',
      'hi': 'रिकॉर्डिंग शुरू नहीं हो सकती',
      'mr': 'रेकॉर्डिंग सुरू होत नाही',
    },
    'download_failed': {
      'en': 'Download failed',
      'hi': 'डाउनलोड विफल',
      'mr': 'डाउनलोड अयशस्वी',
    },
    'image_preview': {
      'en': 'Image Preview',
      'hi': 'चित्र पूर्वावलोकन',
      'mr': 'चित्र पूर्वावलोकन',
    },
    'video_preview': {
      'en': 'Video Preview',
      'hi': 'वीडियो पूर्वावलोकन',
      'mr': 'व्हिडिओ पूर्वावलोकन',
    },
    'doc_received': {
      'en': 'Document received for analysis',
      'hi': 'विश्लेषण के लिए दस्तावेज़ प्राप्त',
      'mr': 'विश्लेषणासाठी दस्तऐवज प्राप्त',
    },
    'cannot_open_doc': {
      'en': 'Cannot open document',
      'hi': 'दस्तावेज़ नहीं खोल सकते',
      'mr': 'दस्तऐवज उघडता येत नाही',
    },
    'no_recording_play': {
      'en': 'No recording to play',
      'hi': 'चलाने के लिए कोई रिकॉर्डिंग नहीं',
      'mr': 'प्ले करण्यासाठी रेकॉर्डिंग नाही',
    },
    'playback_error': {
      'en': 'Playback error',
      'hi': 'प्लेबैक त्रुटि',
      'mr': 'प्लेबॅक त्रुटी',
    },

    // ─── WhatsApp Bot Feature Tiles ───
    'feature_verify_media': {
      'en': 'Verify Images & Videos',
      'hi': 'चित्र और वीडियो सत्यापित करें',
      'mr': 'चित्रे आणि व्हिडिओ पडताळा',
    },
    'feature_verify_media_sub': {
      'en': 'Send media to detect deepfakes & manipulations',
      'hi': 'डीपफेक और हेरफेर पहचानने के लिए मीडिया भेजें',
      'mr': 'डीपफेक आणि हेरफेर शोधण्यासाठी मीडिया पाठवा',
    },
    'feature_analyze_docs': {
      'en': 'Analyze Documents',
      'hi': 'दस्तावेज़ों का विश्लेषण करें',
      'mr': 'दस्तऐवजांचे विश्लेषण करा',
    },
    'feature_analyze_docs_sub': {
      'en': 'Forward PDFs & docs for authenticity checks',
      'hi': 'प्रामाणिकता जाँच के लिए पीडीएफ और दस्तावेज़ भेजें',
      'mr': 'प्रामाणिकता तपासणीसाठी पीडीएफ आणि दस्तऐवज फॉरवर्ड करा',
    },
    'feature_audio': {
      'en': 'Audio Analysis',
      'hi': 'ऑडियो विश्लेषण',
      'mr': 'ऑडिओ विश्लेषण',
    },
    'feature_audio_sub': {
      'en': 'Send voice notes to detect AI-generated speech',
      'hi': 'AI-जनित भाषण पहचानने के लिए वॉइस नोट भेजें',
      'mr': 'AI-जनित भाषण शोधण्यासाठी व्हॉइस नोट पाठवा',
    },
    'feature_instant': {
      'en': 'Instant Results',
      'hi': 'तुरंत परिणाम',
      'mr': 'तात्काळ निकाल',
    },
    'feature_instant_sub': {
      'en': 'Get a detailed verification report in seconds',
      'hi': 'सेकंडों में विस्तृत सत्यापन रिपोर्ट प्राप्त करें',
      'mr': 'सेकंदात तपशीलवार पडताळणी अहवाल मिळवा',
    },

    // ─── Library Detail Screen ───
    'detection_not_found': {
      'en': 'Detection not found',
      'hi': 'पहचान नहीं मिली',
      'mr': 'शोध सापडला नाही',
    },
    'back_to_library': {
      'en': 'Back to Library',
      'hi': 'लाइब्रेरी पर वापस',
      'mr': 'लायब्ररीकडे परत',
    },
    'fake_content_badge': {
      'en': '⚠ FAKE CONTENT',
      'hi': '⚠ फर्जी सामग्री',
      'mr': '⚠ बनावट सामग्री',
    },
    'confidence_pct': {
      'en': 'confidence',
      'hi': 'विश्वसनीयता',
      'mr': 'विश्वासार्हता',
    },
    'why_fake_title': {
      'en': "Why It's Fake — AI Analysis",
      'hi': 'यह नकली क्यों है — AI विश्लेषण',
      'mr': 'हे बनावट का आहे — AI विश्लेषण',
    },
    'comments_feedback': {
      'en': 'Comments & Feedback',
      'hi': 'टिप्पणियाँ और प्रतिक्रिया',
      'mr': 'टिप्पण्या आणि अभिप्राय',
    },
    'add_comment': {
      'en': 'Add a comment...',
      'hi': 'टिप्पणी जोड़ें...',
      'mr': 'टिप्पणी जोडा...',
    },
    'you': {'en': 'You', 'hi': 'आप', 'mr': 'तुम्ही'},
    'just_now': {'en': 'Just now', 'hi': 'अभी', 'mr': 'आत्ताच'},

    // ─── Profile Dialogs (remaining) ───
    'tell_us_improve': {
      'en': 'Tell us how we can improve...',
      'hi': 'हमें बताएं हम कैसे सुधार कर सकते हैं...',
      'mr': 'आम्ही कसे सुधारू शकतो ते सांगा...',
    },
    'feedback_submitted': {
      'en': 'Feedback submitted! Thank you 💚',
      'hi': 'प्रतिक्रिया सबमिट! धन्यवाद 💚',
      'mr': 'अभिप्राय सबमिट! धन्यवाद 💚',
    },
    'close': {'en': 'Close', 'hi': 'बंद करें', 'mr': 'बंद करा'},

    // ─── Profile FAQ ───
    'faq_1_q': {
      'en': 'How does KavachVerify detect fake content?',
      'hi': 'KavachVerify फर्जी सामग्री कैसे पहचानता है?',
      'mr': 'KavachVerify बनावट सामग्री कशी ओळखते?',
    },
    'faq_1_a': {
      'en':
          'KavachVerify uses advanced AI models to analyze images, videos, documents, and voice recordings for signs of manipulation, deepfakes, and AI-generated content.',
      'hi':
          'KavachVerify उन्नत AI मॉडल का उपयोग करके चित्रों, वीडियो, दस्तावेज़ों और वॉइस रिकॉर्डिंग में हेरफेर, डीपफेक और AI-जनित सामग्री के संकेतों का विश्लेषण करता है।',
      'mr':
          'KavachVerify प्रगत AI मॉडेल वापरून चित्रे, व्हिडिओ, दस्तऐवज आणि व्हॉइस रेकॉर्डिंगमध्ये हेरफेर, डीपफेक आणि AI-जनित सामग्रीच्या चिन्हांचे विश्लेषण करते.',
    },
    'faq_2_q': {
      'en': 'What file types are supported?',
      'hi': 'कौन से फाइल प्रकार समर्थित हैं?',
      'mr': 'कोणत्या फाइल प्रकार समर्थित आहेत?',
    },
    'faq_2_a': {
      'en':
          'We support images (JPG, PNG), videos (MP4, MOV), documents (PDF, DOC, DOCX, TXT), and voice recordings.',
      'hi':
          'हम चित्र (JPG, PNG), वीडियो (MP4, MOV), दस्तावेज़ (PDF, DOC, DOCX, TXT), और वॉइस रिकॉर्डिंग का समर्थन करते हैं।',
      'mr':
          'आम्ही चित्रे (JPG, PNG), व्हिडिओ (MP4, MOV), दस्तऐवज (PDF, DOC, DOCX, TXT), आणि व्हॉइस रेकॉर्डिंग समर्थित करतो.',
    },
    'faq_3_q': {
      'en': 'How accurate is the detection?',
      'hi': 'पहचान कितनी सटीक है?',
      'mr': 'शोध किती अचूक आहे?',
    },
    'faq_3_a': {
      'en':
          'Our AI models achieve over 95% accuracy on known manipulation techniques. Accuracy may vary for novel manipulation methods.',
      'hi':
          'हमारे AI मॉडल ज्ञात हेरफेर तकनीकों पर 95% से अधिक सटीकता प्राप्त करते हैं। नई हेरफेर विधियों के लिए सटीकता भिन्न हो सकती है।',
      'mr':
          'आमचे AI मॉडेल ज्ञात हेरफेर तंत्रांवर 95% पेक्षा जास्त अचूकता प्राप्त करतात. नवीन हेरफेर पद्धतींसाठी अचूकता भिन्न असू शकते.',
    },
    'faq_4_q': {
      'en': 'Is my data private?',
      'hi': 'क्या मेरा डेटा निजी है?',
      'mr': 'माझा डेटा खाजगी आहे का?',
    },
    'faq_4_a': {
      'en':
          'Yes. All uploaded content is encrypted and processed securely. We do not store or share your data with third parties.',
      'hi':
          'हाँ। सभी अपलोड की गई सामग्री एन्क्रिप्टेड और सुरक्षित रूप से प्रोसेस की जाती है। हम आपका डेटा तीसरे पक्षों के साथ संग्रहीत या साझा नहीं करते।',
      'mr':
          'होय. सर्व अपलोड केलेली सामग्री एन्क्रिप्टेड आणि सुरक्षितपणे प्रक्रिया केली जाते. आम्ही तुमचा डेटा तृतीय पक्षांसह संग्रहित किंवा शेअर करत नाही.',
    },
    'faq_5_q': {
      'en': 'How does the WhatsApp bot work?',
      'hi': 'WhatsApp बॉट कैसे काम करता है?',
      'mr': 'WhatsApp बॉट कसे काम करते?',
    },
    'faq_5_a': {
      'en':
          'Send any suspicious content to our WhatsApp bot and receive instant AI-powered analysis. Send "join typical-nest" to get started.',
      'hi':
          'कोई भी संदिग्ध सामग्री हमारे WhatsApp बॉट को भेजें और तुरंत AI-संचालित विश्लेषण प्राप्त करें। शुरू करने के लिए "join typical-nest" भेजें।',
      'mr':
          'कोणतीही संशयास्पद सामग्री आमच्या WhatsApp बॉटला पाठवा आणि तात्काळ AI-संचालित विश्लेषण मिळवा. सुरू करण्यासाठी "join typical-nest" पाठवा.',
    },

    // ─── About Dialog ───
    'about_version': {
      'en': 'Version 1.0.0',
      'hi': 'संस्करण 1.0.0',
      'mr': 'आवृत्ती 1.0.0',
    },
    'about_desc': {
      'en':
          'KavachVerify is an AI-powered platform that helps you detect fake content, deepfakes, and misinformation across text, images, videos, documents, and voice recordings.',
      'hi':
          'KavachVerify एक AI-संचालित प्लेटफॉर्म है जो आपको टेक्स्ट, चित्रों, वीडियो, दस्तावेज़ों और वॉइस रिकॉर्डिंग में नकली सामग्री, डीपफेक और गलत सूचना का पता लगाने में मदद करता है।',
      'mr':
          'KavachVerify हा एक AI-संचालित प्लॅटफॉर्म आहे जो तुम्हाला मजकूर, चित्रे, व्हिडिओ, दस्तऐवज आणि व्हॉइस रेकॉर्डिंगमधील बनावट सामग्री, डीपफेक आणि चुकीची माहिती शोधण्यात मदत करतो.',
    },
    'built_with': {
      'en': 'Built with ❤️ by the KavachVerify Team',
      'hi': 'KavachVerify टीम द्वारा ❤️ से बनाया गया',
      'mr': 'KavachVerify टीमने ❤️ ने बनवले',
    },

    // ─── Profile Extra ───
    'joined_date': {
      'en': 'February 2026',
      'hi': 'फरवरी 2026',
      'mr': 'फेब्रुवारी 2026',
    },
    'default_bio': {
      'en': 'Digital truth seeker • Fighting misinformation',
      'hi': 'डिजिटल सत्य अन्वेषक • गलत सूचना से लड़ाई',
      'mr': 'डिजिटल सत्य शोधक • चुकीच्या माहितीशी लढा',
    },
    'user_label': {'en': 'User', 'hi': 'उपयोगकर्ता', 'mr': 'वापरकर्ता'},

    // ─── Library Card Content ───
    'cat_text': {'en': 'Text', 'hi': 'टेक्स्ट', 'mr': 'मजकूर'},
    'cat_image': {'en': 'Image', 'hi': 'चित्र', 'mr': 'चित्र'},
    'cat_video': {'en': 'Video', 'hi': 'वीडियो', 'mr': 'व्हिडिओ'},
    'cat_voice': {'en': 'Voice', 'hi': 'आवाज़', 'mr': 'आवाज'},
    'cat_document': {'en': 'Document', 'hi': 'दस्तावेज़', 'mr': 'दस्तऐवज'},
    'cat_link': {'en': 'Link', 'hi': 'लिंक', 'mr': 'लिंक'},
    'time_m_ago': {'en': 'm ago', 'hi': 'मिनट पहले', 'mr': 'मिनिटांपूर्वी'},
    'time_h_ago': {'en': 'h ago', 'hi': 'घंटे पहले', 'mr': 'तासांपूर्वी'},
    'time_d_ago': {'en': 'd ago', 'hi': 'दिन पहले', 'mr': 'दिवसांपूर्वी'},
    'time_w_ago': {'en': 'w ago', 'hi': 'सप्ताह पहले', 'mr': 'आठवड्यांपूर्वी'},
    'results_found': {
      'en': 'results found',
      'hi': 'परिणाम मिले',
      'mr': 'निकाल सापडले',
    },
    'result_found': {
      'en': 'result found',
      'hi': 'परिणाम मिला',
      'mr': 'निकाल सापडला',
    },
    'no_results_for': {
      'en': 'No results for',
      'hi': 'कोई परिणाम नहीं',
      'mr': 'कोणताही निकाल नाही',
    },

    // ─── Profile Activity Time Labels ───
    'time_2h_ago': {
      'en': '2 hours ago',
      'hi': '2 घंटे पहले',
      'mr': '2 तासांपूर्वी',
    },
    'time_5h_ago': {
      'en': '5 hours ago',
      'hi': '5 घंटे पहले',
      'mr': '5 तासांपूर्वी',
    },
    'time_2d_ago': {
      'en': '2 days ago',
      'hi': '2 दिन पहले',
      'mr': '2 दिवसांपूर्वी',
    },
    'time_3d_ago': {
      'en': '3 days ago',
      'hi': '3 दिन पहले',
      'mr': '3 दिवसांपूर्वी',
    },

    // ─── Detection Content Translations ───
    'fake_badge': {'en': '⚠ FAKE', 'hi': '⚠ नकली', 'mr': '⚠ बनावट'},
    'verify_it': {'en': 'verify it', 'hi': 'सत्यापित करें', 'mr': 'पडताळा'},
    'voice_transcribed': {
      'en': 'Voice Transcribed:',
      'hi': 'ध्वनि प्रतिलेखित:',
      'mr': 'आवाज लिप्यंतरित:',
    },
    'cryptographic_failure': {
      'en': '*CRYPTOGRAPHIC FAILURE*',
      'hi': '*क्रिप्टोग्राफ़िक विफलता*',
      'mr': '*क्रिप्टोग्राफिक अपयश*',
    },
  };

  // ─── Content translation map for API-returned strings ───
  static const Map<String, Map<String, String>> _contentMap = {
    'verify it': {'hi': 'सत्यापित करें', 'mr': 'पडताळा'},
    'Media Verification': {'hi': 'मीडिया सत्यापन', 'mr': 'मीडिया पडताळणी'},
    'Voice Transcribed:': {'hi': 'ध्वनि प्रतिलेखित:', 'mr': 'आवाज लिप्यंतरित:'},
    '*CRYPTOGRAPHIC FAILURE*': {
      'hi': '*क्रिप्टोग्राफ़िक विफलता*',
      'mr': '*क्रिप्टोग्राफिक अपयश*',
    },
    'The Aadhaar number': {'hi': 'आधार नंबर', 'mr': 'आधार क्रमांक'},
    'failed the UIDAI Verhoeff Checksum': {
      'hi': 'UIDAI वेरहॉफ चेकसम में विफल',
      'mr': 'UIDAI वेरहॉफ चेकसम मध्ये अयशस्वी',
    },
    'This is a mathematically invalid number': {
      'hi': 'यह गणितीय रूप से अमान्य संख्या है',
      'mr': 'हा गणितीयदृष्ट्या अवैध क्रमांक आहे',
    },
    'The PAN number': {'hi': 'पैन नंबर', 'mr': 'पॅन क्रमांक'},
    'is algorithmically invalid': {
      'hi': 'एल्गोरिथम के अनुसार अमान्य है',
      'mr': 'अल्गोरिदमनुसार अवैध आहे',
    },
    'The 4th character must be': {
      'hi': 'चौथा अक्षर होना चाहिए',
      'mr': 'चौथे अक्षर असणे आवश्यक आहे',
    },
    'for a citizen': {'hi': 'नागरिक के लिए', 'mr': 'नागरिकासाठी'},
    'This is': {'hi': 'यह है', 'mr': 'हे आहे'},

    // ─── Detection #1 ───
    'Viral WhatsApp Forward About Free Gov Scheme': {
      'hi': 'मुफ्त सरकारी योजना के बारे में वायरल व्हाट्सएप फॉरवर्ड',
      'mr': 'मोफत सरकारी योजनेबद्दल व्हायरल व्हॉट्सअ‍ॅप फॉरवर्ड',
    },
    'A message claiming the government is distributing free laptops to all students has been circulating on WhatsApp. Our AI analysis found no official source.': {
      'hi':
          'सभी छात्रों को मुफ्त लैपटॉप बांटने का दावा करने वाला एक संदेश व्हाट्सएप पर फैल रहा है। हमारे AI विश्लेषण में कोई आधिकारिक स्रोत नहीं मिला।',
      'mr':
          'सर्व विद्यार्थ्यांना मोफत लॅपटॉप वाटत असल्याचा दावा करणारा संदेश व्हॉट्सअ‍ॅपवर फिरत आहे. आमच्या AI विश्लेषणात कोणताही अधिकृत स्रोत सापडला नाही.',
    },
    'No official government press release found matching this claim.': {
      'hi':
          'इस दावे से मेल खाती कोई आधिकारिक सरकारी प्रेस विज्ञप्ति नहीं मिली।',
      'mr':
          'या दाव्याशी जुळणारी कोणतीही अधिकृत सरकारी प्रेस रिलीज सापडली नाही.',
    },
    'The registration link redirects to a phishing site.': {
      'hi': 'पंजीकरण लिंक एक फ़िशिंग साइट पर रीडायरेक्ट करती है।',
      'mr': 'नोंदणी लिंक फिशिंग साइटवर रीडायरेक्ट करते.',
    },
    'Similar messages have been debunked by PIB Fact Check.': {
      'hi': 'PIB फैक्ट चेक द्वारा इसी तरह के संदेशों का खंडन किया गया है।',
      'mr': 'PIB फॅक्ट चेकने अशाच प्रकारच्या संदेशांचे खंडन केले आहे.',
    },
    'The formatting and language pattern matches known spam templates.': {
      'hi': 'फॉर्मेटिंग और भाषा पैटर्न ज्ञात स्पैम टेम्पलेट्स से मेल खाते हैं।',
      'mr': 'फॉरमॅटिंग आणि भाषा पॅटर्न ज्ञात स्पॅम टेम्पलेट्सशी जुळतात.',
    },

    // ─── Detection #2 ───
    'Manipulated Image of Celebrity Endorsement': {
      'hi': 'सेलिब्रिटी एंडोर्समेंट की हेरफेर की गई तस्वीर',
      'mr': 'सेलिब्रिटी एंडोर्समेंटचे हेरफेर केलेले चित्र',
    },
    'A doctored image showing a celebrity endorsing a cryptocurrency investment scheme has been shared widely on social media.': {
      'hi':
          'एक सेलिब्रिटी द्वारा क्रिप्टोकरेंसी निवेश योजना का समर्थन दिखाने वाली एक छेड़छाड़ की गई तस्वीर सोशल मीडिया पर व्यापक रूप से साझा की गई है।',
      'mr':
          'एका सेलिब्रिटीने क्रिप्टोकरन्सी गुंतवणूक योजनेला पाठिंबा दिल्याचे दाखवणारे एक बनावट चित्र सोशल मीडियावर मोठ्या प्रमाणावर शेअर केले गेले आहे.',
    },
    'Error Level Analysis reveals inconsistent compression artifacts.': {
      'hi': 'एरर लेवल एनालिसिस असंगत कंप्रेशन आर्टिफैक्ट्स दर्शाता है।',
      'mr': 'एरर लेव्हल अ‍ॅनालिसिस असंगत कंप्रेशन आर्टिफॅक्ट्स दर्शवते.',
    },
    'The celebrity\'s management has denied any such endorsement.': {
      'hi': 'सेलिब्रिटी के प्रबंधन ने ऐसे किसी भी समर्थन से इनकार किया है।',
      'mr':
          'सेलिब्रिटीच्या व्यवस्थापनाने अशा कोणत्याही समर्थनास नकार दिला आहे.',
    },
    'Reverse image search shows the original unedited photo.': {
      'hi': 'रिवर्स इमेज सर्च मूल असंपादित फ़ोटो दिखाता है।',
      'mr': 'रिव्हर्स इमेज सर्च मूळ असंपादित फोटो दर्शवते.',
    },
    'Font used in the text overlay does not match official branding.': {
      'hi':
          'टेक्स्ट ओवरले में उपयोग किया गया फ़ॉन्ट आधिकारिक ब्रांडिंग से मेल नहीं खाता।',
      'mr': 'टेक्स्ट ओव्हरलेमध्ये वापरलेला फॉन्ट अधिकृत ब्रँडिंगशी जुळत नाही.',
    },

    // ─── Detection #3 ───
    'Deepfake Audio of Political Leader': {
      'hi': 'राजनीतिक नेता का डीपफेक ऑडियो',
      'mr': 'राजकीय नेत्याचे डीपफेक ऑडिओ',
    },
    'An audio clip purporting to be a political leader making controversial statements has been flagged as AI-generated.': {
      'hi':
          'एक राजनीतिक नेता के विवादास्पद बयान देने का दावा करने वाली ऑडियो क्लिप को AI-जनित के रूप में चिह्नित किया गया है।',
      'mr':
          'एका राजकीय नेत्याने वादग्रस्त विधाने केल्याचा दावा करणारी ऑडिओ क्लिप AI-जनित म्हणून ध्वजांकित केली गेली आहे.',
    },
    'Spectral analysis shows unnatural frequency patterns.': {
      'hi': 'स्पेक्ट्रल विश्लेषण अप्राकृतिक आवृत्ति पैटर्न दिखाता है।',
      'mr': 'स्पेक्ट्रल विश्लेषण अनैसर्गिक फ्रिक्वेन्सी पॅटर्न दर्शवते.',
    },
    'Voice biometric comparison shows 34% deviation from genuine samples.': {
      'hi': 'वॉइस बायोमेट्रिक तुलना वास्तविक नमूनों से 34% विचलन दिखाती है।',
      'mr': 'व्हॉइस बायोमेट्रिक तुलना अस्सल नमुन्यांपासून 34% विचलन दर्शवते.',
    },
    'Background noise patterns are synthetically generated.': {
      'hi': 'पृष्ठभूमि शोर पैटर्न कृत्रिम रूप से उत्पन्न हैं।',
      'mr': 'पार्श्वभूमी ध्वनी पॅटर्न कृत्रिमरित्या तयार केले गेले आहेत.',
    },
    'No official record of any such speech or statement exists.': {
      'hi': 'ऐसे किसी भाषण या बयान का कोई आधिकारिक रिकॉर्ड मौजूद नहीं है।',
      'mr': 'अशा कोणत्याही भाषण किंवा विधानाची अधिकृत नोंद अस्तित्वात नाही.',
    },

    // ─── Detection #4 ───
    'Fake News Website Article on Health Cure': {
      'hi': 'स्वास्थ्य इलाज पर फर्जी समाचार वेबसाइट लेख',
      'mr': 'आरोग्य उपचाराबद्दल बनावट बातम्या वेबसाइट लेख',
    },
    'A fake news article claiming a miracle cure for diabetes has been shared over 50,000 times on social media.': {
      'hi':
          'मधुमेह के चमत्कारी इलाज का दावा करने वाला एक फर्जी समाचार लेख सोशल मीडिया पर 50,000 से अधिक बार साझा किया गया है।',
      'mr':
          'मधुमेहावर चमत्कारिक उपचाराचा दावा करणारा एक बनावट बातमी लेख सोशल मीडियावर 50,000 पेक्षा अधिक वेळा शेअर केला गेला आहे.',
    },
    'The website domain was registered just 3 days ago.': {
      'hi': 'वेबसाइट डोमेन सिर्फ 3 दिन पहले पंजीकृत किया गया था।',
      'mr': 'वेबसाइट डोमेन फक्त 3 दिवसांपूर्वी नोंदणीकृत केले गेले.',
    },
    'No medical studies support the claims made.': {
      'hi': 'किए गए दावों का समर्थन करने वाला कोई चिकित्सा अध्ययन नहीं है।',
      'mr': 'केलेल्या दाव्यांचे समर्थन करणारे कोणतेही वैद्यकीय अभ्यास नाहीत.',
    },
    'The "doctor" quoted does not exist in any medical registry.': {
      'hi': 'उद्धृत "डॉक्टर" किसी भी चिकित्सा रजिस्ट्री में मौजूद नहीं है।',
      'mr': 'उद्धृत "डॉक्टर" कोणत्याही वैद्यकीय नोंदणीमध्ये अस्तित्वात नाही.',
    },
    'The article uses common clickbait and fear-mongering patterns.': {
      'hi': 'लेख सामान्य क्लिकबेट और भय फैलाने के पैटर्न का उपयोग करता है।',
      'mr': 'लेख सामान्य क्लिकबेट आणि भयनिर्माण पॅटर्न वापरतो.',
    },

    // ─── Detection #5 ───
    'Altered Government Document Shared on Social Media': {
      'hi': 'सोशल मीडिया पर साझा किया गया बदला हुआ सरकारी दस्तावेज़',
      'mr': 'सोशल मीडियावर शेअर केलेला बदललेला सरकारी दस्तऐवज',
    },
    'A forged government notification about a new tax policy has been circulating across platforms.': {
      'hi':
          'एक नई कर नीति के बारे में एक जाली सरकारी अधिसूचना प्लेटफार्मों पर फैल रही है।',
      'mr':
          'नवीन कर धोरणाबद्दलची एक बनावट सरकारी अधिसूचना प्लॅटफॉर्मवर फिरत आहे.',
    },
    'The document header font does not match official templates.': {
      'hi': 'दस्तावेज़ हेडर फ़ॉन्ट आधिकारिक टेम्पलेट्स से मेल नहीं खाता।',
      'mr': 'दस्तऐवज हेडर फॉन्ट अधिकृत टेम्पलेट्सशी जुळत नाही.',
    },
    'The file number referenced does not exist in government records.': {
      'hi': 'संदर्भित फ़ाइल संख्या सरकारी रिकॉर्ड में मौजूद नहीं है।',
      'mr': 'संदर्भित फाइल क्रमांक सरकारी नोंदींमध्ये अस्तित्वात नाही.',
    },
    'Metadata analysis shows the PDF was created with a consumer editor.': {
      'hi':
          'मेटाडेटा विश्लेषण दिखाता है कि PDF एक उपभोक्ता संपादक से बनाया गया था।',
      'mr': 'मेटाडेटा विश्लेषण दर्शवते की PDF ग्राहक संपादकाने तयार केले गेले.',
    },
    'The seal and signature appear to be copied from another document.': {
      'hi':
          'मुहर और हस्ताक्षर किसी अन्य दस्तावेज़ से कॉपी किए गए प्रतीत होते हैं।',
      'mr': 'शिक्का आणि स्वाक्षरी दुसऱ्या दस्तऐवजावरून कॉपी केल्याचे दिसते.',
    },

    // ─── Detection #6 ───
    'Deepfake Video of Business Leader': {
      'hi': 'व्यापारिक नेता का डीपफेक वीडियो',
      'mr': 'व्यापारी नेत्याचा डीपफेक व्हिडिओ',
    },
    'A deepfake video shows a well-known business leader announcing a fake product launch.': {
      'hi':
          'एक डीपफेक वीडियो एक प्रसिद्ध व्यापारिक नेता को फर्जी उत्पाद लॉन्च की घोषणा करते दिखाता है।',
      'mr':
          'एक डीपफेक व्हिडिओ एका प्रसिद्ध व्यापारी नेत्याला बनावट उत्पाद लॉन्चची घोषणा करताना दाखवतो.',
    },
    'Facial landmark analysis detects micro-expression anomalies.': {
      'hi':
          'फेशियल लैंडमार्क विश्लेषण सूक्ष्म-अभिव्यक्ति विसंगतियों का पता लगाता है।',
      'mr': 'फेशियल लँडमार्क विश्लेषण सूक्ष्म-अभिव्यक्ती विसंगती शोधते.',
    },
    'Lip-sync accuracy is below natural speech threshold.': {
      'hi': 'लिप-सिंक सटीकता प्राकृतिक भाषण सीमा से नीचे है।',
      'mr': 'लिप-सिंक अचूकता नैसर्गिक भाषण मर्यादेपेक्षा कमी आहे.',
    },
    'The company has officially denied any such announcement.': {
      'hi': 'कंपनी ने आधिकारिक रूप से ऐसी किसी भी घोषणा से इनकार किया है।',
      'mr': 'कंपनीने अशा कोणत्याही घोषणेस अधिकृतपणे नकार दिला आहे.',
    },
    'Frame-by-frame analysis reveals temporal artifacts at splice points.': {
      'hi':
          'फ्रेम-दर-फ्रेम विश्लेषण स्प्लाइस बिंदुओं पर टेम्पोरल आर्टिफैक्ट्स प्रकट करता है।',
      'mr':
          'फ्रेम-बाय-फ्रेम विश्लेषण स्प्लाइस बिंदूंवर टेम्पोरल आर्टिफॅक्ट्स प्रकट करते.',
    },
  };

  /// Translate dynamic API content by searching for known phrases
  static String translateContent(String text, String locale) {
    if (locale == 'en') return text;
    String result = text;
    // Sort by longest first to avoid partial matches
    final sortedKeys = _contentMap.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in sortedKeys) {
      if (result.contains(key)) {
        final translation = _contentMap[key]?[locale];
        if (translation != null) {
          result = result.replaceAll(key, translation);
        }
      }
    }
    return result;
  }
}
