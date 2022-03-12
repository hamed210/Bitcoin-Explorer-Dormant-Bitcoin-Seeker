import 'dart:isolate';

import 'package:dormant_bitcoin_seeker_flutter/Bitcoin/wallet_generator_state.dart';
import 'package:flutter/material.dart';

import '../../Bitcoin/bitcoinlib.dart';
import '../../global.dart';

class Search extends StatefulWidget {
  const Search({ Key? key }) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  int currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:appBarBackgroundColor,
        appBar: AppBar(
          toolbarHeight: 110,
          backgroundColor: appBarBackgroundColor,
          title : Container(
            margin: const EdgeInsets.only(top:30),
            child: TextFormField(
              onChanged: onSearch,
              initialValue: "",
              style: const TextStyle(color:Colors.white),
              decoration: InputDecoration(
                fillColor: inputColor,
                filled: true,
                suffixIcon:const Icon(Icons.search),
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintText: "Search",
                hintStyle:const TextStyle(color: Colors.grey)
              ),
            ),
          ),
          bottom: TabBar(
            tabs: const [
              TabButton(title: "ADDRESS",),
              TabButton(title: "PRIVATE KEY",),
              TabButton(title: "SEED PHRASE",),
            ],
            onTap: onChangeTab,
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(left:lateralContentMargins.left, right:lateralContentMargins.right,top:5),
          child: TabBarView(
            children: [
              //TAB ADDRESS
              if(WalletGeneratorState.searchResultByAddress != null)
                Column(
                  children : [
                    WalletGeneratorState.searchResultByAddress!
                  ]
                )
              else
                const Center(
                  child: Text("Invalid address", style: TextStyle(color: Colors.white, fontSize: 22.5),)
                ),
              // TAB PRIVATE KEY
              if(WalletGeneratorState.searchResultByPrivateKey != null)
                Column(
                  children : [
                    WalletGeneratorState.searchResultByPrivateKey!
                  ]
                )
              else
                const Center(
                  child: Text("Invalid private key", style: TextStyle(color: Colors.white, fontSize: 22.5),)
                ),
              const Icon(Icons.directions_bike),
            ],
          ),
        ),
      )
    );
  }

  Isolate? randomBrainWalletsThread;
  void onSearch(String search) async{
    BitcoinLib bitcoin = BitcoinLib();

    final receivePort = ReceivePort();

    Map<String, Object> params = {};
    params["sendPort"] = receivePort.sendPort;

    if(currentTabIndex == 0){
      params["address"] = search;
      randomBrainWalletsThread = await Isolate.spawn(bitcoin.searchByAddress,params);

      receivePort.listen((response) {
        if(response != null){
          WalletGeneratorState.searchResultByAddress = response;
        }
        else{
          WalletGeneratorState.searchResultByAddress = null;
        }
        setState(() {});
      });
    }
    else if(currentTabIndex == 1){
      params["privateKey"] = search;
      randomBrainWalletsThread = await Isolate.spawn(bitcoin.searchByPrivateKey,params);

      receivePort.listen((response) {
        if(response != null){
          WalletGeneratorState.searchResultByPrivateKey = response;
        }
        else{
          WalletGeneratorState.searchResultByPrivateKey = null;
        }
        setState(() {});
      });
    }
    else if(currentTabIndex == 2){
      params["seedPhrase"] = search;
    }
  }

  void onChangeTab(int index){
    currentTabIndex = index;
  }
}

class TabButton extends StatelessWidget {
  const TabButton({
    Key? key,
    required this.title
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: Center(
        child: Text(title)
      )
    );
  }
}