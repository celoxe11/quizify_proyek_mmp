import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quizify_proyek_mmp/core/constants/app_colors.dart';
import 'package:quizify_proyek_mmp/data/models/avatar_model.dart';
import 'package:quizify_proyek_mmp/data/repositories/admin_repository.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_bloc.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_event.dart';
import 'package:quizify_proyek_mmp/presentation/blocs/admin/avatar/admin_avatar_state.dart';

// --- KONFIGURASI DICEBEAR (DATA STATIC) ---

/// Metadata untuk Tampilan di UI (Nama & Deskripsi)
final List<Map<String, String>> _diceBearStylesMetadata = [
  {'id': 'adventurer', 'name': 'Adventurer', 'desc': 'RPG Character Style'},
  {'id': 'adventurer-neutral', 'name': 'Adventurer Neutral', 'desc': 'RPG Style (No Background)'},
  {'id': 'avataaars', 'name': 'Avataaars', 'desc': 'Modern Flat Design'},
  {'id': 'avataaars-neutral', 'name': 'Avataaars Neutral', 'desc': 'Modern Flat (No Background)'},
  {'id': 'big-ears', 'name': 'Big Ears', 'desc': 'Cute & Unique Ears'},
  {'id': 'big-ears-neutral', 'name': 'Big Ears Neutral', 'desc': 'Big Ears (No Background)'},
  {'id': 'bottts', 'name': 'Bottts', 'desc': 'Mechanical Droids'},
  {'id': 'bottts-neutral', 'name': 'Bottts Neutral', 'desc': 'Droids (No Background)'},
  {'id': 'croodles', 'name': 'Croodles', 'desc': 'Abstract Doodles'},
  {'id': 'croodles-neutral', 'name': 'Croodles Neutral', 'desc': 'Doodles (No Background)'},
  {'id': 'fun-emoji', 'name': 'Fun Emoji', 'desc': 'Expressive Emojis'},
  {'id': 'lorelei', 'name': 'Lorelei', 'desc': 'Anime / Digital Art'},
  {'id': 'lorelei-neutral', 'name': 'Lorelei Neutral', 'desc': 'Anime (No Background)'},
  {'id': 'micah', 'name': 'Micah', 'desc': 'Minimalist Portraits'},
  {'id': 'personas', 'name': 'Personas', 'desc': 'Playful Avatars'},
  {'id': 'pixel-art', 'name': 'Pixel Art', 'desc': '8-Bit Retro Style'},
  {'id': 'pixel-art-neutral', 'name': 'Pixel Art Neutral', 'desc': '8-Bit (No Background)'},
  {'id': 'thumbs', 'name': 'Thumbs', 'desc': 'Thumb Characters'},
  {'id': 'identicon', 'name': 'Identicon', 'desc': 'Geometric Pattern'},
  {'id': 'initials', 'name': 'Initials', 'desc': 'Text Initials'},
  {'id': 'shapes', 'name': 'Shapes', 'desc': 'Abstract Shapes'},
];

/// Konfigurasi Parameter API untuk setiap Style
/// Key = Style ID
/// Value = Map fitur yang didukung dan list parameternya
final Map<String, Map<String, List<String>>> _diceBearConfigs = {
  'adventurer': {
    'smile': ['mouth=variant03'], // Smiling
    'bigSmile': ['mouth=variant05'], // Laughing/Wide
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
  'personas': {
    'bald': ['hair=bald'], // Personas support bald specific variant
    'glasses': ['accessories=glasses'],
  },
  'big-ears': {
    'smile': ['mouth=propitious'],
    'glasses': ['accessories=glasses'],
  },
  'big-ears-neutral': {
    'smile': ['mouth=propitious'],
    'glasses': ['accessories=glasses'],
  },
  'micah': {
    'smile': ['mouth=smile'],
    'glasses': ['glassesProbability=100'],
  },
  'bottts': {
     // Bottts tidak punya 'mouth' atau 'hair' standar manusia, jadi kosongkan
     // atau tambahkan parameter khusus robot jika ada.
  },
  // Style lain yang tidak ada di list ini dianggap hanya support Seed (Nama)
};

// --- MAIN PAGE ---

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
      create: (context) => AdminAvatarBloc(
        context.read<AdminRepositoryImpl>(),
      )..add(LoadAvatarsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Avatar Management',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.darkAzure,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildControlBar(),
            Expanded(
              child: BlocBuilder<AdminAvatarBloc, AdminAvatarState>(
                builder: (context, state) {
                  if (state is AvatarLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.darkAzure));
                  }
                  if (state is AvatarError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }
                  if (state is AvatarLoaded) {
                    final processedList = _applyFilterAndSort(state.allAvatars);
                    if (processedList.isEmpty) {
                      return const Center(child: Text("No avatars found."));
                    }

                    // RESPONSIVE LAYOUT
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth > 900
                            ? 4
                            : (constraints.maxWidth > 600 ? 3 : 2);

                        return GridView.builder(
                          padding: const EdgeInsets.all(24),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: processedList.length,
                          itemBuilder: (context, index) =>
                              _AvatarCard(avatar: processedList[index]),
                        );
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
              label: const Text("NEW AVATAR",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['All', 'Common', 'Rare', 'Epic', 'Legendary'].map((rarity) {
                final isSelected = _selectedRarity == rarity;
                Color chipColor = isSelected ? _getRarityColor(rarity) : Colors.grey[100]!;
                Color textColor = isSelected ? Colors.white : Colors.grey[600]!;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(rarity),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedRarity = rarity),
                    selectedColor: chipColor,
                    backgroundColor: Colors.grey[100],
                    labelStyle: TextStyle(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sorting by:", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                PopupMenuButton<String>(
                  onSelected: (val) => setState(() => _sortBy = val),
                  child: Row(
                    children: [
                      Text(_sortBy,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: AppColors.darkAzure)),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.darkAzure),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Lowest Price', child: Text('Lowest Price')),
                    const PopupMenuItem(value: 'Highest Price', child: Text('Highest Price')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'rare': return Colors.blue;
      case 'epic': return Colors.purple;
      case 'legendary': return Colors.amber;
      default: return AppColors.darkAzure;
    }
  }

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

  // --- DIALOG LOGIC ---
  void _showAvatarDialog(BuildContext context,
      {AvatarModel? avatar, required AdminAvatarBloc bloc}) {
    final isEdit = avatar != null;
    final nameCtrl = TextEditingController(text: isEdit ? avatar.name : '');
    final urlCtrl = TextEditingController(text: isEdit ? avatar.imageUrl : '');
    final priceCtrl = TextEditingController(text: isEdit ? avatar.price.toInt().toString() : '');
    String rarity = isEdit ? avatar.rarity : 'common';

    // State DiceBear Local
    String selectedDiceBearStyle = 'adventurer';
    bool isUsingDiceBear = false;
    
    // Fitur Checkbox state
    Map<String, bool> diceBearFeatures = {
      'smile': false,
      'bigSmile': false,
      'bald': false,
      'glasses': false,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          
          // --- FUNGSI UPDATE URL YANG BARU DAN DINAMIS ---
          void updateDiceBearUrl() {
            if (!isUsingDiceBear) return;

            final seed = nameCtrl.text.isEmpty ? 'seed' : nameCtrl.text;
            
            // Ambil config untuk style yang sedang dipilih
            final config = _diceBearConfigs[selectedDiceBearStyle];
            
            final params = <String>[];

            if (config != null) {
              // Loop setiap fitur (smile, bald, dll)
              diceBearFeatures.forEach((featureKey, isActive) {
                // Jika fitur dicentang user AND didukung oleh config style ini
                if (isActive && config.containsKey(featureKey)) {
                  // Tambahkan parameter API yang sesuai
                  params.addAll(config[featureKey]!);
                }
              });
            }

            final query = params.isEmpty ? '' : '&${params.join('&')}';
            urlCtrl.text = 'https://api.dicebear.com/7.x/$selectedDiceBearStyle/svg?seed=$seed$query';
          }
          // -----------------------------------------------

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(isEdit ? "Edit Avatar" : "New Avatar",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PREVIEW IMAGE
                  _buildAvatarPreview(urlCtrl.text, selectedImage: null),
                  const SizedBox(height: 20),

                  // SWITCH MODE
                  _buildSourceSwitch(
                    isUsingDiceBear: isUsingDiceBear,
                    onChanged: (val) => setState(() {
                      isUsingDiceBear = val;
                      if (val) updateDiceBearUrl();
                    }),
                  ),
                  const SizedBox(height: 16),

                  // INPUT NAMA
                  _buildField(nameCtrl, "Avatar Name", Icons.face_rounded,
                      onChanged: (val) {
                    if (isUsingDiceBear) {
                      setState(() => updateDiceBearUrl());
                    }
                  }),
                  const SizedBox(height: 12),

                  // DICEBEAR OPTIONS
                  if (isUsingDiceBear) ...[
                    const SizedBox(height: 12),
                    
                    // Style Picker dengan Data Lengkap
                    InkWell(
                      onTap: () => _showStylePicker(context, selectedDiceBearStyle,
                          (newStyle) {
                        setState(() {
                          selectedDiceBearStyle = newStyle;
                          // Reset checkbox saat ganti style agar tidak rancu
                          diceBearFeatures.updateAll((key, value) => false);
                          updateDiceBearUrl();
                        });
                      }),
                      child: InputDecorator(
                        decoration: _inputDecoration("DiceBear Style", Icons.palette_rounded),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getStyleName(selectedDiceBearStyle),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: AppColors.darkAzure)),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    
                    // Dynamic Checkboxes
                    // Hanya render checkbox jika Style mendukung fitur tersebut
                    _buildDynamicDiceBearFeatures(
                      selectedDiceBearStyle,
                      diceBearFeatures,
                      (key, value) {
                        setState(() {
                          diceBearFeatures[key] = value;
                          updateDiceBearUrl();
                        });
                      }
                    ),

                  ] else ...[
                    _buildField(urlCtrl, "Image URL", Icons.link_rounded),
                  ],

                  const SizedBox(height: 12),
                  _buildField(priceCtrl, "Price", Icons.monetization_on_rounded, isNumber: true),

                  const SizedBox(height: 12),
                  _buildRarityDropdown(rarity, (val) => setState(() => rarity = val!)),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  if (isEdit) {
                    bloc.add(EditAvatarEvent(avatar.id, nameCtrl.text, urlCtrl.text, price, rarity));
                  } else {
                    bloc.add(AddAvatarEvent(nameCtrl.text, urlCtrl.text, price, rarity));
                  }
                  Navigator.pop(ctx);
                },
                child: const Text("Save Avatar"),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- EXTRACTED WIDGETS & HELPERS ---

class _AvatarCard extends StatefulWidget {
  final AvatarModel avatar;
  const _AvatarCard({required this.avatar});

  @override
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color rarityColor;
    switch (widget.avatar.rarity.toLowerCase()) {
      case 'rare': rarityColor = Colors.blue; break;
      case 'epic': rarityColor = Colors.purple; break;
      case 'legendary': rarityColor = Colors.amber; break;
      default: rarityColor = Colors.grey;
    }

    final displayImageUrl = widget.avatar.imageUrl.replaceAll('/svg', '/png');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(_isHovered ? 0.2 : 0.05),
              blurRadius: _isHovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
              color: _isHovered ? rarityColor.withOpacity(0.5) : Colors.transparent,
              width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: rarityColor.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.network(
                              displayImageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(widget.avatar.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(widget.avatar.rarity.toUpperCase(),
                                    style: TextStyle(color: rarityColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Text("Rp ${widget.avatar.price.toInt()}",
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8, right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (val) {
                    final pageState = context.findAncestorStateOfType<_AdminAvatarPageState>();
                    final bloc = context.read<AdminAvatarBloc>();
                    if (val == 'edit') {
                       if(pageState != null) pageState._showAvatarDialog(context, avatar: widget.avatar, bloc: bloc);
                    }
                    if (val == 'toggle') bloc.add(ToggleAvatarEvent(widget.avatar.id));
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                          widget.avatar.isActive ? "Archive" : "Restore",
                          style: TextStyle(color: widget.avatar.isActive ? Colors.red : Colors.green)),
                    ),
                  ],
                ),
              ),
              if (!widget.avatar.isActive)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: const Center(
                      child: Chip(
                        label: Text("ARCHIVED", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HELPERS STATIC ---

String _getStyleName(String id) {
  final style = _diceBearStylesMetadata.firstWhere(
    (s) => s['id'] == id, 
    orElse: () => {'name': id.toUpperCase()} // Fallback
  );
  return style['name']!;
}

Widget _buildAvatarPreview(String imageUrl, {XFile? selectedImage}) {
  return Container(
    height: 120,
    width: 120,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.darkAzure.withOpacity(0.3)),
    ),
    child: selectedImage != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: kIsWeb
                ? Image.network(selectedImage.path)
                : Image.file(File(selectedImage.path)),
          )
        : (imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl.replaceAll('/svg', '/png'),
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              )
            : const Icon(Icons.cloud_upload_rounded, size: 40, color: AppColors.darkAzure)),
  );
}

Widget _buildSourceSwitch({required bool isUsingDiceBear, required Function(bool) onChanged}) {
  return Row(
    children: [
      Expanded(
        child: ChoiceChip(
          label: const Text("Manual URL"),
          selected: !isUsingDiceBear,
          onSelected: (val) => onChanged(false),
          selectedColor: AppColors.darkAzure.withOpacity(0.2),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: ChoiceChip(
          label: const Text("DiceBear API"),
          selected: isUsingDiceBear,
          onSelected: (val) => onChanged(true),
          selectedColor: AppColors.darkAzure.withOpacity(0.2),
        ),
      ),
    ],
  );
}

InputDecoration _inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.grey[50],
  );
}

Widget _buildField(TextEditingController ctrl, String label, IconData icon,
    {bool isNumber = false, Function(String)? onChanged}) {
  return TextField(
    controller: ctrl,
    onChanged: onChanged,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: _inputDecoration(label, icon),
  );
}

Widget _buildRarityDropdown(String currentValue, Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    value: currentValue,
    decoration: _inputDecoration("Rarity", Icons.star_rounded),
    items: const ['common', 'rare', 'epic', 'legendary']
        .map((r) => DropdownMenuItem(value: r, child: Text(r.toUpperCase())))
        .toList(),
    onChanged: onChanged,
  );
}

// --- WIDGET CHECKBOX DINAMIS ---
Widget _buildDynamicDiceBearFeatures(
  String currentStyle,
  Map<String, bool> features,
  void Function(String key, bool value) onChanged,
) {
  // Cek config untuk style saat ini
  final config = _diceBearConfigs[currentStyle];

  // Jika style ini tidak punya konfigurasi fitur (cuma seed), kosongkan
  if (config == null || config.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "This style only supports 'Name' variations.",
        style: TextStyle(color: Colors.blue, fontSize: 12),
      ),
    );
  }

  // Buat list checkbox berdasarkan ketersediaan di config
  List<Widget> checkboxes = [];

  // Helper untuk buat checkbox
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
      const Text("Customize Features", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      if (checkboxes.isEmpty)
        const Text("- No extra features available -", style: TextStyle(color: Colors.grey, fontSize: 12))
      else
        ...checkboxes,
    ],
  );
}

void _showStylePicker(BuildContext context, String currentStyle, Function(String) onSelected) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Agar bisa full height jika perlu
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7, // 70% Layar
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Select Avatar Style", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _diceBearStylesMetadata.length,
                itemBuilder: (context, index) {
                  final s = _diceBearStylesMetadata[index];
                  final isSelected = currentStyle == s['id'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppColors.darkAzure : Colors.grey[100],
                      child: Icon(Icons.style, color: isSelected ? Colors.white : Colors.grey),
                    ),
                    title: Text(s['name']!, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    subtitle: Text(s['desc']!),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.darkAzure) : null,
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