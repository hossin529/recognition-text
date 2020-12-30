import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:text_recognition_app/utilities/size_config.dart';
import 'package:text_recognition_app/utilities/styles.dart';

class MyDocumentScreen extends StatefulWidget {
  @override
  _MyDocumentScreenState createState() => _MyDocumentScreenState();
}

class _MyDocumentScreenState extends State<MyDocumentScreen> {
  /// List of files
  var files;
  bool externalStoragePermissionOkay = false;

  openPDF() async {
    initialisePermission();
    if(externalStoragePermissionOkay == true){
      FilePickerResult result = await FilePicker.platform.pickFiles() ;
      if(result != null) {
      //  File file = File(result.files.single.path);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) {
              return ViewPDF(
                  pathPDF: result.files.single.path);
              //open viewPDF page on click
            }));
      } else {
        // User canceled the picker
      }
    }
  }

  initialisePermission() async {
    var status = await Permission.mediaLibrary.status;
    if (!status.isGranted) {
      await Permission.mediaLibrary.request();
      status = await Permission.mediaLibrary.status;
      if (status.isGranted) {
        setState(() {
          externalStoragePermissionOkay = true;
        });
      }
    } else {
      setState(() {
        externalStoragePermissionOkay = true;
      });
    }
  }


  Future initialise2() async {
    /// get the external storage directory of an Android device
    Directory extDir = await getExternalStorageDirectory();
    /// permissions
    initialisePermission();

    ///async function to get list of files
    var fm = FileManager(root: Directory(extDir.path)); //
    files = await fm.filesTree(
        extensions: ["pdf"] //optional, to filter files, list only pdf files
        );
    setState(() {}); //update the UI
  }


  @override
  void initState() {
    initialise2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: files == null
            ? Center(child: Text("Searching Files"))
            : files.length > 0
                ? ListView.builder(
                    //if file/folder list is grabbed, then show here
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                        title: Text(files[index].path.split('/').last),
                        leading: Icon(Icons.picture_as_pdf),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Colors.redAccent,
                        ),
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ViewPDF(
                                pathPDF: files[index].path.toString());
                            //open viewPDF page on click
                          }));
                        },
                      ));
                    },
                  )
                : Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            openPDF();
                          },
                          icon: Icon(Icons.add_circle_outline_sharp,
                              color: Colors.green),
                          iconSize: SizeConfig.blockSizeHorizontal * 15,
                        ),
                        Text(
                          "Tape Here To Open a PDF File",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.blockSizeHorizontal * 4),
                        )
                      ],
                    ),
                  ));
  }
}

class ViewPDF extends StatelessWidget {
  String pathPDF = "";

  ViewPDF({this.pathPDF});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        //view PDF
        appBar: AppBar(
          title: Text("Document"),
          backgroundColor: kColor,
          elevation: 0.0,
          centerTitle: true,
        ),
        path: pathPDF);
  }
}
