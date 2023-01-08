import 'package:html/parser.dart';
import 'package:http/http.dart';
// import 'package:ext_storage/ext_storage.dart';
import 'package:csv/csv.dart';

void main() {
  scrape();
}

Future<void> scrape() async {
  final page = await get(Uri.parse(
      'https://nl.wikipedia.org/wiki/Lijst_van_Nederlandse_gemeenten'));
  final document = parse(page.body);
  final hrefs = document
      .getElementsByTagName('a')
      .where((e) =>
          e.attributes.containsKey('href') &&
          e.attributes['href']!.startsWith('/wiki/') &&
          !e.attributes['href']!.contains('.svg') &&
          !e.attributes['href']!.contains('.png'))
      .map((e) => e.attributes['href'])
      .toList();

  //print(hrefs);

  int count = 0;
  List<dynamic> gemeenten = [];

  for (var href in hrefs) {
    if (href == null) continue;

    if (href.startsWith('/wiki/') && !href.endsWith('.svg')) {
      final page = await get(Uri.parse('https://nl.wikipedia.org/$href'));
      final document = parse(page.body);
      final coordinates = document.getElementById('text_coordinates');
      final inwoneraantal = document.getElementsByClassName('infobox');

      // if (coordinates != null) {
      //   print(
      //       '$href: ${coordinates.text} ${inwoneraantal[0].children[1].text}');
      // }

      if (inwoneraantal.isNotEmpty && inwoneraantal.length > 1 //&&
          //inwoneraantal[0].children.isNotEmpty &&
          //inwoneraantal[1].children.isNotEmpty &&
          //inwoneraantal[1].children[1].children.length > 9
          // && inwoneraantal[1].children[1].children[10].children.isNotEmpty
          ) {
        for (int i = 0; i < inwoneraantal[0].children.length; i++) {
          //print('Dit is kind i $i');

          for (int j = 0;
              j < inwoneraantal[0].children[i].children.length;
              j++) {
            // print('Dit is kind j $j');
            // print(inwoneraantal[0].children[i].children[j].text);

            //'$href: ${inwoneraantal[0].children[0].children[0].text} ${coordinates?.text} ${inwoneraantal[0].children[1].children[10].text}');

          }

          count++;

          if (count < 785 &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Noord-Holland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Zuid-Holland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Utrecht') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Groningen') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Noord-Brabant') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Gelderland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Zeeland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Friesland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Overijssel') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Flevoland') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Limburg') &&
              !inwoneraantal[0]
                  .children[0]
                  .children[0]
                  .text
                  .contains('Drenthe')) {
            //print(count.toString());

            String naamProvincie =
                inwoneraantal[0].children[1].children[4].text.trim();
            naamProvincie = naamProvincie.replaceAll('Provincie', '');
            naamProvincie = naamProvincie.trim();
            int lengteEraf = (naamProvincie.length / 2).floor();
            naamProvincie =
                naamProvincie.substring(0, naamProvincie.length - lengteEraf);

            String naamGemeente =
                inwoneraantal[0].children[0].children[0].text.trim();
            naamGemeente = naamGemeente.replaceAll('Bestuurscentrum', '');
            naamGemeente = naamGemeente.trim();
            if (naamGemeente == "Noord-H") {
              naamGemeente = "Noord-Holland";
            }

            String inwoneraantalGemeente1 =
                inwoneraantal[0].children[1].children[10].text.trim();
            inwoneraantalGemeente1 =
                inwoneraantalGemeente1.replaceAll('Bestuurscentrum', '');
            inwoneraantalGemeente1 = inwoneraantalGemeente1.trim();

            String inwoneraantalGemeente2 =
                inwoneraantal[0].children[1].children[11].text.trim();
            inwoneraantalGemeente2 =
                inwoneraantalGemeente2.replaceAll('Bestuurscentrum', '');
            inwoneraantalGemeente2 = inwoneraantalGemeente2.trim();

            if (coordinates != null) {
              final String coordinaten = coordinates.text.trim();
              getXcoordCity(coordinaten);
              getYcoordCity(coordinaten);
              // print(
              //     '$naamGemeente $naamProvincie $coordinaten $inwoneraantalGemeente1 $inwoneraantalGemeente2');
              String inwonerAantal;
              if (inwoneraantalGemeente1.contains('Inwoners')) {
                inwonerAantal = inwoneraantalGemeente1;
              } else {
                inwonerAantal = inwoneraantalGemeente2;
              }

              inwonerAantal = cleanupInwoneraantal(inwonerAantal);

              int inwonerGetal;
              try {
                inwonerGetal = parseInwoneraantalToInt(inwonerAantal);
              } catch (exception) {
                print("kon getal niet converteren");
                inwonerGetal = 0;
              }
              //print("$naamGemeente $inwonerGetal");
              gemeenten.add({
                "gemeenteNaam": naamGemeente,
                "provincieNaam": naamProvincie,
                "xCoordinatenStad": getXcoordCity(coordinaten),
                "yCoordinatenStad": getYcoordCity(coordinaten),
                //"coordinaten": coordinaten,
                "inwoneraantal": inwonerGetal,
                //"inwoneraantal": inwonerAantal,
                // "inwoneraantalRegel1": inwoneraantalGemeente1,
                // "inwoneraantalRegel2": inwoneraantalGemeente2
              });
            }
          }
        }
      }
    }
  }
  //if (count > 783) {
  //print('im done looping');

  List<List<dynamic>> rows = [];

  List<dynamic> row = [];
  row.add("gemeenteNaam");
  row.add("provincieNaam");
  row.add("xCoordinatenStad");
  row.add("yCoordinatenStad");
  //row.add("coordinaten");
  row.add("inwoneraantal");
  //row.add("inwoneraantalRegel1");
  //row.add("inwoneraantalRegel2");
  rows.add(row);

  for (int i = 0; i < gemeenten.length; i++) {
    if (i % 2 == 0) {
      List<dynamic> row = [];
      row.add(gemeenten[i]["gemeenteNaam"]);
      row.add(gemeenten[i]["provincieNaam"]);
      row.add(gemeenten[i]["xCoordinatenStad"]);
      row.add(gemeenten[i]["yCoordinatenStad"]);
      //row.add(gemeenten[i]["coordinaten"]);
      row.add(gemeenten[i]["inwoneraantal"]);
      //row.add(gemeenten[i]["inwoneraantalRegel1"]);
      //row.add(gemeenten[i]["inwoneraantalRegel2"]);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);
    print(csv);
  }
}

String cleanupInwoneraantal(String inwonerAantal) {
  if (inwonerAantal.contains("?")) {
    int indexQuestionmark = inwonerAantal.indexOf("?");
    inwonerAantal =
        inwonerAantal.substring(indexQuestionmark - 8, indexQuestionmark);
  }
  inwonerAantal = inwonerAantal.replaceAll(".", "");
  inwonerAantal.trim();
  return inwonerAantal;
}

int parseInwoneraantalToInt(String inwonerAantal) {
  int inwonerCijfer = int.parse(inwonerAantal);
  //print(inwonerCijfer.toString());
  return inwonerCijfer;
}

double getXcoordCity(String coordinaten) {
  double xCoord;
  int degrees = 0;
  int minutes = 0;
  int seconds = 0;
  double distanceToGreenwhich;

  String graden = coordinaten.substring(
      coordinaten.lastIndexOf("°") - 2, coordinaten.lastIndexOf("°"));
  degrees = int.parse(graden);

  if (coordinaten.contains("′")) {
    String minuten = coordinaten.substring(
        coordinaten.lastIndexOf("′") - 2, coordinaten.lastIndexOf("′"));
    minuten = minuten.replaceAll("°", "");
    minutes = int.parse(minuten);
  } else {
    String minuten = coordinaten.substring(
        coordinaten.lastIndexOf("'") - 2, coordinaten.lastIndexOf("'"));
    minuten = minuten.replaceAll("°", "");
    minutes = int.parse(minuten);
  }

  if (coordinaten.contains('"')) {
    String seconden = coordinaten.substring(
        coordinaten.lastIndexOf('"') - 2, coordinaten.lastIndexOf('"'));
    seconden = seconden.replaceAll('"', '');
    seconden = seconden.replaceAll("'", "");
    seconds = int.parse(seconden);
  }

  distanceToGreenwhich = degrees + (minutes / 60) + (seconds / 3600);

  if (coordinaten.contains("WL")) {
    xCoord = -distanceToGreenwhich;
  } else {
    xCoord = distanceToGreenwhich;
  }
  //print("xCoord: $xCoord");
  return xCoord;
}

double getYcoordCity(String coordinaten) {
  double yCoord;
  int degrees = 0;
  int minutes = 0;
  int seconds = 0;
  double distanceToEquator;

  String graden = coordinaten.substring(
      coordinaten.indexOf("°") - 2, coordinaten.indexOf("°"));
  degrees = int.parse(graden);

  if (coordinaten.contains("′")) {
    String minuten = coordinaten.substring(
        coordinaten.indexOf("′") - 2, coordinaten.indexOf("′"));
    minuten = minuten.replaceAll("°", "");
    minutes = int.parse(minuten);
  } else {
    String minuten = coordinaten.substring(
        coordinaten.indexOf("'") - 2, coordinaten.indexOf("'"));
    minuten = minuten.replaceAll("°", "");
    minutes = int.parse(minuten);
  }

  if (coordinaten.contains('"')) {
    String seconden = coordinaten.substring(
        coordinaten.indexOf('"') - 2, coordinaten.indexOf('"'));
    seconden = seconden.replaceAll('"', '');
    seconden = seconden.replaceAll("'", "");
    seconds = int.parse(seconden);
  }

  distanceToEquator = degrees + (minutes / 60) + (seconds / 3600);

  if (coordinaten.contains("NB")) {
    yCoord = 180 + distanceToEquator;
  } else {
    yCoord = 180 - distanceToEquator;
  }

  //print("yCoordCity: $yCoord");
  return yCoord;
}
