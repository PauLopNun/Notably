import 'package:flutter/material.dart';

/// Widget that shows visual feedback during drag and drop operations
class DragDropIndicator extends StatelessWidget {
  final bool isDragging;
  final bool isDropTarget;
  final Widget child;
  final VoidCallback? onTap;

  const DragDropIndicator({
    super.key,
    required this.child,
    this.isDragging = false,
    this.isDropTarget = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: _getBorder(context),
          boxShadow: _getShadow(context),
        ),
        transform: _getTransform(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDragging ? 0.7 : 1.0,
          child: child,
        ),
      ),
    );
  }

  Border? _getBorder(BuildContext context) {
    if (isDropTarget) {
      return Border.all(
        color: Theme.of(context).colorScheme.primary,
        width: 2,
      );
    } else if (isDragging) {
      return Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow(BuildContext context) {
    if (isDropTarget) {
      return [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isDragging) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  Matrix4? _getTransform() {
    if (isDropTarget) {
      return Matrix4.identity()..scale(1.02, 1.02, 1.0);
    } else if (isDragging) {
      return Matrix4.identity()..scale(0.98, 0.98, 1.0);
    }
    return null;
  }
}

/// A widget that shows a drop zone indicator between blocks
class DropZoneIndicator extends StatefulWidget {
  final bool isActive;
  final double height;

  const DropZoneIndicator({
    super.key,
    required this.isActive,
    this.height = 4.0,
  });

  @override
  State<DropZoneIndicator> createState() => _DropZoneIndicatorState();
}

class _DropZoneIndicatorState extends State<DropZoneIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  void didUpdateWidget(DropZoneIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height * _animation.value,
          margin: EdgeInsets.symmetric(
            horizontal: 16.0 * _animation.value,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Drag handle widget with improved visual feedback
class DragHandle extends StatefulWidget {
  final bool isSelected;
  final bool isVisible;
  final VoidCallback? onTap;

  const DragHandle({
    super.key,
    required this.isSelected,
    required this.isVisible,
    this.onTap,
  });

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(DragHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected || _isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isVisible ? 1.0 : 0.0,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) {
          setState(() => _isHovered = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          if (!widget.isSelected) {
            _controller.reverse();
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 36,
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: widget.isSelected || _isHovered
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      border: widget.isSelected || _isHovered
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.isSelected || _isHovered ? Icons.open_with : Icons.drag_indicator,
                        key: ValueKey(widget.isSelected || _isHovered),
                        size: 18,
                        color: widget.isSelected || _isHovered
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}