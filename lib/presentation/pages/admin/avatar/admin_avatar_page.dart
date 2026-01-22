import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_state.dart';

// Import 3 file lainnya
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_widgets.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_mobile.dart';
import 'package:quizify_proyek_mmp/presentation/pages/admin/avatar/admin_avatar_desktop.dart';

// --- KONFIGURASI DICEBEAR (Tetap di sini karena berhubungan dengan logic dialog) ---
final List<Map<String, String>> _diceBearStylesMetadata = [
  {'id': 'adventurer', 'name': 'Adventurer', 'desc': 'RPG Character Style'},
  {
    'id': 'adventurer-neutral',
    'name': 'Adventurer Neutral',
    'desc': 'No Background',
  },
  {'id': 'avataaars', 'name': 'Avataaars', 'desc': 'Modern Flat Design'},
  {
    'id': 'avataaars-neutral',
    'name': 'Avataaars Neutral',
    'desc': 'No Background',
  },
  {'id': 'lorelei', 'name': 'Lorelei', 'desc': 'Anime / Digital Art'},
  {'id': 'lorelei-neutral', 'name': 'Lorelei Neutral', 'desc': 'No Background'},
  {'id': 'big-ears', 'name': 'Big Ears', 'desc': 'Cute & Unique Ears'},
  {'id': 'bottts', 'name': 'Bottts', 'desc': 'Mechanical Droids'},
  {'id': 'fun-emoji', 'name': 'Fun Emoji', 'desc': 'Expressive Emojis'},
  {'id': 'micah', 'name': 'Micah', 'desc': 'Minimalist Portraits'},
  {'id': 'personas', 'name': 'Personas', 'desc': 'Playful Avatars'},
  {'id': 'pixel-art', 'name': 'Pixel Art', 'desc': '8-Bit Retro Style'},
];

final Map<String, Map<String, List<String>>> _diceBearConfigs = {
  'adventurer': {
    'smile': ['mouth=variant03'],
    'bigSmile': ['mouth=variant05'],
    'bald': ['hairProbability=0'],
    'glasses': ['accessories=glasses'],
  },
  'adventurer-neutral': {
    'smile': ['mouth=variant03'],
    'bigSmile': ['mouth=variant05'],
    'bald': ['hairProbability=0'],
    'glasses': ['accessories=glasses'],
  },
  'avataaars': {
    'smile': ['mouth=smile'],
    'bald': ['top=noHair'],
    'glasses': ['accessories=prescription01', 'accessoriesProbability=100'],
  },
  'avataaars-neutral': {
    'smile': ['mouth=smile'],
    'bald': ['top=noHair'],
    'glasses': ['accessories=prescription01', 'accessoriesProbability=100'],
  },
  'lorelei': {
    'smile': ['mouth=happy01'],
    'bigSmile': ['mouth=laugh01'],
    'glasses': ['accessories=glasses01', 'accessoriesProbability=100'],
  },
  'lorelei-neutral': {
    'smile': ['mouth=happy01'],
    'bigSmile': ['mouth=laugh01'],
    'glasses': ['accessories=glasses01', 'accessoriesProbability=100'],
  },
};

class AdminAvatarPage extends StatefulWidget {
  const AdminAvatarPage({super.key});

  @override
  State<AdminAvatarPage> createState() => _AdminAvatarPageState();
}

class _AdminAvatarPageState extends State<AdminAvatarPage> {
  String _selectedRarity = 'All';
  String _sortBy = 'Lowest Price';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminAvatarBloc(context.read<AdminRepositoryImpl>())
            ..add(LoadAvatarsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Avatar Management',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkAzure,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Panggil FilterBar dari file widgets
            AdminAvatarFilterBar(
              selectedRarity: _selectedRarity,
              sortBy: _sortBy,
              onRarityChanged: (val) => setState(() => _selectedRarity = val),
              onSortChanged: (val) => setState(() => _sortBy = val),
            ),

            Expanded(
              child: BlocConsumer<AdminAvatarBloc, AdminAvatarState>(
                listener: (context, state) {
                  if (state is AvatarError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AvatarLoading)
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkAzure,
                      ),
                    );
                  if (state is AvatarError && state is! AvatarLoaded)
                    return Center(child: Text("Error: ${state.message}"));
                  if (state is AvatarLoaded) {
                    final processedList = _applyFilterAndSort(state.allAvatars);
                    if (processedList.isEmpty)
                      return const Center(child: Text("No avatars found."));

                    // --- LAYOUT BUILDER UNTUK RESPONSIVE ---
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 900) {
                          // Panggil Desktop View
                          return AdminAvatarDesktopView(
                            avatars: processedList,
                            onEdit: (avatar) => _showAvatarDialog(
                              context,
                              avatar: avatar,
                              bloc: context.read<AdminAvatarBloc>(),
                            ),
                            onToggle: (id) => context
                                .read<AdminAvatarBloc>()
                                .add(ToggleAvatarEvent(int.parse(id))),
                          );
                        } else {
                          // Panggil Mobile View
                          return AdminAvatarMobileView(
                            avatars: processedList,
                            onEdit: (avatar) => _showAvatarDialog(
                              context,
                              avatar: avatar,
                              bloc: context.read<AdminAvatarBloc>(),
                            ),
                            onToggle: (id) => context
                                .read<AdminAvatarBloc>()
                                .add(ToggleAvatarEvent(int.parse(id))),
                          );
                        }
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            final bloc = ctx.read<AdminAvatarBloc>();
            return FloatingActionButton.extended(
              onPressed: () => _showAvatarDialog(ctx, bloc: bloc),
              backgroundColor: AppColors.darkAzure,
              elevation: 4,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                "NEW AVATAR",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper Functions
  List<AvatarModel> _applyFilterAndSort(List<AvatarModel> list) {
    List<AvatarModel> filtered = List.from(list);
    if (_selectedRarity != 'All') {
      filtered = filtered
          .where((a) => a.rarity.toLowerCase() == _selectedRarity.toLowerCase())
          .toList();
    }
    if (_sortBy == 'Lowest Price') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }
    return filtered;
  }

  // --- LOGIC DIALOG (DiceBear + Image Upload) ---
  void _showAvatarDialog(
    BuildContext context, {
    AvatarModel? avatar,
    required AdminAvatarBloc bloc,
  }) {
    final isEdit = avatar != null;
    final nameCtrl = TextEditingController(text: isEdit ? avatar.name : '');
    final urlCtrl = TextEditingController(text: isEdit ? avatar.imageUrl : '');
    final priceCtrl = TextEditingController(
      text: isEdit ? avatar.price.toInt().toString() : '',
    );
    String rarity = isEdit ? avatar.rarity : 'common';

    String selectedDiceBearStyle = 'adventurer';
    String imageSource = 'dicebear'; // 'dicebear', 'url', or 'upload'
    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    Map<String, bool> diceBearFeatures = {
      'smile': false,
      'bigSmile': false,
      'bald': false,
      'glasses': false,
    };

    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          // 1. AMBIL UKURAN LAYAR
          double screenWidth = MediaQuery.of(context).size.width;

          // 2. TENTUKAN LEBAR DIALOG
          // Jika Desktop (>900), set lebar 700px. Jika Mobile, 90% dari layar.
          double dialogWidth = screenWidth > 900 ? 700 : screenWidth * 0.9;

          Future<void> pickImage() async {
            try {
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              );
              if (image != null) {
                setState(() {
                  selectedImage = image;
                  imageSource = 'upload';
                });
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error picking image: $e')),
              );
            }
          }

          void updateDiceBearUrl() {
            if (imageSource != 'dicebear') return;
            final seed = nameCtrl.text.isEmpty ? 'seed' : nameCtrl.text;
            final config = _diceBearConfigs[selectedDiceBearStyle];
            final Map<String, List<String>> queryParams = {};

            if (config != null) {
              diceBearFeatures.forEach((featureKey, isActive) {
                if (isActive && config.containsKey(featureKey)) {
                  for (String rawParam in config[featureKey]!) {
                    final parts = rawParam.split('=');
                    if (parts.length == 2) {
                      final key = parts[0];
                      final value = parts[1];
                      if (!queryParams.containsKey(key)) queryParams[key] = [];
                      queryParams[key]!.add(value);
                    }
                  }
                }
              });
            }
            final List<String> finalParams = [];
            queryParams.forEach((key, values) {
              finalParams.add('$key=${values.join(',')}');
            });
            final query = finalParams.isEmpty
                ? ''
                : '&${finalParams.join('&')}';
            urlCtrl.text =
                'https://api.dicebear.com/7.x/$selectedDiceBearStyle/svg?seed=$seed$query';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              isEdit ? "Edit Avatar" : "New Avatar",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            // 3. WRAP CONTENT DENGAN CONTAINER LEBAR TERTENTU
            content: Container(
              width: dialogWidth, // <--- INI KUNCINYA AGAR LEBAR
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildAvatarPreview(
                      imageSource == 'upload' ? '' : (urlCtrl.text),
                      selectedImage: selectedImage,
                    ),
                    const SizedBox(height: 20),

                    // --- Source Selection (3 options) ---
                    _buildSourceSelector(
                      imageSource: imageSource,
                      onChanged: (val) => setState(() {
                        imageSource = val;
                        if (val == 'dicebear') updateDiceBearUrl();
                      }),
                    ),

                    const SizedBox(height: 16),
                    _buildField(
                      nameCtrl,
                      "Avatar Name",
                      Icons.face_rounded,
                      onChanged: (val) {
                        if (imageSource == 'dicebear')
                          setState(() => updateDiceBearUrl());
                      },
                    ),
                    const SizedBox(height: 12),

                    if (imageSource == 'dicebear') ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showStylePicker(
                          context,
                          selectedDiceBearStyle,
                          (newStyle) {
                            setState(() {
                              selectedDiceBearStyle = newStyle;
                              diceBearFeatures.updateAll((_, __) => false);
                              updateDiceBearUrl();
                            });
                          },
                        ),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            "DiceBear Style",
                            Icons.palette_rounded,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getStyleName(selectedDiceBearStyle),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkAzure,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDynamicDiceBearFeatures(
                        selectedDiceBearStyle,
                        diceBearFeatures,
                        (key, value) {
                          setState(() {
                            diceBearFeatures[key] = value;
                            updateDiceBearUrl();
                          });
                        },
                      ),
                    ] else if (imageSource == 'url') ...[
                      _buildField(urlCtrl, "Image URL", Icons.link_rounded),
                    ] else if (imageSource == 'upload') ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isSaving ? null : pickImage,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                selectedImage == null
                                    ? 'Choose Image'
                                    : 'Change Image',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkAzure,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),
                          ),
                          if (selectedImage != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  setState(() => selectedImage = null),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              tooltip: 'Clear Selection',
                            ),
                          ],
                        ],
                      ),
                      if (selectedImage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Selected: ${selectedImage!.name}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 12),

                    // --- OPTIONAL: JIKA DESKTOP, TARUH PRICE & RARITY SEBARIS ---
                    if (screenWidth > 600)
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              priceCtrl,
                              "Price",
                              Icons.monetization_on_rounded,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildRarityDropdown(
                              rarity,
                              (val) => setState(() => rarity = val!),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      // Tampilan Mobile (Atas Bawah)
                      _buildField(
                        priceCtrl,
                        "Price",
                        Icons.monetization_on_rounded,
                        isNumber: true,
                      ),
                      const SizedBox(height: 12),
                      _buildRarityDropdown(
                        rarity,
                        (val) => setState(() => rarity = val!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () {
                        final price = double.tryParse(priceCtrl.text) ?? 0;
                        final fileToUpload = imageSource == 'upload'
                            ? selectedImage
                            : null;

                        // Basic Validation
                        if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Name and Price are required'),
                            ),
                          );
                          return;
                        }

                        if (imageSource == 'upload' &&
                            selectedImage == null &&
                            urlCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select an image to upload'),
                            ),
                          );
                          return;
                        }

                        setState(() => isSaving = true);

                        if (isEdit) {
                          bloc.add(
                            EditAvatarEvent(
                              avatar.id,
                              nameCtrl.text,
                              urlCtrl.text,
                              price,
                              rarity,
                              file: fileToUpload,
                            ),
                          );
                        } else {
                          bloc.add(
                            AddAvatarEvent(
                              nameCtrl.text,
                              urlCtrl.text,
                              price,
                              rarity,
                              file: fileToUpload,
                            ),
                          );
                        }
                        Navigator.pop(ctx);
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Avatar"),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- EXTRACTED WIDGETS & HELPERS ---

// --- HELPERS STATIC ---

String _getStyleName(String id) {
  final style = _diceBearStylesMetadata.firstWhere(
    (s) => s['id'] == id,
    orElse: () => {'name': id.toUpperCase()},
  );
  return style['name']!;
}

Widget _buildSourceSelector({
  required String imageSource,
  required Function(String) onChanged,
}) {
  return Row(
    children: [
      Expanded(
        child: ChoiceChip(
          label: const Text("DiceBear"),
          selected: imageSource == 'dicebear',
          onSelected: (val) => onChanged('dicebear'),
          selectedColor: AppColors.darkAzure.withOpacity(0.2),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ChoiceChip(
          label: const Text("URL"),
          selected: imageSource == 'url',
          onSelected: (val) => onChanged('url'),
          selectedColor: AppColors.darkAzure.withOpacity(0.2),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ChoiceChip(
          label: const Text("Upload"),
          selected: imageSource == 'upload',
          onSelected: (val) => onChanged('upload'),
          selectedColor: AppColors.darkAzure.withOpacity(0.2),
        ),
      ),
    ],
  );
}

InputDecoration _inputDecoration(String label, IconData icon) =>
    InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
Widget _buildField(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  bool isNumber = false,
  Function(String)? onChanged,
}) => TextField(
  controller: ctrl,
  onChanged: onChanged,
  keyboardType: isNumber ? TextInputType.number : TextInputType.text,
  decoration: _inputDecoration(label, icon),
);
Widget _buildRarityDropdown(String currentValue, Function(String?) onChanged) =>
    DropdownButtonFormField<String>(
      value: currentValue,
      decoration: _inputDecoration("Rarity", Icons.star_rounded),
      items: const ['common', 'rare', 'epic', 'legendary']
          .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
          .toList(),
      onChanged: onChanged,
    );

Widget _buildDynamicDiceBearFeatures(
  String currentStyle,
  Map<String, bool> features,
  void Function(String key, bool value) onChanged,
) {
  final config = _diceBearConfigs[currentStyle];
  if (config == null || config.isEmpty) return const SizedBox();
  List<Widget> checkboxes = [];
  void addIfSupported(String key, String label) {
    if (config.containsKey(key)) {
      checkboxes.add(
        CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: features[key] ?? false,
          activeColor: AppColors.darkAzure,
          onChanged: (v) => onChanged(key, v ?? false),
        ),
      );
    }
  }

  addIfSupported('smile', 'Smile');
  addIfSupported('bigSmile', 'Big Smile / Laugh');
  addIfSupported('bald', 'Bald / No Hair');
  addIfSupported('glasses', 'Glasses');
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Customize Features",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      ...checkboxes,
    ],
  );
}

void _showStylePicker(
  BuildContext context,
  String currentStyle,
  Function(String) onSelected,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Avatar Style",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _diceBearStylesMetadata.length,
                itemBuilder: (context, index) {
                  final s = _diceBearStylesMetadata[index];
                  final isSelected = currentStyle == s['id'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.darkAzure
                          : Colors.grey[100],
                      child: Icon(
                        Icons.style,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    title: Text(
                      s['name']!,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(s['desc']!),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.darkAzure,
                          )
                        : null,
                    onTap: () {
                      onSelected(s['id']!);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
