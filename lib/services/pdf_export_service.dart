import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class PDFExportService {
  Future<String> exportNoteToPDF(Note note) async {
    // For web, this method shouldn't be called. Use generatePDFBytes() instead.
    if (kIsWeb) {
      throw UnsupportedError('Use generatePDFBytes() for web downloads');
    }

    try {
      final pdfBytes = await generatePDFBytes(note);

      // Save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting PDF: $e');
      throw Exception('Error al exportar PDF: ${e.toString()}');
    }
  }

  Future<void> sharePDF(Note note) async {
    try {
      final pdfBytes = await generatePDFBytes(note);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}.pdf',
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      throw Exception('Error al compartir PDF: ${e.toString()}');
    }
  }

  Future<void> printPDF(Note note) async {
    try {
      final pdfBytes = await generatePDFBytes(note);
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      debugPrint('Error printing PDF: $e');
      throw Exception('Error al imprimir PDF: ${e.toString()}');
    }
  }

  Future<Uint8List> generatePDFBytes(Note note) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(72), // 1 inch margins
          build: (context) => [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                note.title.isEmpty ? 'Sin título' : note.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),

            pw.SizedBox(height: 20),

            // Metadata
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Creado: ${_formatDate(note.createdAt)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Modificado: ${_formatDate(note.updatedAt)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // Content
            pw.Text(
              _convertContentToText(note.content),
              style: pw.TextStyle(
                fontSize: 12,
                lineSpacing: 1.5,
              ),
            ),
          ],
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      );

      return pdf.save();
    } catch (e) {
      debugPrint('Error generating PDF bytes: $e');
      throw Exception('Error al generar PDF: ${e.toString()}');
    }
  }

  String _convertContentToText(List<dynamic> content) {
    if (content.isEmpty) return 'Sin contenido';

    try {
      final buffer = StringBuffer();
      for (final op in content) {
        if (op is Map && op.containsKey('insert')) {
          final text = op['insert'].toString();
          // Clean up the text
          if (text.trim().isNotEmpty && text != '\n') {
            buffer.write(text);
          }
        }
      }
      final result = buffer.toString().trim();
      return result.isEmpty ? 'Sin contenido' : result;
    } catch (e) {
      debugPrint('Error converting content: $e');
      return 'Error al procesar el contenido';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  // Web-specific download function
  Future<void> downloadPDFForWeb(Note note) async {
    if (!kIsWeb) {
      throw UnsupportedError('This method is only for web');
    }

    try {
      final pdfBytes = await generatePDFBytes(note);
      final fileName = '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}.pdf';

      // Use the printing package's download functionality
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );
    } catch (e) {
      debugPrint('Error downloading PDF for web: $e');
      throw Exception('Error al descargar PDF: ${e.toString()}');
    }
  }
}