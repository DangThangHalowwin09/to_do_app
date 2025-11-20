import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfile_Screen extends StatefulWidget {
  const UpdateProfile_Screen({super.key});

  @override
  State<UpdateProfile_Screen> createState() => _UpdateProfile_ScreenState();
}

class _UpdateProfile_ScreenState extends State<UpdateProfile_Screen> {
  final nameController = TextEditingController();
  //final passwordController = TextEditingController();final confirmController = TextEditingController();
  final phoneController = TextEditingController();
  final TextEditingController _areaSearchController = TextEditingController();

  String selectedRole = "";
  bool loading = false;

  List<String> _areaOptionsForDoctors = [];
  List<String> _areaGroupOptionsForHardwareTeam = [];
  List<String> selectedAreasForDoctor = [];
  List<String> selectedGroupsForHardwareTeam = [];

  @override
  void initState() {
    super.initState();
    loadAreaGroup();
  }
  @override
  void dispose() {
    _areaSearchController.dispose();
    super.dispose();
  }
  Future<void> loadAreaGroup() async {
    var areaSnap = await FirebaseFirestore.instance.collection("areas").get();
    var groupSnap = await FirebaseFirestore.instance.collection("groups").get();

    setState(() {
      _areaOptionsForDoctors = areaSnap.docs.map((d) => d['name'].toString()).toList();
      _areaGroupOptionsForHardwareTeam = groupSnap.docs.map((d) => d['name'].toString()).toList();
    });
  }

  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thông báo"),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }

  Future<void> saveProfile() async {
    String name = nameController.text.trim();
    //String pass = passwordController.text.trim();
    //String confirm = confirmController.text.trim();
    String phone = phoneController.text.trim();

    if (name.isEmpty) return showPopup("Chưa nhập tên!");
    //if (pass.isEmpty) return showPopup("Bạn chưa nhập mật khẩu!");
    //if (confirm.isEmpty) return showPopup("Bạn chưa nhập lại mật khẩu!");
    //if (pass != confirm) return showPopup("Mật khẩu không khớp!");
    if (phone.isEmpty) return showPopup("Bạn chưa nhập số điện thoại!");
    if (selectedRole.isEmpty) return showPopup("Bạn chưa chọn vai trò!");

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return showPopup("Không tìm thấy user!");

    setState(() => loading = true);

    // Cập nhật mật khẩu Firebase
    //await user.updatePassword(pass);

    // Lưu Firestore
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "email": user.email,
      "name": name,
      "phone": phone,
      "role": selectedRole,
      "areas": selectedRole == "Y bác sỹ" ? selectedAreasForDoctor : [],
      "group": selectedRole == "Tổ phần cứng" ? selectedGroupsForHardwareTeam : [],
      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    showPopup("Cập nhật hồ sơ thành công!");
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Hoàn tất thông tin tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ❌ Không cho sửa email
            TextField(
              controller: TextEditingController(text: user?.email ?? ""),
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Email (không thể thay đổi)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Tên",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Phone",
              ),
            ),
            const SizedBox(height: 12),

   /*         TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Mật khẩu mới",
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nhập lại mật khẩu",
              ),
            ),
*/
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Vai trò",
              ),
              value: selectedRole.isEmpty ? null : selectedRole,
              items: [
                "User",
                "Admin",
                "Tổ phần cứng",
                "Tổ phần mềm",
                "Y bác sỹ"
              ]
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => selectedRole = v!),
            ),

            const SizedBox(height: 20),

            if (selectedRole == "Y bác sỹ")
              ...[
                const SizedBox(height: 16),
                const Text(
                  'Chọn khoa:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                // Ô tìm kiếm
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TextField(
                    controller: _areaSearchController,
                    decoration: const InputDecoration(
                      labelText: 'Tìm khu vực...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}), // để cập nhật filter
                  ),
                ),

                const SizedBox(height: 8),

                // Danh sách lọc + checkbox
                if (_areaOptionsForDoctors.isEmpty)
                  const Text('Đang tải danh sách khu vực...')
                else
                  ..._areaOptionsForDoctors
                      .where((area) =>
                      area.toLowerCase().contains(_areaSearchController.text.toLowerCase()))
                      .map((area) => CheckboxListTile(
                    title: Text(area),
                    value: selectedAreasForDoctor.contains(area),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedAreasForDoctor.add(area);
                        } else {
                          selectedAreasForDoctor.remove(area);
                        }
                      });
                    },
                  )),
              ],
             /* Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn khoa:"),
                  ..._areaOptionsForDoctors.map((a) => CheckboxListTile(
                    title: Text(a),
                    value: selectedAreasForDoctor.contains(a),
                    onChanged: (val) {
                      setState(() {
                        val!
                            ? selectedAreasForDoctor.add(a)
                            : selectedAreasForDoctor.remove(a);
                      });
                    },
                  )),
                ],
              ),*/


            if (selectedRole == "Tổ phần cứng")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn khu vực:"),
                  ..._areaGroupOptionsForHardwareTeam.map((g) => CheckboxListTile(
                    title: Text(g),
                    value: selectedGroupsForHardwareTeam.contains(g),
                    onChanged: (val) {
                      setState(() {
                        val!
                            ? selectedGroupsForHardwareTeam.add(g)
                            : selectedGroupsForHardwareTeam.remove(g);
                      });
                    },
                  )),
                ],
              ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Lưu thông tin"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
