import 'package:flutter/material.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';

class MemberTeamPage extends StatefulWidget {
  final String team_id;

  const MemberTeamPage({Key? key, required this.team_id}) : super(key: key);
  @override
  State<MemberTeamPage> createState() => _MemberTeamPageState();
}

class _MemberTeamPageState extends State<MemberTeamPage> {

  @override
  void initState() {
    Provider.of<UserData>(context, listen: false).findTeamMember();
    Provider.of<UserData>(context, listen: false).findTeamSafetyMember();
    super.initState();
  }

  Widget _buildList(List<TeamMember> list, {required bool isSafety}) {
    if (list.isNotEmpty) {
      return ListView.builder(
        itemCount: list.length,
        padding: const EdgeInsets.symmetric(vertical: 4),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final member = list[index];
          final bool isLeader = member.team_leader == "1";
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isSafety
                        ? [const Color(0xFFFF5722), const Color(0xFFFF8A65)]
                        : [const Color(0xFF0F9B73), const Color(0xFF2EC89F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isSafety ? const Color(0xFFFF5722) : const Color(0xFF0F9B73)).withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              title: Text(
                '${member.fname} ${member.lname}',
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  isLeader ? "หัวหน้าทีมตรวจ / Team Leader" : "ผู้ร่วมทีมตรวจ / Team Member",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12,
                    color: isLeader 
                        ? (isSafety ? const Color(0xFFFF5722) : const Color(0xFF0F9B73))
                        : Colors.grey.shade500,
                    fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              trailing: isLeader
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB300).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFB300),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "หัวหน้าทีม",
                            style: TextStyle(
                              fontFamily: 'Prompt',
                              color: Color(0xFFFFB300),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
          );
        },
      );
    } else {
      return const Center(
        child: Text(
          "ไม่พบข้อมูลสมาชิก / No Data",
          style: TextStyle(
            fontFamily: 'Prompt',
            color: Colors.grey,
          ),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<UserData>(
          builder: (context, _user, _) => Text(
            "สมาชิกทีมตรวจ ${_user.team_display}",
            style: const TextStyle(
              color: Colors.black87,
              fontFamily: 'Prompt',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 10),
            _buildSectionHeader("รายชื่อสมาชิก 5 ส.", const Color(0xFF0F9B73)),
            Expanded(
              child: Consumer<UserData>(
                builder: (context, memberteam, child) =>
                    _buildList(memberteam.listmemberteam, isSafety: false),
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionHeader("รายชื่อสมาชิก Safety", const Color(0xFFFF5722)),
            Expanded(
              child: Consumer<UserData>(
                builder: (context, memberteam, child) =>
                    _buildList(memberteam.listmembersafetyteam, isSafety: true),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
