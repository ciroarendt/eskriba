import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';

/// Widget to display AI-extracted action items with priorities and assignments
class ActionItemsWidget extends StatefulWidget {
  final List<dynamic> actionItems;

  const ActionItemsWidget({
    super.key,
    required this.actionItems,
  });

  @override
  State<ActionItemsWidget> createState() => _ActionItemsWidgetState();
}

class _ActionItemsWidgetState extends State<ActionItemsWidget> {
  String _filterPriority = 'all';
  final List<String> _completedItems = [];

  @override
  Widget build(BuildContext context) {
    if (widget.actionItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhuma ação identificada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A IA não encontrou itens de ação nesta transcrição',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final filteredItems = _getFilteredItems();

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              const Text('Filtrar por prioridade:'),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Todas'),
                      _buildFilterChip('high', 'Alta'),
                      _buildFilterChip('medium', 'Média'),
                      _buildFilterChip('low', 'Baixa'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Action Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final task = item['task'] ?? 'Tarefa sem descrição';
              final priority = item['priority'] ?? 'medium';
              final assignee = item['assignee'];
              final dueDate = item['due_date'];
              final category = item['category'];
              final itemId = '${task}_$index';
              final isCompleted = _completedItems.contains(itemId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          // Checkbox
                          Checkbox(
                            value: isCompleted,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _completedItems.add(itemId);
                                } else {
                                  _completedItems.remove(itemId);
                                }
                              });
                            },
                          ),
                          
                          // Priority Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(priority).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPriorityLabel(priority),
                              style: TextStyle(
                                color: _getPriorityColor(priority),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Category Badge
                          if (category != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Task Description
                      Text(
                        task,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : null,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Details Row
                      Row(
                        children: [
                          // Assignee
                          if (assignee != null) ...[
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              assignee,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          
                          // Due Date
                          if (dueDate != null) ...[
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dueDate,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Summary Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Total',
                widget.actionItems.length.toString(),
                Icons.list_alt,
                Colors.blue,
              ),
              _buildSummaryItem(
                'Concluídas',
                _completedItems.length.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildSummaryItem(
                'Pendentes',
                (widget.actionItems.length - _completedItems.length).toString(),
                Icons.pending,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterPriority == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        onSelected: (selected) {
          setState(() {
            _filterPriority = value;
          });
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  List<dynamic> _getFilteredItems() {
    if (_filterPriority == 'all') {
      return widget.actionItems;
    }
    
    return widget.actionItems.where((item) {
      final priority = item['priority'] ?? 'medium';
      return priority == _filterPriority;
    }).toList();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'ALTA';
      case 'medium':
        return 'MÉDIA';
      case 'low':
        return 'BAIXA';
      default:
        return 'N/A';
    }
  }
}
