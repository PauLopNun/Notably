import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Mobile-optimized swipe actions for list items
class SwipeActionCard extends StatefulWidget {
  final Widget child;
  final List<SwipeAction>? leftActions;
  final List<SwipeAction>? rightActions;
  final VoidCallback? onTap;
  final double threshold;

  const SwipeActionCard({
    super.key,
    required this.child,
    this.leftActions,
    this.rightActions,
    this.onTap,
    this.threshold = 0.3,
  });

  @override
  State<SwipeActionCard> createState() => _SwipeActionCardState();
}

class _SwipeActionCardState extends State<SwipeActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0.0;
  double _maxExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // Background actions
          if (widget.leftActions != null || widget.rightActions != null)
            _buildActionsBackground(),
          
          // Main content
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final offset = _dragExtent * _animation.value;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: widget.child,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionsBackground() {
    return SizedBox(
      height: double.infinity,
      child: Row(
        children: [
          // Left actions
          if (widget.leftActions != null && _dragExtent > 0) ...[
            ...widget.leftActions!.map((action) => Expanded(
              child: GestureDetector(
                onTap: () {
                  _close();
                  action.onPressed();
                },
                child: Container(
                  color: action.backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.icon,
                        color: action.foregroundColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.label,
                        style: TextStyle(
                          color: action.foregroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
          
          const Spacer(),
          
          // Right actions
          if (widget.rightActions != null && _dragExtent < 0) ...[
            ...widget.rightActions!.map((action) => Expanded(
              child: GestureDetector(
                onTap: () {
                  _close();
                  action.onPressed();
                },
                child: Container(
                  color: action.backgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.icon,
                        color: action.foregroundColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.label,
                        style: TextStyle(
                          color: action.foregroundColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  void _handleDragStart(DragStartDetails details) {
    _controller.stop();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta!;
    _maxExtent = context.size!.width;
    
    setState(() {
      _dragExtent += delta;
      _dragExtent = _dragExtent.clamp(-_maxExtent * 0.7, _maxExtent * 0.7);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    final threshold = _maxExtent * widget.threshold;
    
    if (velocity.abs() > 300 || _dragExtent.abs() > threshold) {
      // Open
      _open();
      HapticFeedback.lightImpact();
    } else {
      // Close
      _close();
    }
  }

  void _open() {
    setState(() {
      if (_dragExtent > 0 && widget.leftActions != null) {
        _dragExtent = _maxExtent * 0.5;
      } else if (_dragExtent < 0 && widget.rightActions != null) {
        _dragExtent = -_maxExtent * 0.5;
      }
    });
    _controller.forward();
  }

  void _close() {
    setState(() {
      _dragExtent = 0.0;
    });
    _controller.forward();
  }
}

class SwipeAction {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const SwipeAction({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });
}

// Pull-to-refresh wrapper for mobile
class MobilePullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String refreshText;

  const MobilePullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshText = 'Desliza para actualizar',
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

// Long press context menu for mobile
class MobileLongPressMenu extends StatelessWidget {
  final Widget child;
  final List<ContextMenuAction> actions;

  const MobileLongPressMenu({
    super.key,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: child,
    );
  }

  void _showContextMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            ...actions.map((action) => ListTile(
              leading: Icon(action.icon),
              title: Text(action.title),
              subtitle: action.subtitle != null ? Text(action.subtitle!) : null,
              onTap: () {
                Navigator.pop(context);
                action.onPressed();
              },
            )),
          ],
        ),
      ),
    );
  }
}

class ContextMenuAction {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onPressed;

  const ContextMenuAction({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onPressed,
  });
}

// Mobile-optimized drag handles
class MobileDragHandle extends StatelessWidget {
  final VoidCallback? onTap;
  final String? tooltip;

  const MobileDragHandle({
    super.key,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.drag_indicator,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// Haptic feedback helper
class HapticHelper {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }
  
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
  
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
  
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}

// Touch-friendly button sizes
class TouchTarget {
  static const double minSize = 44.0;
  static const EdgeInsets padding = EdgeInsets.all(12.0);
  static const EdgeInsets margin = EdgeInsets.all(8.0);
}