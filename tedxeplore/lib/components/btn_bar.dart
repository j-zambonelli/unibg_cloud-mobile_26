import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainBtnBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBtnBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), 
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65), 
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: CupertinoTabBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            activeColor: const Color(0xFFFF3B30),
            inactiveColor: const Color(0xFF8E8E93),
            iconSize: 24,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart_fill),
                label: 'Preferiti',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_crop_circle_fill),
                label: 'Profilo',
              ),
            ],
          ),
        ),
      ),
    );
  }
}