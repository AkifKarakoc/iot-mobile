import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/connection_status_widget.dart';
import '../widgets/result_dialog.dart';
import '../../core/di/injection.dart';
import '../../data/datasources/esp32_camera_service.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    final internetStatus = ref.watch(internetStatusProvider);
    final esp32Status = ref.watch(esp32StatusProvider);

    // Show result dialog when analysis succeeds
    ref.listen<AnalysisState>(analysisProvider, (previous, next) {
      if (next.status == AnalysisStatus.success && next.analysis != null) {
        showDialog(
          context: context,
          builder: (context) => ResultDialog(analysis: next.analysis!),
        );
      } else if (next.status == AnalysisStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            _buildHeader(internetStatus, esp32Status),

            // Main Content Area
            Expanded(
              child: _buildCameraViewer(context, esp32Status),
            ),

            // Bottom Action Bar
            _buildBottomActions(context, ref, analysisState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    AsyncValue<bool> internetStatus,
    AsyncValue<bool> esp32Status,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1D1E33),
            const Color(0xFF1D1E33).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'BioCycle AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const Spacer(),

          // Connection Status Indicators
          Row(
            children: [
              ConnectionStatusWidget(
                label: 'Internet',
                isConnected: internetStatus.value ?? false,
                icon: Icons.wifi,
              ),
              const SizedBox(width: 12),
              ConnectionStatusWidget(
                label: 'ESP32',
                isConnected: esp32Status.value ?? false,
                icon: Icons.camera_alt,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewer(
      BuildContext context, AsyncValue<bool> esp32Status) {
    final isConnected = esp32Status.value ?? false;
    final cameraService = getIt<Esp32CameraService>();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: isConnected
            ? _buildLiveStream(cameraService)
            : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildLiveStream(Esp32CameraService cameraService) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: cameraService.getStreamUrl(),
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00D4AA),
            ),
          ),
          errorWidget: (context, url, error) => _buildStreamError(),
        ),
        // Live indicator
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'CANLI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStreamError() {
    return Container(
      color: const Color(0xFF111328),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Color(0xFF4A4A6A),
            ),
            SizedBox(height: 16),
            Text(
              'Stream yüklenemedi',
              style: TextStyle(
                color: Color(0xFF8D8E98),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: const Color(0xFF111328),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: const Color(0xFF4A4A6A),
            ),
            const SizedBox(height: 24),
            const Text(
              'ESP32-CAM Bağlı Değil',
              style: TextStyle(
                color: Color(0xFF8D8E98),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kamera bağlantısını kontrol edin',
              style: TextStyle(
                color: Color(0xFF4A4A6A),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showIpConfigDialog(context),
              icon: const Icon(Icons.settings),
              label: const Text('IP Ayarları'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D1E33),
                foregroundColor: const Color(0xFF00D4AA),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    AnalysisState analysisState,
  ) {
    final isLoading = analysisState.status == AnalysisStatus.loading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Camera Button
          _buildIconButton(
            icon: Icons.camera_alt,
            label: 'Kamera',
            onPressed: isLoading
                ? null
                : () {
                    ref.read(analysisProvider.notifier).analyzeFromCamera();
                  },
          ),

          // Main Analyze Button (FAB) - ESP32-CAM
          _buildAnalyzeButton(context, ref, isLoading),

          // Gallery Button
          _buildIconButton(
            icon: Icons.photo_library,
            label: 'Galeri',
            onPressed: isLoading
                ? null
                : () {
                    ref.read(analysisProvider.notifier).analyzeFromGallery();
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              ref.read(analysisProvider.notifier).analyzeWaste();
            },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4AA), Color(0xFF00A896)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4AA).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 32,
              ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isEnabled ? const Color(0xFF8D8E98) : const Color(0xFF4A4A6A),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled
                    ? const Color(0xFF8D8E98)
                    : const Color(0xFF4A4A6A),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIpConfigDialog(BuildContext context) {
    final controller = TextEditingController();
    final cameraService = getIt<Esp32CameraService>();

    cameraService.getIpAddress().then((currentIp) {
      controller.text = currentIp;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'ESP32-CAM IP Adresi',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '192.168.1.100',
            hintStyle: TextStyle(color: Color(0xFF4A4A6A)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00D4AA)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00D4AA)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(color: Color(0xFF8D8E98)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cameraService.setIpAddress(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('IP adresi kaydedildi')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4AA),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
