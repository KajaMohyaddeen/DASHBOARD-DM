import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user.dart';
import 'package:emailjs/emailjs.dart' as emailjs;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(
        primaryColor: Colors.teal,
        // useMaterial3: false,
    textTheme: GoogleFonts.loraTextTheme(
      Theme.of(context).textTheme,
    ),
  ),
      debugShowCheckedModeBanner: false,
      home: const UserManagement(),
    );
  }
}

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  UserManagementState createState() => UserManagementState();
}

class UserManagementState extends State<UserManagement> {
  final _registerFormKey = GlobalKey<FormState>();
  final _unregisterFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _unregisterEmailController = TextEditingController();
  bool _active = true;

  List<User> _users = [];
  final Map<String, int> _stats = {'active': 0, 'inactive': 0};

  @override
  void initState() {
    super.initState();
    // _home();
    _fetchUsers();
    _fetchStats();
 
  
  }

   void _sendEmail(String toEmail,String toName ) async {
    final templateParams = {
    'to_email': toEmail, // Replace with the actual recipient email
    'from_name': 'Kaja',
    'to_name': toName,
  };
    try {
      await emailjs.send(
        'service_pke9oy9',
        'template_1bm6c5e',
        templateParams,
        const emailjs.Options(
            publicKey: 'XzzRf63TT8UDIsJrD',
            privateKey: 'ImrHCJJ5wjf5lMIWed1zT',
            limitRate: emailjs.LimitRate(
              id: 'app',
              throttle: 10000,
            )),
      );
      print('SUCCESS!');
    } catch (error) {
      if (error is emailjs.EmailJSResponseStatus) {
        print('ERROR... $error');
      }
      print(error.toString());
    }
  }

  
  Future<void> _home() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000'));
      if (response.statusCode == 200) {
         print("Home Route Called !!");
         print(response.body);
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/users'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          _users = jsonResponse.map((user) => User.fromJson(user)).toList();
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/stats'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        int activeCount = 0;
        int inactiveCount = 0;
        for (var stat in jsonResponse) {
          if (stat['Active'] == 1) {
            activeCount = stat['count'];
          } else {
            inactiveCount = stat['count'];
          }
        }
        setState(() {
          _stats['active'] = activeCount;
          _stats['inactive'] = inactiveCount;
        });
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> _registerUser() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/adduser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': _nameController.text,
          'email': _emailController.text,
          'active': _active ? 1 : 0,
        }),
      );

      if (response.statusCode == 200) {
        _sendEmail(_emailController.text, _nameController.text);
        _nameController.clear();
        _emailController.clear();
        setState(() {
          _active = false;
        });
        _fetchUsers();
        _fetchStats();
      } else {
        print('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print('Error registering user: $e');
    }
  }

  Future<void> _unregisterUser() async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/unregister-user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _unregisterEmailController.text,
        }),
      );

      if (response.statusCode == 200) {
        _unregisterEmailController.clear();
        _fetchUsers();
        _fetchStats();
      } else {
        print('Failed to unregister user: ${response.body}');
      }
    } catch (e) {
      print('Error unregistering user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 203, 203, 203),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange.shade900,
        title: const Text('User Management',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w500))
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Stats Panel
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                // color: Colors.white24,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Active Users',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_stats['active']}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Inactive Users',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_stats['inactive']}',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Registration Form
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _registerFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title: const Text('Active'),
                          selected: true,
                          value: _active,
                          onChanged: (bool value) {
                            setState(() {
                              _active = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_registerFormKey.currentState!.validate()) {
                              _registerUser();
                            }
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Unregistration Form
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _unregisterFormKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _unregisterEmailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                         ElevatedButton(
                          onPressed: () {
                            if (_unregisterFormKey.currentState!.validate()) {
                              _unregisterUser();
                            }
                          },
                          child: const Text('Unregister'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // User List
              const Text('Users:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _users.isEmpty
                  ? const Text('No users found')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_users[index].name),
                          subtitle: Text(_users[index].email),
                          trailing: Icon(
                            _users[index].active ? Icons.check_circle : Icons.cancel,
                            color: _users[index].active ? Colors.green : Colors.red,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
