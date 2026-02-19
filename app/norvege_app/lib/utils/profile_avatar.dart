import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'app_logger.dart';
import '../theme.dart';

class ProfileAvatar extends StatefulWidget {
  final double radius;
  final String? initialImageUrl;
  final Function(File)? onImageSelected;

  const ProfileAvatar({
    super.key,
    this.radius = 60.0,
    this.initialImageUrl,
    this.onImageSelected,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // --- 1. LA NOUVELLE FONCTION DE SÉLECTION ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100, // On prend l'originale pour l'instant
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        // On calcule le poids en Méga-octets (Mo)
        int sizeInBytes = await file.length();
        double sizeInMb = sizeInBytes / (1024 * 1024);

        // Si l'image fait plus de 1 Mo
        if (sizeInMb > 1.0) {
          // On affiche le pop-up
          if (!mounted) return;
          bool? shouldCompress = await _showSizeDialog(context, sizeInMb);

          if (!mounted) return; // ← Vérifier que le widget est toujours monté

          if (shouldCompress == true) {
            // Option 1 : Réduire (On compresse l'image)
            file = await _compressImage(file);
          } else {
            // Option 2 : Changer (On relance le menu du bas)
            if (mounted) _showPickerOptions(context);
            return;
          }
        }

        // On valide l'image (compressée ou déjà légère)
        setState(() {
          _selectedImage = file;
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_selectedImage!);
        }
      }
    } catch (e) {
      AppLogger.error('Erreur sélection image : $e');
    }
  }

  // --- 2. LE POP-UP DE CHOIX ---
  Future<bool?> _showSizeDialog(BuildContext context, double sizeInMb) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Image trop lourde"),
        content: Text(
          "Votre image fait ${sizeInMb.toStringAsFixed(1)} Mo.\n\nLa limite est de 1 Mo. Voulez-vous que l'application la réduise automatiquement, ou préférez-vous en choisir une autre ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // Retourne 'false'
            child: const Text("Changer", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), // Retourne 'true'
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.vibrantOrange,
            ),
            child: const Text("Réduire", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 3. LA FONCTION DE COMPRESSION ---
  Future<File> _compressImage(File file) async {
    // On crée un nouveau nom de fichier temporaire
    final targetPath = file.path.replaceAll(
      RegExp(r'\.\w+$'),
      '_compressed.jpg',
    );

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 60, // On baisse la qualité à 60% (suffisant pour un avatar)
    );

    return result != null ? File(result.path) : file;
  }

  // 4. Le petit menu qui s'ouvre par le bas
  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Changer la photo de profil",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepBlue,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_rounded,
                  color: AppColors.vibrantOrange,
                ),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop(); // On ferme le menu
                  _pickImage(ImageSource.camera); // On lance la caméra
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_rounded,
                  color: AppColors.vibrantOrange,
                ),
                title: const Text('Choisir dans la galerie'),
                onTap: () {
                  Navigator.of(context).pop(); // On ferme le menu
                  _pickImage(ImageSource.gallery); // On lance la galerie
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 3. On appelle le menu au lieu de lancer directement la galerie
      onTap: () => _showPickerOptions(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.softGray,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!) as ImageProvider
                : (widget.initialImageUrl != null
                      ? NetworkImage(widget.initialImageUrl!)
                      : null),
            child: _selectedImage == null && widget.initialImageUrl == null
                ? Icon(Icons.person, size: widget.radius, color: Colors.white)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.vibrantOrange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
