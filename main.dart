import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color _backgroundColor = Color(0xFF0F172A);
const Color _accentColor = Color(0xFF2DD4BF);
const Color _cardColor = Color(0xFF1E293B);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const HeartIQApp());
}

class HeartIQApp extends StatelessWidget {
  const HeartIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heart iQ',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        primaryColor: _accentColor,
      ),
      home: const LoginScreen(),
    );
  }
}
//==============================================
// LOGIN SCREEN
//==============================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailErrorText = email.isEmpty ? 'Please enter your email.' : null;
      _passwordErrorText = password.isEmpty ? 'Please enter your password.' : null;
    });

    if (_emailErrorText != null || _passwordErrorText != null) {
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            const Text(
              'Heart iQ',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              'Ahead of the Beat',
              style: TextStyle(fontSize: 16, color: _accentColor),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration('Email Address').copyWith(
                errorText: _emailErrorText,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: _buildInputDecoration('Password').copyWith(
                errorText: _passwordErrorText,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: _backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleSignIn,
                child: const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'or',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: _backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                },
                child: const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
//==============================================
// SIGN-UP SCREEN
//==============================================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? _firstNameErrorText;
  String? _lastNameErrorText;
  String? _emailErrorText;
  String? _phoneErrorText;
  String? _passwordErrorText;
  String? _addressLine1ErrorText;
  String? _cityErrorText;
  String? _stateErrorText;
  String? _countryErrorText;
  String? _postalCodeErrorText;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final addressLine1 = _addressLine1Controller.text.trim();
    final city = _cityController.text.trim();
    final state = _stateController.text.trim();
    final country = _countryController.text.trim();
    final postalCode = _postalCodeController.text.trim();

    setState(() {
      _firstNameErrorText = firstName.isEmpty ? 'Please enter your first name.' : null;
      _lastNameErrorText = lastName.isEmpty ? 'Please enter your last name.' : null;
      _emailErrorText = email.isEmpty ? 'Please enter your email.' : null;
      _phoneErrorText = phone.isEmpty ? 'Please enter your phone number.' : null;
      _passwordErrorText = password.isEmpty ? 'Please enter your password.' : null;
      _addressLine1ErrorText = addressLine1.isEmpty ? 'Please enter your address.' : null;
      _cityErrorText = city.isEmpty ? 'Please enter your city.' : null;
      _stateErrorText = state.isEmpty ? 'Please enter your state.' : null;
      _countryErrorText = country.isEmpty ? 'Please enter your country.' : null;
      _postalCodeErrorText = postalCode.isEmpty ? 'Please enter your postal code.' : null;
    });

    if (_firstNameErrorText != null ||
        _lastNameErrorText != null ||
        _emailErrorText != null ||
        _phoneErrorText != null ||
        _passwordErrorText != null ||
        _addressLine1ErrorText != null ||
        _cityErrorText != null ||
        _stateErrorText != null ||
        _countryErrorText != null ||
        _postalCodeErrorText != null) {
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign-Up',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _firstNameController,
                decoration: _buildInputDecoration('First Name').copyWith(errorText: _firstNameErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: _buildInputDecoration('Last Name').copyWith(errorText: _lastNameErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Email Address').copyWith(errorText: _emailErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration('Phone Number').copyWith(errorText: _phoneErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _buildInputDecoration('Password').copyWith(errorText: _passwordErrorText),
              ),
              const SizedBox(height: 16),
              const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: _addressLine1Controller,
                decoration: _buildInputDecoration('Address Line #1').copyWith(errorText: _addressLine1ErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressLine2Controller,
                decoration: _buildInputDecoration('Address Line #2 (Optional)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: _buildInputDecoration('City').copyWith(errorText: _cityErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _stateController,
                decoration: _buildInputDecoration('State').copyWith(errorText: _stateErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _countryController,
                decoration: _buildInputDecoration('Country').copyWith(errorText: _countryErrorText),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _postalCodeController,
                decoration: _buildInputDecoration('Postal Code').copyWith(errorText: _postalCodeErrorText),
              ),
              const SizedBox(height: 16),
              const Text('Medical History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                decoration: _buildInputDecoration('List any Known Medical Conditions Here'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleSignUp,
                  child: const Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//==============================================
// HOME SCREEN
//==============================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(fontSize: 16, color: Colors.white60)),
            const Text('User', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 155, 26, 26),
                  foregroundColor: _backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
                },
                label: const Text('EMERGENCY', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LAST BIOMETRIC SCAN', style: TextStyle(fontSize: 12, color: _accentColor, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('72 BPM', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  Text('Status: Optimal Cardiovascular Baseline', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _backgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const DietAndLifestyleScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.eco, size: 18),
                            SizedBox(height: 4),
                            Text('Diet and Lifestyle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _backgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.face, size: 18),
                            SizedBox(height: 4),
                            Text('Face Scan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: _backgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SymptomCheckScreen()));
                        },
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description, size: 18),
                            SizedBox(height: 4),
                            Text('Symptom Check', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
//==============================================
// EMERGENCY SCREEN - FALSE ALARM
//==============================================
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  int _secondsLeft = 10;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (!mounted || _isExpired) return;

      setState(() {
        _secondsLeft -= 1;
      });

      if (_secondsLeft > 0) {
        _startTimer();
      } else {
        setState(() {
          _isExpired = true;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyCallScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpired = true;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const EmergencyCallScreen()),
                    );
                  },
                  child: const Text(
                    'SOS',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Click the button if you need help.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Text(
                'Auto-redirecting in $_secondsLeft seconds',
                style: const TextStyle(fontSize: 16, color: _accentColor),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: const Text('Return to Home Screen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==============================================
// EMERGENCY CALL SCREEN
//==============================================
class EmergencyCallScreen extends StatelessWidget {
  const EmergencyCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Call'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_in_talk, size: 80, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                'Calling emergency services...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please stay calm and wait for assistance.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: _backgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  },
                  child: const Text('Return to Home Screen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//==============================================
// DIET AND LIFESTYLE SCREEN
//==============================================
class DietAndLifestyleScreen extends StatelessWidget {
  const DietAndLifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet and Lifestyle'), automaticallyImplyLeading: true),
      body: const Center(
        child: Text('Diet and Lifestyle Content Goes Here', style: TextStyle(fontSize: 18, color: Colors.white70)),
      ),
    );
  }
}

//==============================================
// SYMPTOM CHECK SCREEN
//==============================================
class SymptomCheckScreen extends StatefulWidget {
  const SymptomCheckScreen({super.key});
  
  @override
  State<SymptomCheckScreen> createState() => _SymptomCheckScreenState();
}

class _SymptomCheckScreenState extends State<SymptomCheckScreen> {

  final _symptomController = TextEditingController();

  String _aiAdvice = "Enter your symptoms above to get advice.";
  bool _isLoading = false;

  String? _errorText;

  Future<void> _getAIAdvice() async {
    if (_symptomController.text.trim().isEmpty) {
      setState(() {
        _errorText = "Please enter your symptoms before checking.";
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    final apiKey = dotenv.get('GEMINI_API_KEY'); // Replace with your actual API key

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      // Instructions for the AI model to provide advice based on symptoms
      systemInstruction: Content.system('''
        You are a helpful triage assistant.
        If the user inpts mild, common symptoms (like a light headache, mild couch, or fatigue), suggest gentle home remedies like drinking more water, resting, or eating specific healthy foods (e.g., nuts, broths).
        DO NOT DIAGNOSE DISEASES
        If the symptoms are severs or concerning (e.g., chest pain, shortness of breath, severe bleeding, high fever), immediately advise them to seek professional medical help or go to an emergency room.
      '''),
    );
    
    try {
      final prompt = _symptomController.text;
      final content = [Content.text(prompt)];

      final response = await model.generateContent(content);

      setState(() {
        _aiAdvice = response.text ?? "I couldn't process that. Please try again.";
      });
    } catch (e) {
      setState(() {
        _aiAdvice = "Error communicating with AI: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symptom Check'), automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'List your symptoms below and we will provide a preliminary analysis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
             'This is not a substitute for professional medical advice.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            const SizedBox(height: 32),
            TextField(
              controller: _symptomController,
              decoration: InputDecoration(
                labelText: 'How are you feeling today?',
                border: const OutlineInputBorder(),
                hintText: 'e.g., I have a slight headache and feel tired.',
                errorText: _errorText,
                ),
                maxLines: 3,
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: _backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null: _getAIAdvice,
                child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Check Symptoms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: _accentColor),
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Text(
                    _aiAdvice,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//==============================================
// TEXT TOGGLE WIDGET
//==============================================
class TextToggleWidget extends StatefulWidget {
  const TextToggleWidget({super.key});

  @override
  State<TextToggleWidget> createState() => _TextToggleWidgetState();
}

class _TextToggleWidgetState extends State<TextToggleWidget> {
  // 2. This variable tracks whether the text is hidden or visible
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 3. The button that triggers the visibility change
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: _backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _isVisible ? null : () {
            // 4. setState tells Flutter to rebuild the UI with the new value
              setState(() {
               _isVisible = true; // Toggles the text on
              });
            },
            child: const Text('Generate Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
         ),
        ),
        const SizedBox(height: 20),
        // 5. Conditional operator: Displays the Text if true, otherwise an empty box
        if (_isVisible)
            const Text('Hello! You clicked the button.', style: TextStyle(fontSize: 20))
      ],
    );
  }
}

//==============================================
// SCAN SCREEN
//==============================================
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isScanning = false;

  Future<void> _runMockScan() async {
    setState(() {
      _isScanning = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Scan'), automaticallyImplyLeading: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _isScanning ? _accentColor : Colors.transparent, width: 3),
                ),
                child: Center(
                  child: _isScanning
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: _accentColor),
                            SizedBox(height: 16),
                            Text('TS-CAN Processing Optical Vectors...', style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_front, size: 80, color: Colors.white38),
                            SizedBox(height: 16),
                            Text('Align your face inside the framing area', style: TextStyle(color: Colors.white60)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isScanning ? Colors.grey : _accentColor,
                  foregroundColor: _backgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isScanning ? null : _runMockScan,
                child: Text(_isScanning ? 'Processing Analysis...' : 'Start 45s Scan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//==============================================
// RESULTS SCREEN
//==============================================
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Metrics Evaluation'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.check_circle_outline, size: 72, color: _accentColor),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Biometric Metrics Extracted', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _buildResultRow('Heart Rate (Calculated)', '74 BPM'),
            _buildResultRow('Heart Rate Variability (HRV)', '62 ms'),
            _buildResultRow('Cardiovascular Stress Index', 'Low / Normal'),
            _buildResultRow('Phenotypic CAD Risk Match', '0.12 (Low Probability)'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _accentColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                },
                child: const Text('Return to Dashboard', style: TextStyle(color: _accentColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _accentColor)),
        ],
      ),
    );
  }
}

InputDecoration _buildInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: _cardColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}