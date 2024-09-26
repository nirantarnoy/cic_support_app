import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cic_support/models/storeissue.dart';
import 'package:flutter_cic_support/models/teammerber.dart';
import 'package:flutter_cic_support/pages/profilenormal.dart';
import 'package:flutter_cic_support/pages/storeissuedetailpage.dart';
import 'package:flutter_cic_support/providers/storeissue.dart';
import 'package:flutter_cic_support/providers/user.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class StoreissueApprovePage extends StatefulWidget {
  static final routeName = 'storeissueapprove';
  final String team_id;

  const StoreissueApprovePage({Key? key, required this.team_id})
      : super(key: key);
  @override
  State<StoreissueApprovePage> createState() => _StoreissueApprovePageState();
}

class _StoreissueApprovePageState extends State<StoreissueApprovePage> {
  // Future _obtainMemeberTeam() async {
  //   await Provider.of<UserData>(context, listen: false).findTeamMember();
  // }

  @override
  void initState() {
    Provider.of<StoreissueData>(context, listen: false).fetchIssuelist();

    super.initState();
  }

  Widget _buildlist(List<Storeissue> _listcheck) {
    DateFormat dateformatter = DateFormat('dd-MM-yyyy hh:ss');
    Widget cards;
    if (_listcheck.length > 0) {
      cards = new ListView.builder(
          itemCount: _listcheck.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoreissuedetailPage(
                              issue_id: _listcheck[index].id,
                            ))),
                child: ListTile(
                  leading: Icon(
                    Icons.error_outlined,
                    color: Color.fromARGB(255, 241, 84, 5),
                  ),
                  title: Text('${_listcheck[index].journal_no}'),
                  subtitle: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_listcheck[index].emp_full_name}',
                            style: TextStyle(color: Colors.green),
                          )),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${dateformatter.format(DateTime.parse(_listcheck[index].trans_date))}',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(""),
                ),
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              widget.team_id == ''
                  ? Navigator.of(context).pushNamed("profilenormal")
                  : Navigator.of(context).pushNamed("profile");
            }),
        title: Consumer<UserData>(
          builder: (context, _user, _) => Text(
            "อนุมัติใบเบิกสโตร์",
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
            child: Consumer<StoreissueData>(
              builder: ((context, memberteam, child) =>
                  _buildlist(memberteam.listIssue)),
            ),
          ),
        ]),
      ),
    );
  }
}
