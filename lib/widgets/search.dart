import 'package:filman_flutter/notifiers/filman.dart';
import 'package:filman_flutter/notifiers/settings.dart';
import 'package:filman_flutter/screens/film.dart';
import 'package:filman_flutter/types/film.dart';
import 'package:filman_flutter/types/search_results.dart';
import 'package:filman_flutter/utils/titlte.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  late Future<SearchResults> lazySearch;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(
          controller: searchController,
          padding: const MaterialStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0)),
          leading: const Icon(Icons.search),
          autoFocus: true,
          onChanged: (value) {
            if (value.isNotEmpty) {
              setState(() {
                lazySearch = Provider.of<FilmanNotifier>(context, listen: false)
                    .searchInFilman(value);
              });
            }
          },
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: searchController.text.isNotEmpty
              ? FutureBuilder(
                  future: lazySearch,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Center(
                            child: Text(
                              "Wystąpił błąd podczas wyszukiwania, ${snapshot.error}",
                            ),
                          ));
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return ListView(
                        children: snapshot.data?.isNotEmpty() == true
                            ? [
                                for (Film film
                                    in snapshot.data?.getFilms() ?? [])
                                  Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 3.0),
                                    child: ListTile(
                                      title: DisplayTitle(title: film.title),
                                      subtitle: Text(film.desc),
                                      leading: Image.network(film.imageUrl),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => FilmScreen(
                                              url: film.link,
                                              title: film.title,
                                              image: film.imageUrl,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).viewInsets.bottom,
                                )
                              ]
                            : [
                                Center(
                                  child: Text("Brak wyników",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium),
                                )
                              ],
                      );
                    }
                    return const Text("Brak wyników");
                  })
              : Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Center(
                    child: Text(
                        "Rozpocznij wyszukiwanie a wyniki pojawią się tutaj",
                        style: Theme.of(context).textTheme.labelMedium),
                  ),
                ),
        ),
      ],
    );
  }
}
