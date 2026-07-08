import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_cic_support/widgets/ai_chat_drawer.dart';
import 'package:flutter_cic_support/utils/table_exporter.dart';

class ChatMessage {
  final String role;
  String content;
  bool isStreaming;
  Map<String, dynamic>? meta;
  int isLiked; // 0 = neutral, 1 = liked

  ChatMessage({
    required this.role,
    required this.content,
    this.isStreaming = false,
    this.meta,
    this.isLiked = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class AIITChatPage extends StatefulWidget {
  const AIITChatPage({Key? key}) : super(key: key);

  @override
  State<AIITChatPage> createState() => _AIITChatPageState();
}

class _AIITChatPageState extends State<AIITChatPage> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Color> _themeColors = [
    const Color(0xFF8E2DE2),
    const Color(0xFF4A00E0),
  ];

  @override
  void initState() {
    super.initState();
    _addInitialGreeting();
  }

  void _addInitialGreeting() {
    _messages.add(ChatMessage(
      role: 'assistant',
      content: 'สวัสดีครับ ผมคือผู้ช่วย AI ด้านงานระบบ IT ยินดีต้อนรับครับ! คุณสามารถสอบถามข้อมูล แจ้งปัญหาคอมพิวเตอร์ ระบบเครือข่าย ขอสิทธิ์การใช้งาน หรือขอคำแนะนำการใช้งานอุปกรณ์และระบบต่างๆ ของบริษัทได้ทันทีครับ',
    ));
  }

  List<String> _getSuggestedQuestions() {
    return [
      "แจ้งคอมพิวเตอร์เปิดไม่ติด",
      "ขอสิทธิ์ใช้งานโฟลเดอร์แชร์ (Shared Folder)",
      "ขอรหัสผ่าน Wi-Fi ของบริษัท",
      "วิธีเปลี่ยนรหัสผ่านอีเมลพนักงาน",
    ];
  }

  void fetchAiStream(String prompt) async {
    final userMessage = ChatMessage(role: 'user', content: prompt);
    final assistantMessage = ChatMessage(role: 'assistant', content: '', isStreaming: true);

    setState(() {
      _messages.add(userMessage);
      _messages.add(assistantMessage);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final empCode = prefs.getString('emp_code') ?? '';
      final departmentId = prefs.getString('department_id') ?? '';

      var request = http.Request('POST', Uri.parse('http://192.168.60.25:3000/api/chat'));
      request.headers['Content-Type'] = 'application/json';
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Build history payload (excluding the 2 new messages we just appended)
      final history = _messages
          .take(_messages.length - 2)
          .map((m) => m.toJson())
          .toList();

      final payload = {
        "prompt": prompt,
        "history": history,
        "department_id": departmentId,
        "emp_code": empCode,
        "token": token,
      };

      debugPrint("===============================");
      debugPrint("Sending Chat Request to AI:");
      debugPrint("URL: http://192.168.60.25:3000/api/chat");
      debugPrint("Headers: ${request.headers}");
      debugPrint("Payload: ${jsonEncode(payload)}");
      debugPrint("===============================");

      request.body = jsonEncode(payload);

      var response = await request.send();

      response.stream.transform(utf8.decoder).transform(const LineSplitter()).listen((value) {
        if (value.contains("[DONE]")) {
           debugPrint("สตรีมมิ่งเสร็จสิ้น");
           if (mounted) {
             setState(() {
               assistantMessage.isStreaming = false;
               _isLoading = false;
             });
           }
           _scrollToBottom();
           return;
        }

        if (value.startsWith("data: ")) {
           var jsonStr = value.substring(6).trim();
           if (jsonStr.isNotEmpty) {
               try {
                   var data = jsonDecode(jsonStr);
                   if (data['text'] != null && data['text'].toString().isNotEmpty) {
                      if (mounted) {
                        setState(() {
                          assistantMessage.content += data['text'];
                        });
                      }
                      _scrollToBottom();
                   }
                   if (data['meta'] != null) {
                      if (mounted) {
                        setState(() {
                          assistantMessage.meta = data['meta'];
                        });
                      }
                      _scrollToBottom();
                   }
               } catch (e) {
                   debugPrint("JSON Decode Error: $e, string: $jsonStr");
               }
           }
        }
      }, onError: (err) {
        if (mounted) {
          setState(() {
            assistantMessage.content += "\nError: $err";
            assistantMessage.isStreaming = false;
            _isLoading = false;
          });
        }
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          assistantMessage.content = "Error: $e";
          assistantMessage.isStreaming = false;
          _isLoading = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void toggleLike(ChatMessage message) async {
    if (message.meta == null || message.meta!['log_id'] == null) return;
    final logId = message.meta!['log_id'];
    
    // Toggle state: if liked, set to 0, otherwise 1
    final newLikeState = message.isLiked == 1 ? 0 : 1;
    
    setState(() {
      message.isLiked = newLikeState;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final empCode = prefs.getString('emp_code') ?? '';
      final departmentId = prefs.getString('department_id') ?? '';

      final headers = {
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };
      final payload = {
        'log_id': logId,
        'is_liked': newLikeState,
        'department_id': departmentId,
        'emp_code': empCode,
        'token': token,
      };

      debugPrint("===============================");
      debugPrint("Sending Feedback to AI:");
      debugPrint("URL: http://192.168.60.25:3000/api/chat/feedback");
      debugPrint("Headers: $headers");
      debugPrint("Payload: ${jsonEncode(payload)}");
      debugPrint("===============================");

      final response = await http.post(
        Uri.parse('http://192.168.60.25:3000/api/chat/feedback'),
        headers: headers,
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        debugPrint('Feedback saved successfully');
      } else {
        debugPrint('Failed to save feedback: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending feedback: $e');
    }
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.24), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 10, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color.darkenColor()),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaSection(Map<String, dynamic> meta) {
    List<Widget> chips = [];
    meta.forEach((key, value) {
      if (key == 'log_id') return; // Skip log_id since it's used for feedback
      
      IconData icon = Icons.info_outline;
      String label = key;
      Color chipColor = const Color(0xFF6B8DF8);

      if (key.toLowerCase().contains('time') || key.toLowerCase().contains('latency') || key.toLowerCase().contains('duration')) {
        icon = Icons.timer_outlined;
        label = 'เวลาประมวลผล';
        chipColor = const Color(0xFF0F9B73);
      } else if (key.toLowerCase().contains('model')) {
        icon = Icons.dns_outlined;
        label = 'โมเดล';
        chipColor = const Color(0xFF8A2387);
      } else if (key.toLowerCase().contains('token')) {
        icon = Icons.generating_tokens_outlined;
        label = 'โทเคน';
        chipColor = const Color(0xFFFF7E36);
      } else if (key.toLowerCase().contains('category') || key.toLowerCase().contains('intent')) {
        icon = Icons.category_outlined;
        label = 'หมวดหมู่';
        chipColor = const Color(0xFFFFAD3B);
      }

      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 6.0, bottom: 4.0),
          child: _buildMetaChip(
            icon: icon,
            label: label,
            value: value.toString(),
            color: chipColor,
          ),
        ),
      );
    });

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: chips,
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    fetchAiStream(text);
  }

  void _showRepeatQuestionDialog(String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.replay_circle_filled_rounded, color: _themeColors[0]),
              const SizedBox(width: 8),
              const Text(
                'ถามซ้ำอีกครั้ง',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'คุณต้องการส่งคำถามนี้เพื่อถามซ้ำอีกครั้งหรือไม่?\n\n"$content"',
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'ยกเลิก',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmitted(content);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColors[0],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ยืนยัน',
                style: TextStyle(
                  fontFamily: 'Prompt',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.role == 'user';
    final bubbleColor = isMe ? _themeColors[0] : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final alignment = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleBorder = isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  backgroundColor: _themeColors[0].withOpacity(0.1),
                  radius: 15,
                  child: Icon(Icons.computer, color: _themeColors[0], size: 14),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: message.content.isNotEmpty
                      ? () => _showRepeatQuestionDialog(message.content)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: bubbleBorder,
                      border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.content.isEmpty && message.isStreaming)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "กำลังพิมพ์...",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontFamily: 'Prompt',
                                ),
                              ),
                            ],
                          )
                        else ...[
                          MarkdownBody(
                            data: message.content,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                height: 1.4,
                                fontFamily: 'Prompt',
                              ),
                              tableHead: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Prompt',
                              ),
                              tableBody: TextStyle(
                                color: textColor,
                                fontSize: 11,
                                fontFamily: 'Prompt',
                              ),
                              tableBorder: TableBorder.all(
                                color: isMe ? Colors.white.withOpacity(0.5) : Colors.grey.shade300,
                                width: 1,
                              ),
                              tableCellsPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            ),
                          ),
                          if (message.isStreaming) ...[
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                              ),
                            ),
                          ],
                        ],
                        if (message.meta != null)
                          _buildMetaSection(message.meta!),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isMe && !message.isStreaming && 
              ((message.meta != null && message.meta!['log_id'] != null) || TableExporter.hasTable(message.content)))
            Padding(
              padding: const EdgeInsets.only(left: 38.0, top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (message.meta != null && message.meta!['log_id'] != null) ...[
                    GestureDetector(
                      onTap: () => toggleLike(message),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: message.isLiked == 1
                              ? _themeColors[0].withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: message.isLiked == 1
                                ? _themeColors[0].withOpacity(0.3)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              message.isLiked == 1 ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                              size: 14,
                              color: message.isLiked == 1 ? _themeColors[0] : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              message.isLiked == 1 ? 'ถูกใจแล้ว' : 'ถูกใจคำตอบ',
                              style: TextStyle(
                                color: message.isLiked == 1 ? _themeColors[0] : Colors.grey.shade700,
                                fontSize: 10,
                                fontFamily: 'Prompt',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (TableExporter.hasTable(message.content))
                      const SizedBox(width: 8),
                  ],
                  if (TableExporter.hasTable(message.content))
                    GestureDetector(
                      onTap: () async {
                        final success = await TableExporter.exportTable(message.content, 'it_ai_report');
                        if (!mounted) return;
                        if (!success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ไม่พบข้อมูลตารางหรือเกิดข้อผิดพลาดในการดาวน์โหลด',
                                style: TextStyle(fontFamily: 'Prompt'),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _themeColors[0].withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _themeColors[0].withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 14,
                              color: _themeColors[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'ดาวน์โหลดตาราง (CSV)',
                              style: TextStyle(
                                color: _themeColors[0],
                                fontSize: 10,
                                fontFamily: 'Prompt',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: const AIChatDrawer(currentTopic: 'it'),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _themeColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ระบบ IT Assistant',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Suggested Questions Selection
          if (!_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.transparent,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: _getSuggestedQuestions().map((question) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          question,
                          style: TextStyle(
                            color: _themeColors[0],
                            fontSize: 11,
                            fontFamily: 'Prompt',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _themeColors[0].withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: _themeColors[0].withOpacity(0.2)),
                        ),
                        onPressed: () => _handleSubmitted(question),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _handleSubmitted,
                        style: const TextStyle(fontSize: 14, fontFamily: 'Prompt'),
                        decoration: const InputDecoration(
                          hintText: 'พิมพ์คำถามเกี่ยวกับระบบ IT ตรงนี้...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'Prompt'),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_textController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _themeColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

extension ColorDarken on Color {
  Color darkenColor([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
