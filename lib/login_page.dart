import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
// import 'home_page.dart'; // Ta page principale actuelle

// ... reste de ton main() avec l'initialisation Firebase ...

MaterialApp(
  title: 'Mon Appli',
  theme: ThemeData(primarySwatch: Colors.blue),
  home: StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      // Pendant que Firebase vérifie le statut de connexion au démarrage
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      
      // Si l'utilisateur est connecté, on affiche l'appli principale
      if (snapshot.hasData) {
        return const HomePage(); // Remplace par le nom de ta page principale
      }
      
      // Sinon, on le renvoie vers l'écran de connexion
      return const LoginPage();
    },
  ),
);
