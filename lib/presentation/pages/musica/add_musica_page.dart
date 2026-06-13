import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../state/cancion_provider.dart';

class AddMusicaPage extends StatefulWidget {
  const AddMusicaPage({super.key});

  @override
  State<AddMusicaPage> createState() => _AddMusicaPageState();
}

class _AddMusicaPageState extends State<AddMusicaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _detalleCtrl = TextEditingController();
  
  PlatformFile? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _detalleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint('[PICKER] >> Error al seleccionar archivo: $e');
      _showSnackBar('Error al acceder al almacenamiento', isError: true);
    }
  }

  Future<void> _saveCancion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null || _selectedFile!.path == null) {
      _showSnackBar('Debe seleccionar un archivo de audio (.mp3, .wav, etc.)', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    final cancionProvider = Provider.of<CancionProvider>(context, listen: false);
    
    // Convertir el archivo seleccionado a XFile para el multipart
    final xFile = XFile(_selectedFile!.path!);

    final success = await cancionProvider.uploadCancion(
      archivo: xFile,
      nombre: _nombreCtrl.text.trim(),
      detalle: _detalleCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (success) {
      _showSnackBar('Música importada y guardada correctamente', isError: false);
      Navigator.pop(context); // Volver al listado
    } else {
      _showSnackBar(cancionProvider.errorMessage ?? 'Error al subir la canción', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Añadir Música',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Importa tu canción 🎵',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Completa los datos y selecciona el archivo de audio.',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Campo Nombre
              _buildField(
                controller: _nombreCtrl,
                label: 'Nombre de la canción',
                icon: Icons.music_note_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Detalle
              _buildField(
                controller: _detalleCtrl,
                label: 'Detalle o descripción (opcional)',
                icon: Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Selector de Archivo de Audio
              const Text(
                'Archivo de audio',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildFileSelector(),
              const SizedBox(height: 40),

              // Botón Guardar / Carga
              _isUploading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C6FF7)),
                    )
                  : _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7C6FF7), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF7C6FF7), size: 20),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2A2A4E), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7C6FF7), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildFileSelector() {
    final hasFile = _selectedFile != null;
    final sizeKb = hasFile ? _selectedFile!.size / 1024 : 0.0;
    final sizeStr = sizeKb > 1024
        ? '${(sizeKb / 1024).toStringAsFixed(2)} MB'
        : '${sizeKb.toStringAsFixed(1)} KB';

    return GestureDetector(
      onTap: _pickAudioFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? const Color(0xFF2ECC71) : const Color(0xFF2A2A4E),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              hasFile ? Icons.audiotrack_rounded : Icons.cloud_upload_rounded,
              color: hasFile ? const Color(0xFF2ECC71) : const Color(0xFF7C6FF7),
              size: 44,
            ),
            const SizedBox(height: 14),
            Text(
              hasFile ? _selectedFile!.name : 'Seleccionar archivo de audio',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFile
                  ? 'Tamaño: $sizeStr | Haz clic para cambiar'
                  : 'Soporta MP3, WAV, M4A, etc.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FF7), Color(0xFF5A4FCF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FF7).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _saveCancion,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text(
          'Guardar e Importar Música',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
    );
  }
}
