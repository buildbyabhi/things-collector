import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'sync_service.dart';
import 'auth_service.dart';
import 'login_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThingsCollectorApp());
}

class ThingsCollectorApp extends StatelessWidget {
  const ThingsCollectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Things Collector',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6), // Soft Violet
              secondary: Color(0xFFF43F5E), // Soft Rose
              surface: Colors.white,
            ),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF111827), // Dark slate
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              secondary: Color(0xFFF43F5E),
              surface: Color(0xFF1F2937), // Dark surface
            ),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasData) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SyncService _syncService = SyncService();
  final AuthService _authService = AuthService();
  String _selectedFilter = 'All';
  final List<String> _categories = ['All', 'Notes', 'Links', 'Ideas'];

  void _showAddDialog() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String title = '';
    String subtitle = '';
    String selectedCategory = 'Notes';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Thing', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                      items: ['Notes', 'Links', 'Ideas']
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w600))))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCategory = val!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      onChanged: (val) => title = val,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Notes / URL Link',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      maxLines: 3,
                      minLines: 1,
                      onChanged: (val) => subtitle = val,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            _syncService.addThing(title, subtitle, selectedCategory);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Playful Pastel Background Blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(isDark ? 0.15 : 0.08), // Soft Emerald
                boxShadow: [
                  BoxShadow(color: const Color(0xFF10B981).withOpacity(isDark ? 0.15 : 0.08), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(28.0, 32.0, 24.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Things',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: IconButton(
                              icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.amber : const Color(0xFF6B7280)),
                              onPressed: () {
                                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: IconButton(
                              icon: Icon(Icons.logout_rounded, color: isDark ? Colors.grey[400] : const Color(0xFF6B7280)),
                              onPressed: () async {
                                await _authService.signOut();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Categories
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: FilterChip(
                          label: Text(cat, style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : const Color(0xFF4B5563)), fontWeight: FontWeight.bold, fontSize: 15)),
                          selected: isSelected,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          elevation: isSelected ? 4 : 0,
                          pressElevation: 0,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)))),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: StreamBuilder<List<Thing>>(
                    stream: _syncService.getThingsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFFEF4444))));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                      }

                      var things = snapshot.data!;
                      if (_selectedFilter != 'All') {
                        things = things.where((t) => t.category == _selectedFilter).toList();
                      }
                      
                      if (things.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.inbox_rounded, size: 80, color: isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB)),
                              const SizedBox(height: 16),
                              Text(
                                'Nothing here yet.\nTap + to start collecting!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: things.length,
                        itemBuilder: (context, index) {
                          final thing = things[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(thing: thing, syncService: _syncService)));
                            },
                            onLongPress: () {
                              _syncService.deleteThing(thing.id);
                            },
                            child: LovableCard(thing: thing),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Add Thing', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}

class LovableCard extends StatelessWidget {
  final Thing thing;

  const LovableCard({super.key, required this.thing});

  IconData _getIcon() {
    switch (thing.category) {
      case 'Links': return Icons.link_rounded;
      case 'Ideas': return Icons.lightbulb_outline_rounded;
      default: return Icons.notes_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thing.imageUrl != null)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(thing.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  child: Center(
                    child: Icon(_getIcon(), size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                  ),
                ),
              ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        thing.category,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      thing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 17, fontWeight: FontWeight.w800, height: 1.2),
                    ),
                    if (thing.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        thing.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.grey[400] : const Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Thing thing;
  final SyncService syncService;

  const DetailScreen({super.key, required this.thing, required this.syncService});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF111827)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              onPressed: () {
                syncService.deleteThing(thing.id);
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thing.imageUrl != null) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.5 : 0.1), blurRadius: 30, offset: const Offset(0, 15)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.network(thing.imageUrl!, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 32),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(thing.category, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              thing.title,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF111827), height: 1.1, letterSpacing: -1),
            ),
            const SizedBox(height: 24),
            Text(
              thing.subtitle,
              style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : const Color(0xFF4B5563), height: 1.6, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 48),
            if (thing.url != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse(thing.url!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Open Link', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
