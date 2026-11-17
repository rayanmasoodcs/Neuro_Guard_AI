import 'package:flutter/material.dart';
import '../models/bluetooth_device_model.dart';
import 'package:neuroguard_ai/l10n/app_localizations.dart';

class BluetoothDeviceCard extends StatelessWidget {
  final BluetoothDeviceModel device;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final VoidCallback? onUnpair;
  final bool isPaired;

  const BluetoothDeviceCard({
    super.key,
    required this.device,
    required this.onConnect,
    required this.onDisconnect,
    this.onUnpair,
    this.isPaired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Device Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF0B8F55).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDeviceIcon(),
                    color: Color(0xFF0B8F55),
                    size: 28,
                  ),
                ),
                SizedBox(width: 12),
                
                // Device Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            device.getSignalStrength(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Signal strength indicator
                          _buildSignalIndicator(device.getSignalPercentage()),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: device.isConnected
                        ? Color(0xFF0B8F55)
                        : device.isConnecting
                            ? Colors.orange
                            : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    device.isConnected
                                            ? AppLocalizations.of(context).connected
                        : device.isConnecting
                                                ? AppLocalizations.of(context).connecting
                                                : AppLocalizations.of(context).available,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                if (device.isConnected || device.isConnecting)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: device.isConnecting ? null : onDisconnect,
                      icon: Icon(Icons.close, size: 18),
                      label: Text(AppLocalizations.of(context).disconnect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConnect,
                      icon: Icon(Icons.bluetooth_connected, size: 18),
                      label: Text(AppLocalizations.of(context).connect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0B8F55),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (isPaired && (onUnpair != null))
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: SizedBox(
                      width: 45,
                      child: ElevatedButton(
                        onPressed: onUnpair,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black54,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(Icons.delete, size: 18),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    switch (device.deviceType) {
      case 'Smartwatch':
      case 'Band':
        return Icons.watch;
      case 'Phone':
        return Icons.smartphone;
      case 'Earbuds':
        return Icons.headphones;
      default:
        return Icons.bluetooth;
    }
  }

  Widget _buildSignalIndicator(double strength) {
    return SizedBox(
      width: 60,
      height: 14,
      child: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Strength indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.transparent,
              color: _getSignalColor(strength),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(double strength) {
    if (strength >= 0.75) return Colors.green;
    if (strength >= 0.5) return Colors.yellow[700]!;
    if (strength >= 0.25) return Colors.orange;
    return Colors.red;
  }
}





