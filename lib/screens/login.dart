import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _role = 'user'; // الدور الافتراضي هو user
  final _adminPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_role == 'user') {
      // دخول المستخدم بدون كلمة مرور
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userRole: 'user'),
        ),
      );
    } else {
      // التحقق من كلمة المرور في حالة الـ admin
      if (_adminPasswordController.text == '010143030') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userRole: 'admin'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('كلمة المرور غير صحيحة')),
        );
      }
    }
  }

  @override
  void dispose() {
    _adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // استخدام خلفية متدرجة لتحسين المظهر
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'اختر نوع الدخول:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: ListTile(
                              title: Text('مدير'),
                              leading: Radio<String>(
                                value: 'user',
                                groupValue: _role,
                                onChanged: (value) {
                                  setState(() {
                                    _role = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              title: Text('الحج ياسر'),
                              leading: Radio<String>(
                                value: 'admin',
                                groupValue: _role,
                                onChanged: (value) {
                                  setState(() {
                                    _role = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_role == 'admin') ...[
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _adminPasswordController,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            return null;
                          },
                        ),
                      ],
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_role == 'admin') {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            } else {
                              _login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // لون خلفية الزر
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'دخول',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white, // لون نص الزر
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
