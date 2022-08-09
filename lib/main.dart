import 'package:duvalsx/HomePages.dart';
import 'package:duvalsx/Services/CacheService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Constants.dart';
import 'Providers/PictureProvider.dart';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'Providers/LanguageChangeProvider.dart';


Future<void> main() async{
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService().initPreference();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    //  DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PictureProvider>(create: (_) => PictureProvider()),
        ChangeNotifierProvider(
          create: (context) =>  LanguageChangeProvider(),
        )
      ],
      child: Builder(
        builder: (context) =>
            Consumer<LanguageChangeProvider>(
                builder: (context, value, child){
                  return MaterialApp(
                    locale: Provider.of<LanguageChangeProvider>(context, listen: true).currentLocale,
                    localizationsDelegates: const [
                      S.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: S.delegate.supportedLocales,
                    debugShowCheckedModeBanner: false,
                    // home: value.doneLoading == true ? Login(): SplashScreen(context: context,),
                    home: SplashScreen(context: context,),
                  );
                }
            ),
      ),
    );
  }
}


class SplashScreen extends StatefulWidget {
  final BuildContext context;
  const SplashScreen({Key? key, required this.context}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver{


  getData() async{
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    widget.context.read<LanguageChangeProvider>().doneLoading = true;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const HomePages()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //WidgetsBinding.instance.addObserver(this);
    getData();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  // }

  // @override
  // void dispose() {
  //   WidgetsBinding.instance.removeObserver(this);
  //   super.dispose();
  // }
  //
  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //
  //   // if (state == AppLifecycleState.inactive ||
  //   //     state == AppLifecycleState.detached){
  //   //   if (kDebugMode) {
  //   //     print("inactive");
  //   //   }
  //   //   return;
  //   // }
  //
  //   final isBackground = state == AppLifecycleState.paused;
  //
  //   if (isBackground) {
  //     if (kDebugMode) {
  //       print("pause");
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: fisrtcolor,
      body:  Center(
        child: Text(
          "Duvals",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PopBold',
            fontSize: 24
          ),
        ),
      ),
    );
  }
}
