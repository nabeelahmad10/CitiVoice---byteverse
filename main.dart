import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// These packages would need to be added to your pubspec.yaml
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:lottie/lottie.dart';

void main() => runApp(MyApp());

// --- App Setup ---
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100], // Lighter background
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Default AppBar color
          foregroundColor: Colors.white, // Default text/icon color on AppBar
          elevation: 2,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        cardTheme: CardTheme(
            elevation: 1.5,
            margin: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
            )
        ),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Main Navigation Structure ---
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isAIAssistantVisible = false;

  final List<Widget> _bottomNavPages = [
    HomeContent(),
    AlertsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Hide AI assistant when switching tabs
      if (_isAIAssistantVisible) {
        _isAIAssistantVisible = false;
      }
    });
  }

  void _toggleAIAssistant() {
    setState(() {
      _isAIAssistantVisible = !_isAIAssistantVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            _bottomNavPages[_selectedIndex],

            // AI Assistant FAB
            Positioned(
              right: 16,
              bottom: 80, // Position above bottom nav
              child: FloatingActionButton(
                onPressed: _toggleAIAssistant,
                backgroundColor: Color(0xFF6A60F6),
                child: Icon(
                  _isAIAssistantVisible ? Icons.close : Icons.smart_toy,
                  color: Colors.white,
                ),
                tooltip: "AI Assistant",
              ),
            ),

            // AI Assistant Panel
            if (_isAIAssistantVisible)
              AIAssistantPanel(
                onClose: _toggleAIAssistant,
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure labels are always visible
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"), // Using filled icons
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active), label: "Alerts"), // Using active icon
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: "History"), // Different history icon
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"), // Outline icon
        ],
      ),
    );
  }
}

// --- AI Assistant Panel ---
class AIAssistantPanel extends StatefulWidget {
  final VoidCallback onClose;

  AIAssistantPanel({required this.onClose});

  @override
  _AIAssistantPanelState createState() => _AIAssistantPanelState();
}

class _AIAssistantPanelState extends State<AIAssistantPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isExpanded = false;

  // Speech to text and text to speech would be initialized here
  // stt.SpeechToText _speech = stt.SpeechToText();
  // FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();

    // Add initial greeting message
    _addMessage(
      "Hello! I'm your AI assistant. How can I help you with medical, legal, or government services today?",
      false,
    );

    // Initialize speech recognition and TTS here
    // _initSpeech();
    // _initTts();
  }

  // void _initSpeech() async {
  //   bool available = await _speech.initialize(
  //     onStatus: (status) => print('Speech status: $status'),
  //     onError: (error) => print('Speech error: $error'),
  //   );
  //   if (!available) {
  //     print("Speech recognition not available");
  //   }
  // }

  // void _initTts() async {
  //   await _flutterTts.setLanguage("en-US");
  //   await _flutterTts.setSpeechRate(0.5);
  //   await _flutterTts.setVolume(1.0);
  //   await _flutterTts.setPitch(1.0);
  // }

  void _listen() {
    // Simulated speech recognition
    setState(() {
      _isListening = true;
    });

    // Simulate processing delay
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isListening = false;
        _messageController.text = "I need help with filing a legal complaint";
      });
    });

    // Real implementation would use:
    // if (!_isListening) {
    //   _speech.listen(
    //     onResult: (result) {
    //       setState(() {
    //         _messageController.text = result.recognizedWords;
    //         if (result.finalResult) {
    //           _isListening = false;
    //         }
    //       });
    //     },
    //   );
    // } else {
    //   _speech.stop();
    //   setState(() {
    //     _isListening = false;
    //   });
    // }
  }

  void _speak(String text) {
    // Simulated text-to-speech
    print("Speaking: $text");

    // Real implementation would use:
    // _flutterTts.speak(text);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    _addMessage(userMessage, true);
    _messageController.clear();

    setState(() {
      _isProcessing = true;
    });

    // Simulate AI processing
    await Future.delayed(Duration(seconds: 2));

    // Generate response based on user message
    String response = _generateResponse(userMessage);

    _addMessage(response, false);
    _speak(response);

    setState(() {
      _isProcessing = false;
    });

    // Real implementation would call an API:
    // try {
    //   final response = await http.post(
    //     Uri.parse('https://your-ai-api-endpoint.com/chat'),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode({
    //       'message': userMessage,
    //       'context': 'medical_legal_government',
    //     }),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //     _addMessage(data['response'], false);
    //     _speak(data['response']);
    //   } else {
    //     _addMessage("Sorry, I'm having trouble connecting. Please try again later.", false);
    //   }
    // } catch (e) {
    //   _addMessage("Network error. Please check your connection and try again.", false);
    // } finally {
    //   setState(() {
    //     _isProcessing = false;
    //   });
    // }
  }

  // Simulated response generation
  String _generateResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('medical') || message.contains('doctor') || message.contains('health')) {
      return "I can help you with medical services. Would you like to book an appointment with a doctor, find nearby hospitals, or get information about health insurance?";
    } else if (message.contains('legal') || message.contains('lawyer') || message.contains('complaint')) {
      return "For legal assistance, I can help you connect with a lawyer, provide information about filing complaints, or guide you through common legal procedures. What specific legal help do you need?";
    } else if (message.contains('government') || message.contains('service') || message.contains('document')) {
      return "I can assist with government services like document applications, checking status of applications, or finding the right department for your needs. Please let me know what government service you're looking for.";
    } else if (message.contains('emergency') || message.contains('sos')) {
      return "If this is an emergency, please use the SOS button on the home screen or dial emergency services directly. Would you like me to guide you to the emergency features?";
    } else {
      return "I'm here to help with medical, legal, and government services. Could you please provide more details about what you need assistance with?";
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _animationController.dispose();
    // _speech.cancel();
    // _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = _isExpanded ? screenHeight * 0.8 : screenHeight * 0.5;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: panelHeight * _animation.value,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity! > 300) {
                // Swipe down to close
                widget.onClose();
              } else if (details.primaryVelocity! < -300) {
                // Swipe up to expand
                setState(() {
                  _isExpanded = true;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar for dragging
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xFF6A60F6).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.smart_toy, color: Color(0xFF6A60F6)),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "AI Assistant",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(_isExpanded ? Icons.fullscreen_exit : Icons.fullscreen),
                              onPressed: _toggleExpand,
                              tooltip: _isExpanded ? "Minimize" : "Expand",
                            ),
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: widget.onClose,
                              tooltip: "Close",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(),

                  // Chat messages
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _messages.length,
                      reverse: false,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
                  ),

                  // AI thinking indicator
                  if (_isProcessing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF6A60F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.smart_toy, color: Color(0xFF6A60F6), size: 16),
                          ),
                          SizedBox(width: 8),
                          Text("Thinking..."),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A60F6)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Input area
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Voice input button
                        GestureDetector(
                          onTap: _listen,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? Color(0xFF6A60F6)
                                  : Color(0xFF6A60F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.white : Color(0xFF6A60F6),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Text input field
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Send button
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF6A60F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick suggestions
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildSuggestionChip("Medical help"),
                        _buildSuggestionChip("Legal advice"),
                        _buildSuggestionChip("Government services"),
                        _buildSuggestionChip("File a complaint"),
                        _buildSuggestionChip("Emergency contacts"),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF6A60F6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: Color(0xFF6A60F6), size: 16),
            ),
            SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Color(0xFF6A60F6)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.person, color: Colors.blue, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () {
          _messageController.text = text;
          _sendMessage();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFF6A60F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF6A60F6).withOpacity(0.3)),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xFF6A60F6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }
}

// --- Chat Message Model ---
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// --- Home Content (Grid Navigation) ---
class HomeContent extends StatelessWidget {
  final List<_ServiceOption> options = [
    _ServiceOption("Medical Assistance", Icons.medical_services_outlined, Colors.green),
    _ServiceOption("Emergency SOS", Icons.sos, Colors.red), // Specific SOS icon
    _ServiceOption("Legal Help", Icons.gavel_outlined, Colors.blue),
    _ServiceOption("File a Grievance", Icons.assignment_add_outlined, Colors.orange), // Add icon
    _ServiceOption("Government Services", Icons.account_balance_outlined, Colors.purple),
    _ServiceOption("Track Complaint", Icons.playlist_add_check_circle_outlined, Colors.teal), // Tracking icon
  ];

  // Navigation Logic
  void _navigateToPage(BuildContext context, String title) {
    Widget? page;
    switch (title) {
      case "Medical Assistance":
        page = MedicalAssistanceScreen();
        break;
      case "Emergency SOS":
        page = EmergencySOSScreen(); // Navigate to the dedicated SOS screen
        break;
      case "Legal Help":
        page = LegalHelpScreen();
        break;
      case "File a Grievance":
        page = FileGrievanceScreen();
        break;
      case "Government Services":
        page = GovernmentServicesScreen();
        break;
      case "Track Complaint":
        page = TrackComplaintScreen();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service "$title" not implemented yet.')),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page!),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Gradient background for the top section
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, Suresh 👋",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("How can we help you today?", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.translate, color: Colors.white), // Language icon
                  onPressed: () { /* Handle language change */ },
                ),
              ],
            ),
          ),
          // Search Bar - slightly different style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: TextField(
              style: TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search services...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue, width: 1.5), // Highlight on focus
                ),
              ),
            ),
          ),
          // Grid Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor, // Use theme background
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16), // More top padding
              child: GridView.builder(
                itemCount: options.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.05, // Slightly taller items
                ),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _buildHomeGridItem(context, option); // Use helper
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper for Grid Item in HomeContent
  Widget _buildHomeGridItem(BuildContext context, _ServiceOption option) {
    return InkWell( // Use InkWell for ripple effect
      onTap: () => _navigateToPage(context, option.title),
      borderRadius: BorderRadius.circular(16), // Match container border radius
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient( // Use gradients on cards
            colors: [option.color.withOpacity(0.85), option.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: option.color.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, color: Colors.white, size: 45),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                option.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- Alerts Screen (Existing - Minor Style Update) ---
class AlertsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Wrap in Scaffold for consistent AppBar
      appBar: AppBar(
        title: Text("Important Alerts"),
        backgroundColor: Colors.red[700], // Slightly darker red
      ),
      body: Container(
        // color: Colors.red[50], // Color now handled by Scaffold background
          padding: EdgeInsets.all(16),
          child: ListView( // Use ListView for potential scrolling
              children: [
              _buildAlertCard(context, Icons.flood, "Flood Warning", "High water levels reported near Adyar River. Consider moving to higher ground if in affected zones.", Colors.orange),
          _buildAlertCard(context, Icons.power_off, "Power Outage Update", "Scheduled maintenance tomorrow (Apr 14) from 10 AM to 1 PM in Sector  "Power Outage Update", "Scheduled maintenance tomorrow (Apr 14) from 10 AM to 1 PM in Sector 5.", Colors.blueGrey),
          _buildAlertCard(context, Icons.masks, "Health Advisory", "Increase in flu cases reported. Maintain hygiene and wear masks in crowded places.", Colors.blue),
      _buildAlertCard(context, Icons.traffic, "Traffic Alert", "Heavy congestion on GST Road due to ongoing road work. Plan alternate routes.", Colors.deepPurple),
      ],
    ),
    ));
  }

  Widget _buildAlertCard(BuildContext context, IconData icon, String title, String message, Color iconColor) {
    return Card(
      // color: Colors.red[100], // Card color from theme now
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Handled by theme
      child: ListTile(
        leading: CircleAvatar( // Use CircleAvatar for icon background
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(message, style: TextStyle(color: Colors.black87)),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    );
  }
}


// --- History Screen (Existing - Minor Style Update) ---
class HistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> historyItems = [ // Include icons
    {"title": "Medical Consultation Booked", "date": "April 10, 2025", "icon": Icons.medical_services_outlined, "color": Colors.green},
    {"title": "Grievance Filed: Pothole", "date": "April 2, 2025", "icon": Icons.assignment_add_outlined, "color": Colors.orange},
    {"title": "SOS Alert Triggered", "date": "March 28, 2025", "icon": Icons.sos, "color": Colors.red},
    {"title": "Legal Advice Requested", "date": "March 15, 2025", "icon": Icons.gavel_outlined, "color": Colors.blue},
    {"title": "Complaint Tracked: #GVT123", "date": "March 10, 2025", "icon": Icons.playlist_add_check_circle_outlined, "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity History"),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: Container(
        // color: Colors.grey[100], // Handled by theme
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return Card(
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Handled by theme
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: (item['color'] as Color).withOpacity(0.1),
                  child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                ),
                title: Text(item['title']!),
                subtitle: Text(item['date']!),
                trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () { /* Navigate to detail if applicable */ } ,
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- Profile Screen (Existing - Style Update) ---
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        backgroundColor: Colors.indigo, // Different color for profile
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView( // Added SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Stack( // Add edit icon over avatar
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60, // Larger avatar
                      backgroundColor: Colors.indigo[100],
                      child: Icon(Icons.person, color: Colors.indigo, size: 65),
                    ),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.indigo),
                    )
                  ]
              ),
              SizedBox(height: 16),
              Text(
                "Rituparna Das", // Full name
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800]),
              ),
              Text(
                "User ID: RP-2034",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(height: 24),
              Divider(),
              _buildProfileOption(context, Icons.email_outlined, "rituparna.d@email.com"), // Example email
              _buildProfileOption(context, Icons.phone_android_outlined, "+91 98765 43210"),
              _buildProfileOption(context, Icons.location_on_outlined, "Kattankulathur, TN"),
              _buildProfileOption(context, Icons.credit_card_outlined, "Payment Methods", onTap: () {}), // Added option
              _buildProfileOption(context, Icons.notifications_none, "Notifications", onTap: () {}), // Added option
              _buildProfileOption(context, Icons.settings_outlined, "App Settings", onTap: () {}),
              _buildProfileOption(context, Icons.help_outline, "Help & Support", onTap: () {}), // Added option
              SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: Icon(Icons.logout, color: Colors.white),
                  label: Text("Logout", style: TextStyle(color: Colors.white)),
                  onPressed: () { /* Logout logic */ },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.infinity, 45)
                  )
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo[600]),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey) : null,
      onTap: onTap,
      dense: true, // Makes ListTile compact
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }
}


// =====================================================
// --- NEW / ENHANCED SCREENS ---
// =====================================================

// --- Emergency SOS Screen ---
class EmergencySOSScreen extends StatefulWidget { // Made stateful for location simulation
  @override
  _EmergencySOSScreenState createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends State<EmergencySOSScreen> {
  String _currentLocation = "Fetching location...";
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _getSimulatedLocation();
  }

  // --- SIMULATED LOCATION FETCH ---
  Future<void> _getSimulatedLocation() async {
    // ** REAL IMPLEMENTATION NOTES **
    // 1. Add geolocator: ^latest_version to pubspec.yaml
    // 2. Add permission_handler: ^latest_version to pubspec.yaml
    // 3. Request location permissions (check AndroidManifest.xml and Info.plist)
    // 4. Use Geolocator.getCurrentPosition()

    // Simulate delay
    await Future.delayed(Duration(seconds: 2));

    // Simulate fetching - Replace with actual Geolocator call
    // Example: Position position = await Geolocator.getCurrentPosition(...);
    // Example: List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    // Example: String address = "${placemarks.first.street}, ${placemarks.first.locality}";

    setState(() {
      // Using current known location as placeholder
      _currentLocation = "Near SRM University, Kattankulathur, TN";
      _locationFetched = true;
    });
  }

  // --- SIMULATED CALL FUNCTION ---
  Future<void> _makeEmergencyCall(String number) async {
    // ** REAL IMPLEMENTATION NOTES **
    // 1. Add url_launcher: ^latest_version to pubspec.yaml
    // 2. Use launchUrl(Uri.parse('tel:$number'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulating call to $number...')),
    );
    // await launchUrl(Uri.parse('tel:$number'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency SOS"),
        backgroundColor: Colors.red[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BIG SOS BUTTON ---
            Container(
              height: 180,
              child: ElevatedButton(
                onPressed: () {
                  // Trigger SOS Action - Alert contacts, send location etc.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('SOS ACTION ACTIVATED! (Simulated)')),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos, size: 80, color: Colors.white),
                    SizedBox(height: 10),
                    Text("ACTIVATE SOS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: CircleBorder(), // Make it circular
                  elevation: 10,
                ),
              ),
            ),
            SizedBox(height: 24),

            // --- CURRENT LOCATION CARD ---
            _buildSectionTitle(context, "Your Current Location", Icons.my_location),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.location_pin, color: Colors.red, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: _locationFetched
                          ? Text(_currentLocation, style: TextStyle(fontSize: 16))
                          : Row(children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text("Fetching location...")
                      ]),
                    ),
                    if (_locationFetched) // Show refresh button only after fetch
                      IconButton(
                          icon: Icon(Icons.refresh, color: Colors.blue),
                          onPressed: () {
                            setState(() { // Simulate re-fetching
                              _locationFetched = false;
                              _currentLocation = "Fetching location...";
                            });
                            _getSimulatedLocation();
                          }
                      )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // --- QUICK CONTACTS ---
            _buildSectionTitle(context, "Quick Emergency Contacts", Icons.call),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildEmergencyContactButton(context, "Police", Icons.local_police, "100", Colors.blue),
                _buildEmergencyContactButton(context, "Ambulance", Icons.emergency, "108", Colors.green),
                _buildEmergencyContactButton(context, "Fire", Icons.fire_truck, "101", Colors.orange),
              ],
            ),
            SizedBox(height: 20),

            // --- ALERT CONTACTS ---
            _buildSectionTitle(context, "Alert Emergency Contacts", Icons.people_alt),
            Card(
              child: ListTile(
                  leading: Icon(Icons.add_alert, color: Colors.redAccent),
                  title: Text("Alert Predefined Contacts"),
                  subtitle: Text("Send location & alert message"),
                  trailing: Icon(Icons.send),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Simulating alert to contacts...')),
                    );
                  }
              ),
            ),
            Card(
              child: ListTile(
                  leading: Icon(Icons.settings, color: Colors.grey),
                  title: Text("Manage Emergency Contacts"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () { /* Navigate to contact settings */ }
              ),
            ),

          ],
        ),
      ),
    );
  }

  // Helper for Emergency Contact Buttons
  Widget _buildEmergencyContactButton(BuildContext context, String label, IconData icon, String number, Color color) {
    return ElevatedButton(
      onPressed: () => _makeEmergencyCall(number),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.zero
      ),
    );
  }
}

// --- Medical Assistance Screen ---
class MedicalAssistanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical Assistance"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Quick Actions", Icons.flash_on),
            // Quick Action Buttons (e.g., Grid or Row)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5, // Adjust ratio for wider buttons
              children: [
                _buildQuickActionButton(context, "Call Ambulance", Icons.emergency, Colors.red, () { /* Call 108 */ }),
                _buildQuickActionButton(context, "Book Appointment", Icons.calendar_today, Colors.blue, () { /* Navigate to booking */ }),
              ],
            ),
            SizedBox(height: 20),

            // Find Nearby
            _buildSectionTitle(context, "Find Nearby", Icons.location_searching),
            _buildInfoCard(context, "Hospitals", Icons.local_hospital, Colors.red, () { /* Navigate to map/list */ }),
            _buildInfoCard(context, "Clinics", Icons.medical_services_outlined, Colors.blue, () { /* Navigate to map/list */ }),
            _buildInfoCard(context, "Pharmacies", Icons.local_pharmacy, Colors.purple, () { /* Navigate to map/list */ }),
            SizedBox(height: 20),

            // Health Resources
            _buildSectionTitle(context, "Health Resources", Icons.health_and_safety),
            _buildInfoCard(context, "First Aid Tips", Icons.medication_liquid, Colors.orange, () { /* Show tips */ }),
            _buildInfoCard(context, "Symptom Checker", Icons.sick_outlined, Colors.teal, () { /* Link to checker */ }),
            _buildInfoCard(context, "Health Records", Icons.folder_copy_outlined, Colors.indigo, () { /* Link to records */ }),

          ],
        ),
      ),
    );
  }

  // Helper for Quick Action Buttons
  Widget _buildQuickActionButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          alignment: Alignment.centerLeft, // Align icon/text left
          padding: EdgeInsets.symmetric(horizontal: 16)
      ),
    );
  }
}


// --- File a Grievance Screen ---
class FileGrievanceScreen extends StatefulWidget { // Needs state for form
  @override
  _FileGrievanceScreenState createState() => _FileGrievanceScreenState();
}

class _FileGrievanceScreenState extends State<FileGrievanceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(); // Optional location

  final List<String> _categories = ["Public Transport", "Roads & Infrastructure", "Waste Management", "Public Safety", "Utilities", "Environment", "Other"];

  // Simulate fetching current location for the form field
  Future<void> _getSimulatedLocationForForm() async {
    // Simulate fetching location
    await Future.delayed(Duration(milliseconds: 500));
    // Replace with actual location fetching if needed
    _locationController.text = "Near SRM Arch, Kattankulathur";
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("File a Grievance"),
        backgroundColor: Colors.orange[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "Grievance Details", Icons.edit_note),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text("Select Category"),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
                decoration: InputDecoration( // Use themed decoration
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              SizedBox(height: 16),

              // Description Text Area
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Describe the issue",
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true, // Better alignment for multiline
                ),
                maxLines: 5,
                minLines: 3,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a description' : null,
              ),
              SizedBox(height: 16),

              // Optional Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                    labelText: "Location (Optional)",
                    prefixIcon: Icon(Icons.location_on_outlined),
                    suffixIcon: IconButton( // Button to fetch location
                      icon: Icon(Icons.my_location, color: Colors.blue),
                      tooltip: "Use Current Location",
                      onPressed: _getSimulatedLocationForForm,
                    )
                ),
              ),
              SizedBox(height: 16),

              // Attachments Button (UI Only)
              OutlinedButton.icon(
                icon: Icon(Icons.attach_file),
                label: Text("Attach Photos/Videos (Optional)"),
                onPressed: () { /* Implement file picking */ },
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange[900],
                    side: BorderSide(color: Colors.orange[800]!)
                ),
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text("Submit Grievance", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data (send to backend, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Grievance submitted successfully! (Simulated)')),
                      );
                      // Optionally clear form or navigate away
                      // _formKey.currentState?.reset();
                      // setState(() => _selectedCategory = null);
                      // _descriptionController.clear();
                      // _locationController.clear();
                      Navigator.pop(context); // Go back after submission
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                      minimumSize: Size(double.infinity, 50) // Full width
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --- Government Services Screen ---
class GovernmentServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Government Services"),
        backgroundColor: Colors.purple[700],
      ),
      body: ListView( // Use ListView for categories
        padding: EdgeInsets.all(12),
        children: [
          _buildSectionTitle(context, "Popular Services", Icons.star_border),
          // Example popular services (could be fetched)
          _buildServiceListTile(context, "Apply for Aadhaar Card", Icons.fingerprint, () {}),
          _buildServiceListTile(context, "Pay Property Tax", Icons.house_outlined, () {}),
          _buildServiceListTile(context, "Check Driving License Status", Icons.drive_eta_outlined, () {}),
          SizedBox(height: 16),

          _buildSectionTitle(context, "Service Categories", Icons.category),
          // Categories using ExpansionTiles
          _buildServiceCategoryTile(
              context,
              "Identity & Verification",
              Icons.badge_outlined,
              Colors.blue,
              [
                _buildServiceListTile(context, "Aadhaar Services", Icons.fingerprint, () {}),
                _buildServiceListTile(context, "PAN Card Services", Icons.credit_card_outlined, () {}),
                _buildServiceListTile(context, "Voter ID Card", Icons.how_to_vote_outlined, () {}),
              ]
          ),
          _buildServiceCategoryTile(
              context,
              "Utilities & Bills",
              Icons.receipt_long_outlined,
              Colors.green,
              [
                _buildServiceListTile(context, "Electricity Bill Payment", Icons.electrical_services_outlined, () {}),
                _buildServiceListTile(context, "Water Bill Payment", Icons.water_drop_outlined, () {}),
                _buildServiceListTile(context, "Gas Booking", Icons.local_fire_department_outlined, () {}),
              ]
          ),
          _buildServiceCategoryTile(
              context,
              "Transport & Vehicles",
              Icons.directions_car_outlined,
              Colors.orange,
              [
                _buildServiceListTile(context, "Driving License Services", Icons.drive_eta_outlined, () {}),
                _buildServiceListTile(context, "Vehicle Registration (RC)", Icons.rv_hookup_outlined, () {}),
                _buildServiceListTile(context, "FASTag Recharge", Icons.toll_outlined, () {}),
              ]
          ),
          _buildServiceCategoryTile(
              context,
              "Social Welfare",
              Icons.group_outlined,
              Colors.redAccent,
              [
                _buildServiceListTile(context, "Pension Schemes", Icons.elderly_outlined, () {}),
                _buildServiceListTile(context, "Scholarships", Icons.school_outlined, () {}),
              ]
          ),
        ],
      ),
    );
  }

  // Helper for Expansion Tile Category
  Widget _buildServiceCategoryTile(BuildContext context, String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures corners are clipped
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        childrenPadding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start, // Align children left
        children: children,
      ),
    );
  }

  // Helper for individual service items within a category
  Widget _buildServiceListTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColorDark),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      onTap: onTap,
    );
  }
}


// --- Track Complaint Screen ---
class TrackComplaintScreen extends StatefulWidget { // Stateful for status simulation
  @override
  _TrackComplaintScreenState createState() => _TrackComplaintScreenState();
}

class _TrackComplaintScreenState extends State<TrackComplaintScreen> {
  final TextEditingController _complaintIdController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _complaintStatus; // To hold simulated status

  // Simulate fetching status
  void _trackComplaint() async {
    if (_complaintIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a Complaint ID')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _complaintStatus = null; // Clear previous status
    });

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    // Simulate API response based on ID (very basic example)
    if (_complaintIdController.text.toUpperCase() == "GRV123") {
      _complaintStatus = {
        "id": "GRV123",
        "status": "In Progress",
        "submitted": "April 2, 2025",
        "category": "Roads & Infrastructure",
        "department": "Public Works Dept.",
        "lastUpdate": "April 10, 2025 - Assigned to Engineer",
        "expectedResolution": "April 25, 2025 (Estimate)"
      };
    } else if (_complaintIdController.text.toUpperCase() == "SOS456") {
      _complaintStatus = {
        "id": "SOS456",
        "status": "Resolved",
        "submitted": "March 28, 2025",
        "category": "Public Safety",
        "department": "Police Dept.",
        "lastUpdate": "March 29, 2025 - Case Closed",
        "resolutionDetails": "Patrol investigated, issue resolved."
      };
    }
    else {
      _complaintStatus = {
        "id": _complaintIdController.text,
        "status": "Not Found",
      };
    }


    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _complaintIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Complaint Status"),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle(context, "Enter Complaint ID", Icons.receipt_outlined),
            Row( // Input field and button side-by-side
              children: [
                Expanded(
                  child: TextField(
                    controller: _complaintIdController,
                    decoration: InputDecoration(
                      labelText: 'Complaint ID (e.g., GRV123)',
                      // border: OutlineInputBorder(), // Handled by theme
                      // prefixIcon: Icon(Icons.search), // Added below
                    ),
                    textInputAction: TextInputAction.search, // Show search icon on keyboard
                    onSubmitted: (_) => _trackComplaint(), // Track on submit from keyboard
                  ),
                ),
                SizedBox(width: 10),
                IconButton.filled( // Use filled button for search
                  icon: Icon(Icons.search),
                  onPressed: _trackComplaint,
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(14) // Make it larger
                  ),
                  tooltip: "Track Status",
                )
              ],
            ),
            SizedBox(height: 24),

            // Status Display Area
            _buildSectionTitle(context, "Complaint Status", Icons.fact_check_outlined),

            _isLoading
                ? Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : _complaintStatus == null
                ? Card(child: Padding(padding: EdgeInsets.all(16), child: Text("Enter a Complaint ID and press Track.", textAlign: TextAlign.center)))
                : Card(
              color: Colors.teal[50], // Light background for status card
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _complaintStatus!['status'] == "Not Found"
                    ? Text("Complaint ID '${_complaintStatus!['id']}' not found.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow("ID:", _complaintStatus!['id']),
                    _buildStatusRow("Status:", _complaintStatus!['status'], isStatus: true),
                    if (_complaintStatus!.containsKey('category'))
                      _buildStatusRow("Category:", _complaintStatus!['category']),
                    if (_complaintStatus!.containsKey('submitted'))
                      _buildStatusRow("Submitted:", _complaintStatus!['submitted']),
                    if (_complaintStatus!.containsKey('department'))
                      _buildStatusRow("Department:", _complaintStatus!['department']),
                    if (_complaintStatus!.containsKey('lastUpdate'))
                      _buildStatusRow("Last Update:", _complaintStatus!['lastUpdate']),
                    if (_complaintStatus!.containsKey('expectedResolution'))
                      _buildStatusRow("Est. Resolution:", _complaintStatus!['expectedResolution']),
                    if (_complaintStatus!.containsKey('resolutionDetails'))
                      _buildStatusRow("Resolution:", _complaintStatus!['resolutionDetails']),
                  ],
                ),
              ),
            ),

            // Action Buttons (Conditional)
            if (_complaintStatus != null && _complaintStatus!['status'] != "Not Found" && _complaintStatus!['status'] != "Resolved")
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(Icons.add_comment_outlined),
                      label: Text("Add Comment"),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.teal),
                    ),
                    OutlinedButton.icon(
                      icon: Icon(Icons.upgrade_outlined),
                      label: Text("Escalate"),
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  // Helper to display status rows neatly
  Widget _buildStatusRow(String label, String value, {bool isStatus = false}) {
    Color statusColor = Colors.black87;
    FontWeight statusWeight = FontWeight.normal;
    if (isStatus) {
      switch(value.toLowerCase()) {
        case 'in progress': statusColor = Colors.orange.shade800; statusWeight = FontWeight.bold; break;
        case 'submitted': statusColor = Colors.blue.shade700; statusWeight = FontWeight.bold; break;
        case 'resolved': statusColor = Colors.green.shade700; statusWeight = FontWeight.bold; break;
        case 'rejected': statusColor = Colors.red.shade700; statusWeight = FontWeight.bold; break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54))),
          Expanded(child: Text(value, style: TextStyle(color: statusColor, fontWeight: statusWeight, fontSize: 15))),
        ],
      ),
    );
  }
}


// --- Legal Help Screen (Based on Image - Minor Polish) ---
class LegalHelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Legal Assistance"),
        backgroundColor: Colors.white, // Specific style for this page
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Legal Services", Icons.gavel),
            SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildLegalServiceTile(context, "Legal Advice", Icons.lightbulb_outline, Color(0xFF6A60F6)), // Approx blue
                _buildLegalServiceTile(context, "Document Help", Icons.description_outlined, Color(0xFFF3696A)), // Approx red
                _buildLegalServiceTile(context, "Find Lawyer", Icons.person_search_outlined, Color(0xFF3CD38A)), // Approx green
                _buildLegalServiceTile(context, "Legal Aid", Icons.business_center_outlined, Color(0xFFFFAC4A)), // Approx orange
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton.icon( // AI Assistant Button
              icon: Icon(Icons.smart_toy_outlined, color: Colors.white),
              label: Text("Ask AI Legal Assistant", style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A60F6),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 24),
            _buildSectionTitle(context, "Top Lawyers Nearby", Icons.star_outline),
            SizedBox(height: 12),
            _buildLawyerCard(context, "V", "Vitthal Sharma", "Family Law", 5, "Chennai", "8 years", true),
            _buildLawyerCard(context, "S", "Sanjana K.", "Corporate Law", 4, "Chennai", "5 years", false),
            _buildLawyerCard(context, "R", "Rajesh Gupta", "Criminal Law", 5, "Chennai", "12 years", true),
          ],
        ),
      ),
    );
  }

  // Helper for Service Tiles in Legal Help
  Widget _buildLegalServiceTile(BuildContext context, String title, IconData icon, Color color) {
    return InkWell( // Added InkWell
      onTap: () => _showNotImplementedSnackBar(context, title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 35),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Helper for Lawyer Cards in Legal Help
  Widget _buildLawyerCard(BuildContext context, String initial, String name, String specialty, int rating, String location, String experience, bool available) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Theme
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFE8E6FC), // Light purple background
              child: Text(initial, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A60F6))),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      if (available)
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                            child: Text("Available", style: TextStyle(color: Colors.green[800], fontSize: 11, fontWeight: FontWeight.bold))
                        ) else
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                            child: Text("Busy", style: TextStyle(color: Colors.grey[700], fontSize: 11, fontWeight: FontWeight.bold))
                        ),
                    ],
                  ),
                  Text(specialty, style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 4),
                  Row( // Star Rating
                    children: List.generate(5, (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 18,
                    )),
                  ),
                  SizedBox(height: 4),
                  Text("$location • $experience", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  SizedBox(height: 8),
                  Row( // Action Buttons
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        icon: Icon(Icons.call_outlined, size: 16),
                        label: Text("Call"),
                        onPressed: () => _showNotImplementedSnackBar(context, "Calling $name"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF6A60F6), side: BorderSide(color: Color(0xFF6A60F6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), textStyle: TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text("Book"),
                        onPressed: () => _showNotImplementedSnackBar(context, "Booking $name"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6A60F6), foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), textStyle: TextStyle(fontSize: 12), elevation: 2
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================
// --- UTILITY WIDGETS & CLASSES ---
// =====================================================

// --- Service Option Data Class ---
class _ServiceOption {
  final String title;
  final IconData icon;
  final Color color;

  _ServiceOption(this.title, this.icon, this.color);
}

// --- Helper Widget for Section Titles ---
Widget _buildSectionTitle(BuildContext context, String title, IconData? icon) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
    child: Row(
      children: [
        if (icon != null) Icon(icon, color: Theme.of(context).primaryColorDark, size: 20),
        if (icon != null) SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    ),
  );
}

// --- Helper Widget for Generic Info Cards ---
Widget _buildInfoCard(BuildContext context, String title, IconData icon, Color iconColor, VoidCallback onTap) {
  return Card(
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    ),
  );
}

// --- Helper to show temporary snackbar ---
void _showNotImplementedSnackBar(BuildContext context, String featureName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$featureName feature is not implemented yet.'),
      duration: Duration(seconds: 2),
    ),
  );
}
