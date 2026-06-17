import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // <-- AJOUT de Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // <-- AJOUT de Firebase Auth
import 'firebase_options.dart'; // <-- AJOUT (généré automatiquement par FlutterFire CLI)

// On importe tes deux écrans
import 'screens/ecran_solo.dart'; 
import 'login_page.dart'; // <-- AJOUT de ton nouvel écran de connexion

void main() async {
  // On s'assure que les liaisons des widgets sont initialisées avant Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase avec les options de ta console
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MonAppli());
}

class MonAppli extends StatelessWidget {
  const MonAppli({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Le StreamBuilder remplace directement "home: const EcranSolo()"
      home: StreamBuilder<User?>(
        // Il écoute en continu l'état de connexion de Firebase
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          // 1. Pendant que Firebase vérifie si la session est active au démarrage
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // 2. Si un utilisateur est trouvé (déjà connecté ou vient de se connecter)
          if (snapshot.hasData) {
            return const EcranSolo(); // Il prend les commandes de l'appli
          }
          
          // 3. Si personne n'est connecté (null), on affiche l'écran de connexion
          return const LoginPage();
        },
      ),
    );
  }
}
