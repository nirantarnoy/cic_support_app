import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  // Future _obtainMemeberTeam() async {
  //   await Provider.of<UserData>(context, listen: false).findTeamMember();
  // }

  @override
  void initState() {
    Provider.of<UserData>(context, listen: false).findTeamMember();
    super.initState();
  }

  Widget _buildlist(List<TeamMember> _listcheck) {
    Widget cards;
    if (_listcheck.length > 0) {
      cards = new ListView.builder(
          itemCount: _listcheck.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(
                    '${_listcheck[index].fname} ${_listcheck[index].lname}'),
              ),
            );
          });

      return cards;
    } else {
      return Center(child: Text("No Data"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("สมาชิกทีมตรวจ"),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        child: Column(children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Consumer<UserData>(
              builder: ((context, memberteam, child) =>
                  _buildlist(memberteam.listmemberteam)),
            ),
          ),
        ]),
      ),
    );
  }
}
