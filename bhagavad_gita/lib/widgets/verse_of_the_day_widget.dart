import 'dart:convert';
import 'package:bhagavad_gita/Constant/app_colors.dart';
import 'package:bhagavad_gita/Constant/app_size_config.dart';
import 'package:bhagavad_gita/Constant/http_link_string.dart';
import 'package:bhagavad_gita/Constant/string_constant.dart';
import 'package:bhagavad_gita/models/all_verse_of_the_day_model.dart';
import 'package:bhagavad_gita/models/verse_of_the_day_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class VerseOfTheDayWidget extends StatefulWidget {
  const VerseOfTheDayWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<VerseOfTheDayWidget> createState() => _VerseOfTheDayWidgetState();
}

class _VerseOfTheDayWidgetState extends State<VerseOfTheDayWidget> {
  var todayDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final HttpLink httpLink = HttpLink(strGitaHttpLink);

  late ValueNotifier<GraphQLClient> client;

  late String verseOfTheDayQuery;
  @override
  void initState() {
    super.initState();
    client = ValueNotifier<GraphQLClient>(
        GraphQLClient(link: httpLink, cache: GraphQLCache()));

    verseOfTheDayQuery = """
    query GetVerseOfTheDayId {
      allVerseOfTheDays(condition: {date: "2021-09-20"}) {
        nodes {
          verseOrder
        }
      }
    }
    """;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Query(
        options: QueryOptions(document: gql(verseOfTheDayQuery)),
        builder: (
          QueryResult result, {
          Refetch? refetch,
          FetchMore? fetchMore,
        }) {
          if (result.hasException) {
            print("ERROR : ${result.exception.toString()}");
          }
          Map<String, dynamic>? verseDay = result.data;
          if (verseDay == null) {
            return Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          var respose = jsonEncode(verseDay);
          print('Verse of the day id : $respose');
          AllVerseOTheDayResponseModel allVerseOTheDayResponseModel =
              allVerseOTheDayResponseModelFromJson(respose);
          if (allVerseOTheDayResponseModel.allVerseOfTheDays!.nodes!.length ==
              0) {
            return Container();
          }
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.5,
                vertical: kDefaultPadding * 0.5),
            child: Container(
              height: (width - kDefaultPadding) * 0.526,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/images/home_verse_of_the_day.png'),
                      fit: BoxFit.fill),
                  borderRadius: BorderRadius.circular(kDefaultCornerRadius)),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/black_layer.png'),
                            fit: BoxFit.fill),
                        borderRadius:
                            BorderRadius.circular(kDefaultCornerRadius)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringConstant.strVerseOfTheDay,
                          style: Theme.of(context)
                              .textTheme
                              .headline2!
                              .copyWith(
                                  color: whiteColor, fontSize: width * 0.037),
                        ),
                        Spacer(),
                        VerseOfTheDayTextWidget(
                          verseID:
                              "${allVerseOTheDayResponseModel.allVerseOfTheDays!.nodes![0].verseOrder ?? 0}",
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'READ MORE',
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    color: whiteColor, fontSize: width * 0.037),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VerseOfTheDayTextWidget extends StatefulWidget {
  const VerseOfTheDayTextWidget({Key? key, required this.verseID})
      : super(key: key);

  @override
  State<VerseOfTheDayTextWidget> createState() =>
      _VerseOfTheDayTextWidgetState();
  final String verseID;
}

class _VerseOfTheDayTextWidgetState extends State<VerseOfTheDayTextWidget> {
  final HttpLink httpLink = HttpLink(strGitaHttpLink);
  late ValueNotifier<GraphQLClient> client;

  late String getVerseDetail;
  @override
  void initState() {
    super.initState();
    client = ValueNotifier<GraphQLClient>(
        GraphQLClient(link: httpLink, cache: GraphQLCache()));

    getVerseDetail = """
            query GetVerseDetailsById {
              gitaVerseById(id: ${widget.verseID}) {
              chapterNumber
              verseNumber
              gitaTranslationsByVerseId(condition: { language: "english", authorName: "Swami Sivananda" }) {
                nodes {
                  description
                }
              }
            }
          }
          """;
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Query(
        options: QueryOptions(document: gql(getVerseDetail)),
        builder: (
          QueryResult result, {
          Refetch? refetch,
          FetchMore? fetchMore,
        }) {
          if (result.hasException) {
            print("ERROR : ${result.exception.toString()}");
          }
          Map<String, dynamic>? verseDetail = result.data;
          if (verseDetail == null) {
            return Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          var respose = jsonEncode(verseDetail);
          VerseOTheDayDetailResponseModel verseOTheDayDetailResponseModel =
              verseOTheDayDetailResponseModelFromJson(respose);
          print('VerseDetail : $respose');
          return RichText(
            maxLines: 4,
            text: TextSpan(
              text:
                  '${verseOTheDayDetailResponseModel.gitaVerseById!.chapterNumber}.${verseOTheDayDetailResponseModel.gitaVerseById!.verseNumber} | ',
              style: Theme.of(context).textTheme.headline2!.copyWith(
                  color: primaryColor,
                  fontSize: width * 0.037,
                  overflow: TextOverflow.ellipsis),
              children: <TextSpan>[
                TextSpan(
                  text:
                      '${verseOTheDayDetailResponseModel.gitaVerseById!.gitaTranslationsByVerseId!.nodes![0].description}',
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                      color: whiteColor,
                      fontSize: width * 0.037,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}