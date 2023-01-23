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
                leading: Icon(
                  Icons.account_circle,
                  color: Color.fromARGB(255, 45, 172, 123),
                ),
                title: Text(
                    '${_listcheck[index].fname} ${_listcheck[index].lname}'),
                trailing: _listcheck[index].team_leader == "1"
                    ? Icon(
                        Icons.star,
                        color: Color.fromARGB(216, 211, 214, 11),
                      )
                    : Text(""),
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
        title: Consumer<UserData>(
          builder: (context, _user, _) => Text(
            "สมาชิกทีมตรวจ ${_user.team_display}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 45, 172, 123),
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
