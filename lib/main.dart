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
            print(count.toString());

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

              // print(
              //     '$naamGemeente $naamProvincie $coordinaten $inwoneraantalGemeente1 $inwoneraantalGemeente2');
              gemeenten.add({
                "gemeenteNaam": naamGemeente,
                "provincieNaam": naamProvincie,
                "coordinaten": coordinaten,
                "inwoneraantalRegel1": inwoneraantalGemeente1,
                "inwoneraantalRegel2": inwoneraantalGemeente2
              });
            }
          }
        }
      }
    }

  }
    //if (count > 783) {
      print('im done looping');

      List<List<dynamic>> rows = [];

      List<dynamic> row = [];
      row.add("gemeenteNaam");
      row.add("provincieNaam");
      row.add("coordinaten");
      row.add("inwoneraantalRegel1");
      row.add("inwoneraantalRegel2");
      rows.add(row);

      for (int i = 0; i < gemeenten.length; i++) {
        List<dynamic> row = [];
        row.add(gemeenten[i]["gemeenteNaam"]);
        row.add(gemeenten[i]["provincieNaam"]);
        row.add(gemeenten[i]["coordinaten"]);
        row.add(gemeenten[i]["inwoneraantalRegel1"]);
        row.add(gemeenten[i]["inwoneraantalRegel2"]);
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);
      print(csv);
    //}

}
