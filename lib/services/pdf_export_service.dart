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
    
    final pdf = pw.Document();
    
    // Use built-in fonts for web compatibility
    final fontData = pw.Font.helvetica();
    final boldFontData = pw.Font.helveticaBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(72), // 1 inch margins
        build: (context) => [
          // Title
          pw.Header(
            level: 0,
            child: pw.Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              style: pw.TextStyle(
                font: boldFontData,
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
                  'Created: ${_formatDate(note.createdAt)}',
                  style: pw.TextStyle(
                    font: fontData,
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Last Modified: ${_formatDate(note.updatedAt)}',
                  style: pw.TextStyle(
                    font: fontData,
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
              font: fontData,
              fontSize: 12,
              lineSpacing: 1.5,
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: fontData,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ),
    );
    
    // Save the PDF
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  Future<void> sharePDF(Note note) async {
    if (kIsWeb) {
      throw UnsupportedError('Share PDF not supported on web');
    }
    final pdfBytes = await generatePDFBytes(note);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}.pdf',
    );
  }

  Future<void> printPDF(Note note) async {
    if (kIsWeb) {
      throw UnsupportedError('Print PDF not supported on web');
    }
    final pdfBytes = await generatePDFBytes(note);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  Future<Uint8List> generatePDFBytes(Note note) async {
    final pdf = pw.Document();
    // Use built-in fonts for web compatibility - no external font loading
    final fontData = pw.Font.helvetica();
    final boldFontData = pw.Font.helveticaBold();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(72),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              note.title.isEmpty ? 'Untitled' : note.title,
              style: pw.TextStyle(
                font: boldFontData,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            _convertContentToText(note.content),
            style: pw.TextStyle(
              font: fontData,
              fontSize: 12,
              lineSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
    
    return pdf.save();
  }

  String _convertContentToText(List<dynamic> content) {
    if (content.isEmpty) return 'No content';
    
    // This is a simplified conversion from Quill delta to text
    // In a real implementation, you'd want to properly parse the delta format
    try {
      final buffer = StringBuffer();
      for (final op in content) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert'].toString());
        }
      }
      return buffer.toString().isEmpty ? 'No content' : buffer.toString();
    } catch (e) {
      return content.toString();
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file names
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}