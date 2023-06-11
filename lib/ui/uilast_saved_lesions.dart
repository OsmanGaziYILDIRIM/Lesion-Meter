import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

String decodeUrl(String url) {
  return Uri.decodeComponent(url);
}

class LastSavedLesions extends StatefulWidget {
  final String patientId;
  final List<File> lastGuestImages;
  final String lastGuestActionDateTime;

  const LastSavedLesions({Key? key, required this.lastGuestImages, required this.lastGuestActionDateTime, required this.patientId}) : super(key: key);

  get lastGuestImageDateTime => null;

  @override
  _LastSavedLesionsState createState() => _LastSavedLesionsState();
}

class _LastSavedLesionsState extends State<LastSavedLesions> {
  bool showEditButton = false;
  Map<String, List<String>> downloadedImageData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.patientId.isNotEmpty) {
      retrieveImagesFromFirebase();
    }
    else
    {
      setState(() {
        downloadedImageData[widget.lastGuestImageDateTime] = widget.lastGuestImages.cast<String>();
      });
    }
  }

  Future<void> retrieveImagesFromFirebase() async {
    try {
      final ListResult listResult = await FirebaseStorage.instance.ref().child(widget.patientId).listAll();
      final List<Reference> folderRefs = listResult.prefixes;

      // sort by date time.
      folderRefs.sort((a, b) => DateFormat('dd.MM.yyyy HH:mm:ss').parse(b.name).compareTo(DateFormat('dd.MM.yyyy HH:mm:ss').parse(a.name)));

      for (final Reference folderRef in folderRefs) {
        final ListResult imageResult = await folderRef.listAll();
        final List<Reference> imageRefs = imageResult.items;
        List<String> fileUrlList = [];
        for (final Reference ref in imageRefs) {
          final String downloadUrl = await ref.getDownloadURL();
          fileUrlList.add(downloadUrl);
        }
        downloadedImageData[folderRef.name] = fileUrlList;
      }
      setState(() {
        isLoading = false;  // İşlem tamamlandığında, durumu güncelle
      });
    } catch (e) {
      setState(() {
        isLoading = false;  // Hata durumunda da durumu güncelle
      });
      print('Firebase Storage retrieval error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: downloadedImageData.length,
        itemBuilder: (context, index) {
          final folderName = downloadedImageData.keys.elementAt(index);
          final imageUrls = downloadedImageData[folderName];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                folderName,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                shrinkWrap: true,  // Ensures that the GridView fits within the Column
                physics: ScrollPhysics(),  // Allows scrolling within the GridView
                itemCount: imageUrls?.length ?? 0,
                itemBuilder: (context, innerIndex) {
                  final imageUrl = imageUrls?[innerIndex] ?? '';

                  return imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                      : Container();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}