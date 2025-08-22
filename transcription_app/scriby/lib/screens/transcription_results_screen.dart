import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranscriptionResultsScreen extends StatefulWidget {
  final Map<String, dynamic> transcriptionData;
  
  const TranscriptionResultsScreen({Key? key, required this.transcriptionData}) : super(key: key);
  
  @override
  _TranscriptionResultsScreenState createState() => _TranscriptionResultsScreenState();
}

class _TranscriptionResultsScreenState extends State<TranscriptionResultsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcription Results'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.text_fields), text: 'Text'),
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
            Tab(icon: Icon(Icons.topic), text: 'Topics'),
            Tab(icon: Icon(Icons.task_alt), text: 'Actions'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTranscriptionTab(),
          _buildSummaryTab(),
          _buildTopicsTab(),
          _buildActionItemsTab(),
        ],
      ),
    );
  }
  
  Widget _buildTranscriptionTab() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Full Transcription',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyToClipboard(widget.transcriptionData['text']),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  widget.transcriptionData['text'] ?? 'No transcription available',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'Processed in ${widget.transcriptionData['processing_time'] ?? 'N/A'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Spacer(),
              Icon(Icons.verified, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Confidence: ${((widget.transcriptionData['confidence_score'] ?? 0) * 100).toInt()}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryTab() {
    final analysis = widget.transcriptionData['analysis'];
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () => _copyToClipboard(analysis?['summary']),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  analysis?['summary'] ?? 'Summary not available',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopicsTab() {
    final analysis = widget.transcriptionData['analysis'];
    final topics = analysis?['key_topics'] as List<dynamic>? ?? [];
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Topics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: topics.isEmpty
                ? Center(child: Text('No topics identified'))
                : ListView.builder(
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(topic.toString()),
                          trailing: Icon(Icons.topic, color: Colors.deepPurple),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionItemsTab() {
    final analysis = widget.transcriptionData['analysis'];
    final actionItems = analysis?['action_items'] as List<dynamic>? ?? [];
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Action Items',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Expanded(
            child: actionItems.isEmpty
                ? Center(child: Text('No action items identified'))
                : ListView.builder(
                    itemCount: actionItems.length,
                    itemBuilder: (context, index) {
                      final item = actionItems[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.task_alt, color: Colors.orange),
                          title: Text(item.toString()),
                          trailing: IconButton(
                            icon: Icon(Icons.check_circle_outline),
                            onPressed: () {
                              // Mark as completed
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  void _copyToClipboard(String? text) {
    if (text != null) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }
  
  void _shareResults() {
    // Implement sharing functionality
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}