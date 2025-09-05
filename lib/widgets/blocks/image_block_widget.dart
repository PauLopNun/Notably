import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/block.dart';

class ImageBlockWidget extends StatefulWidget {
  final PageBlock block;
  final bool isSelected;
  final VoidCallback? onDelete;

  const ImageBlockWidget({
    super.key,
    required this.block,
    this.isSelected = false,
    this.onDelete,
  });

  @override
  State<ImageBlockWidget> createState() => _ImageBlockWidgetState();
}

class _ImageBlockWidgetState extends State<ImageBlockWidget> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.block.content['url'] as String?;
    final caption = widget.block.content['caption'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: widget.isSelected
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Container(
            constraints: const BoxConstraints(
              minHeight: 120,
              maxHeight: 400,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? _buildImagePlaceholder()
                : _buildImage(imageUrl),
          ),

          // Caption
          if (caption != null && caption.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                caption,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Actions
          if (widget.isSelected) _buildImageActions(),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return InkWell(
      onTap: _isUploading ? null : _pickImage,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: _isUploading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca para subir una imagen',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'o arrastra y suelta aquí',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => SizedBox(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 8),
              Text(
                'Error al cargar la imagen',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar otra imagen'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageActions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Cambiar'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _showCaptionDialog,
            icon: const Icon(Icons.text_fields, size: 16),
            label: const Text('Descripción'),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            tooltip: 'Eliminar imagen',
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        
        // In a real app, you would upload this to your storage service
        // For now, we'll just use a placeholder URL
        final imageUrl = 'https://via.placeholder.com/800x400?text=${Uri.encodeComponent(file.name)}';
        
        // Update block content
        // This would typically be handled by the parent widget
        // For now, we'll just update the local state
        widget.block.content['url'] = imageUrl;
        widget.block.content['fileName'] = file.name;
        widget.block.content['fileSize'] = file.size;
        
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir la imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _showCaptionDialog() async {
    final currentCaption = widget.block.content['caption'] as String? ?? '';
    final controller = TextEditingController(text: currentCaption);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descripción de la imagen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Escribe una descripción...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result != null) {
      widget.block.content['caption'] = result;
      setState(() {});
    }

    controller.dispose();
  }
}