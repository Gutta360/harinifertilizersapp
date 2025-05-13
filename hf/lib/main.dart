import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:littleflower/login.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        // apiKey: "AIzaSyAzz2lntnIRMRGTxvGqUGjYPVK9Zd0TxH0",
        // authDomain: "littleflowerschoolapp.firebaseapp.com",
        // projectId: "littleflowerschoolapp",
        // storageBucket: "littleflowerschoolapp.firebasestorage.app",
        // messagingSenderId: "743465373466",
        // appId: "1:743465373466:web:17e645f781946e24cca6a3"),

        apiKey: "AIzaSyDdojfI0l29-HRGQVybJg-bErNfp0yPETA",
        authDomain: "littleflowersvuyyuru.firebaseapp.com",
        projectId: "littleflowersvuyyuru",
        storageBucket: "littleflowersvuyyuru.firebasestorage.app",
        messagingSenderId: "264527105609",
        appId: "1:264527105609:web:f8f23b5bf648e859223998",
        measurementId: "G-218HZ2Q88E"),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalData(),
      child: const MainWidget(),
    ),
  );
}

class MainWidget extends StatelessWidget {
  const MainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.outfitTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.outfit(textStyle: textTheme.bodyMedium),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const NewLoginPage());
  }
}

class GlobalData extends ChangeNotifier {
  bool _isUserLoggedIn = false;

  bool get isUserLoggedIn => _isUserLoggedIn;

  void setIsUserLoggedIn(bool isUserLoggedIn) {
    _isUserLoggedIn = isUserLoggedIn;
    notifyListeners();
  }
}
