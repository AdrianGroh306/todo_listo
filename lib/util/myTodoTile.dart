import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ToDoTile extends StatefulWidget {
  final String taskName;
  final bool taskCompleted;
  final bool isEditing;
  final bool quickToggle;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;
  final VoidCallback? onEdit;
  final Function(String)? onTaskNameChanged;

  const ToDoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    this.isEditing = false,
    this.quickToggle = false,
    required this.onChanged,
    required this.deleteFunction,
    this.onEdit,
    this.onTaskNameChanged,
  });

  @override
  State<ToDoTile> createState() => _ToDoTileState();
}

class _ToDoTileState extends State<ToDoTile>
    with TickerProviderStateMixin {
  late TextEditingController _textController;
  late AnimationController _checkboxAnimationController;
  late Animation<double> _checkboxScaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.taskName);
    
    _checkboxAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _checkboxScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _checkboxAnimationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _checkboxAnimationController.dispose();
    super.dispose();
  }

  void _handleCheckboxTap() {
    _checkboxAnimationController.forward().then((_) {
      _checkboxAnimationController.reverse();
    });
    
    HapticFeedback.lightImpact();
    widget.onChanged?.call(!widget.taskCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        color: widget.taskCompleted 
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isHovered 
              ? colorScheme.outline.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ListTile(
          contentPadding: const EdgeInsets.only(
            left: 16,
            right: 8,
            top: 2,
            bottom: 2,
          ),
          title: widget.isEditing
              ? TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onTaskNameChanged?.call(value.trim());
                    }
                  },
                  onTapOutside: (_) {
                    if (_textController.text.trim().isNotEmpty) {
                      widget.onTaskNameChanged?.call(_textController.text.trim());
                    }
                  },
                )
              : GestureDetector(
                  onTap: widget.quickToggle ? _handleCheckboxTap : widget.onEdit,
                  child: Text(
                    widget.taskName,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.taskCompleted 
                          ? colorScheme.onSurface.withOpacity(0.6)
                          : colorScheme.onSurface,
                      decoration: widget.taskCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: colorScheme.onSurface.withOpacity(0.6),
                      decorationThickness: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          trailing: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _checkboxScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _checkboxScaleAnimation.value * 1.3,
                  child: Checkbox(
                    value: widget.taskCompleted,
                    onChanged: (_) => _handleCheckboxTap(),
                    activeColor: colorScheme.primary,
                    checkColor: colorScheme.onPrimary,
                    side: BorderSide(
                      color: colorScheme.outline,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
