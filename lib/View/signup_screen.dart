import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_list/View/all_welcome_screens.dart';
import '../Service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'User';
  bool _isLoading = false;
  bool isPasswordHidden = true;

  List<String> _selectedAreas = [];
  List<String> _selectedAreasGroup = [];
  List<String> _areaOptions = [];
  List<String> _areaGroupOptions = [];

  @override
  void initState() {
    super.initState();
    fetchAreaList(); // gọi khi màn hình khởi tạo
  }

  Future<void> fetchAreaList() async {
    final snapshot = await FirebaseFirestore.instance.collection('areas').get();
    final snapshotGroup = await FirebaseFirestore.instance.collection('groups').get();
    setState(() {
      _areaOptions = snapshot.docs.map((doc) => doc['name'].toString()).toList();
      _areaGroupOptions = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    });
  }

  void _signup() async {
    setState(() {
      _isLoading = true;
    });

    String? result = await _authService.signup(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _selectedRole,
      areas: _selectedRole == 'Tổ phần cứng' ? _selectedAreas : [],
      group: _selectedRole == 'Y bác sỹ' ? _selectedAreasGroup : [],
    );

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo thành công')),
      );
      showActionDialog(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại nguyên nhân: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/icon_login.jpg"),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: isPasswordHidden,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordHidden = !isPasswordHidden;
                      });
                    },
                    icon: Icon(
                      isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Vai trò',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                    _selectedAreas.clear(); // reset khi đổi role
                  });
                },
                items: [
                  'User',
                  'Admin',
                  'Tổ phần cứng',
                  'Tổ phần mềm',
                  'Y bác sỹ',
                ].map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                )).toList(),
              ),
              if (_selectedRole == 'Tổ phần cứng') ...[
                const SizedBox(height: 16),
                const Text(
                  'Chọn khu vực hỗ trợ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_areaGroupOptions.isEmpty)
                  const Text('Đang tải danh sách khu vực...')
                else
                  ..._areaGroupOptions.map((area) => CheckboxListTile(
                    title: Text(area),
                    value: _selectedAreasGroup.contains(area),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedAreasGroup.add(area);
                        } else {
                          _selectedAreasGroup.remove(area);
                        }
                      });
                    },
                  )),
              ],
              if (_selectedRole == 'Y bác sỹ') ...[
                const SizedBox(height: 16),
                const Text(
                  'Chọn khu vực hỗ trợ:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (_areaOptions.isEmpty)
                  const Text('Đang tải danh sách khu vực...')
                else
                  ..._areaOptions.map((area) => CheckboxListTile(
                    title: Text(area),
                    value: _selectedAreas.contains(area),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedAreas.add(area);
                        } else {
                          _selectedAreas.remove(area);
                        }
                      });
                    },
                  )),
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signup,
                  child: const Text(" Đăng ký "),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Huỷ đăng ký. Về ", style: TextStyle(fontSize: 18)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      " trang Admin.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showActionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Bạn đã đăng ký thành công tài khoản'),
        content: const Text('Tiếp tục đăng ký tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đăng ký thêm'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AdminScreen()),
                    (route) => false,
              );
            },
            child: const Text('Về trang Admin'),
          ),
        ],
      );
    },
  );
}
