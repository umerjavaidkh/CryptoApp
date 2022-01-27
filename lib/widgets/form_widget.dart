import 'package:cryptotracker/injection_container.dart';
import 'package:cryptotracker/repositories/crypto_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
final formGlobalKey = GlobalKey<FormState>();

class HomePageForm extends StatefulWidget{


  final BuildContext buildContext;
  final Key ? key;

  HomePageForm({required this.buildContext,this.key});

  @override
  State<StatefulWidget> createState() {

    return HomePageFormState();
  }

}

class HomePageFormState extends State<HomePageForm>{

  double minRate = 43200.1255;
  double maxRate = 43500.3422;

  late final CryptoRepository cryptoRepository;

  final TextEditingController minTextEditingController =
  TextEditingController();
  final TextEditingController maxTextEditingController =
  TextEditingController();

  @override
  void initState() {

    cryptoRepository = getIt.get<CryptoRepository>();
    setLimitsInStart();
    super.initState();
  }

  void setLimitsInStart() async {
    var tempMinLimit =await  cryptoRepository.getMinRateLimit();
    var tempMaxLimit =await cryptoRepository.getMaxRateLimit();
    if(tempMinLimit!=null && tempMinLimit>0){
       minRate = tempMinLimit;
    }
    if(tempMaxLimit!=null && tempMaxLimit>0){
      maxRate = tempMaxLimit;
    }
  }


  @override
  Widget build(BuildContext context) {


    return  Form(
        key: formGlobalKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Min Accepted Rate $minRate",
                  style: TextStyle(
                      color: Colors.green,
                      fontFamily: "SFProDisplay",
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 180,
                  child: TextFormField(
                    key: Key("12345"),
                    controller: minTextEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter min rate",
                      counterText: '',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18,color: Colors.lightGreen),
                    ),
                    validator: (rate) {
                      if (rate!.isNotEmpty)
                        return null;
                      else
                        return 'Please Enter Min Limit';
                    },
                    autofocus: true,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18,color: Colors.lightGreen),
                    textInputAction: TextInputAction.done,
                    maxLength: 12,
                    inputFormatters: [],
                  ),
                ),
                ElevatedButton(
                  child: Text("Add"),
                  onPressed: () async {
                    if (minTextEditingController.text.isNotEmpty) {
                      var tempRate = double.tryParse(
                          minTextEditingController.text) ??
                          minRate;
                      if(tempRate >= maxRate){
                        Fluttertoast.showToast(
                            msg: "MIN LIMIT SHOULD LESS THEN MAX LIMIT",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }else{
                        minRate=tempRate;
                        cryptoRepository.saveMinRateLimit(minRate);
                      }

                    } else {
                      Fluttertoast.showToast(
                          msg: "MIN LIMIT SHOULD NOT BE EMPTY",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    setState(() {});
                    minTextEditingController.text = "";
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Max Accepted Rate $maxRate",
                  style: TextStyle(
                      fontFamily: "SFProDisplay",
                      fontSize: 16,
                      color: Colors.green,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 180,
                  child: TextFormField(
                    key: Key("54321"),
                    controller: maxTextEditingController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter max rate",
                      counterText: '',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18,color: Colors.lightGreen),
                    ),
                    validator: (rate) {
                      if (rate!.isNotEmpty)
                        return null;
                      else
                        return 'Please Enter Max Limit';
                    },
                    autofocus: true,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18,color: Colors.lightGreen),
                    textInputAction: TextInputAction.done,
                    maxLength: 12,
                    inputFormatters: [],
                  ),
                ),
                ElevatedButton(
                  child: Text("Add"),
                  onPressed: () async {
                    if (maxTextEditingController.text.isNotEmpty) {
                      var tempRate  = double.tryParse(
                          maxTextEditingController.text) ??
                          maxRate;
                      if(tempRate <= minRate){
                        Fluttertoast.showToast(
                            msg: "MAX LIMIT SHOULD GREATER THEN MIN LIMIT",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }else{
                        maxRate = tempRate;
                        cryptoRepository.saveMaxRateLimit(maxRate);
                      }


                    } else {
                      Fluttertoast.showToast(
                          msg: "MAX LIMIT SHOULD NOT BE EMPTY",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                    setState(() {});
                    maxTextEditingController.text = "";
                  },
                ),
              ],
            ),
          ],
        ));

  }



}