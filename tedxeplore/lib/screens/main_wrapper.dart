import 'package:flutter/material.dart';
import 'package:tedxeplore/components/btn_bar.dart';
import 'package:tedxeplore/screens/home.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Elenco delle schermate collegate alla Bottom Bar
  final List<Widget> _screens = [
    const HomeScreen(), // La tua nuova home a fasce orizzontali
    const Scaffold(body: Center(child: Text('Schermata Preferiti (In Arrivo)', style: TextStyle(color: Colors.white)))), 
    const Scaffold(body: Center(child: Text('Schermata Profilo (In Arrivo)', style: TextStyle(color: Colors.white)))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // Salva lo stato delle pagine quando ti sposti da una all'altra
      ),
      bottomNavigationBar: MainBtnBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Aggiorna la pagina attiva
          });
        },
      ),
    );
  }
}