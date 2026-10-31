import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/channel.dart';

class ChannelFilterBar extends StatelessWidget {
  final List<Channel> channels;
  final String selectedChannelId;
  final ValueChanged<String> onChannelSelected;
  final String? userCompanyName;

  const ChannelFilterBar({
    super.key,
    required this.channels,
    required this.selectedChannelId,
    required this.onChannelSelected,
    this.userCompanyName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final channel = channels[index];
          final isSelected = channel.id == selectedChannelId;

          String displayName = channel.name;
          if (channel.isCompanyRestricted && userCompanyName != null) {
            displayName = '🏢 $userCompanyName Lounge';
          }

          return ChoiceChip(
            showCheckmark: false,
            avatar: Icon(
              channel.iconData,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            label: Text(displayName),
            selected: isSelected,
            onSelected: (_) => onChannelSelected(channel.id),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.uaeEmerald,
            side: BorderSide(
              color: isSelected ? AppColors.uaeEmerald : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
