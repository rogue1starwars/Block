import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'package:http/http.dart' as http;

List<String> httpMethods = [
  'GET',
  'POST',
  'PUT',
  'DELETE',
];

List<BlockBluePrint> blockDataHttp = [
  BlockBluePrint(
    name: 'Gemini API',
    fields: [
      Field(
        label: "Token",
        type: FieldTypes.string,
        value: '',
      ),
      Field(
        label: "Item",
        type: FieldTypes.string,
        value: '',
      ),
    ],
    children: [
      ValueInput(
        label: 'Image',
        block: null,
        filter: [BlockTypes.image],
      )
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) async {
      try {
        final token = block.fields[0].value;
        final item = block.fields[1].value;
        final imageInput = block.children[0] as ValueInput;
        final imageBlock = imageInput.block;
        if (imageBlock is! Block) {
          ref.read(uiProvider.notifier).showMessage('Invalid image');
          return false;
        }
        // Execute the image block to get the image file (assume it returns XFile or File)
        final imageFile = await imageBlock.execute(ref);
        if (imageFile == null) {
          ref.read(uiProvider.notifier).showMessage('No image file');
          return false;
        }

        // Read image bytes and encode as base64
        String mimeType = 'image/jpeg';
        final path = imageFile.path;
        if (path.endsWith('.png')) {
          mimeType = 'image/png';
        } else if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
          mimeType = 'image/jpeg';
        } else {
          ref.read(uiProvider.notifier).showMessage('Unsupported image format');
          return false;
        }
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);

        // Prompts
        if (item is! String) {
          ref.read(uiProvider.notifier).showMessage('Invalid item');
          return false;
        }
        final prompt =
            "Is there a $item in the image? Respond only with true or false.";

        if (token is! String) {
          ref.read(uiProvider.notifier).showMessage('Invalid token');
          return false;
        }
        final url = Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$token');
        final response = await http.post(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode({
            "contents": [
              {
                "parts": [
                  {"text": prompt},
                  {
                    "inline_data": {
                      "mime_type":
                          mimeType, // or "image/png" depending on your image
                      "data": base64Image,
                    }
                  }
                ]
              }
            ]
          }),
        );
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final String result =
            data['candidates']?[0]['content']?['parts'][0]['text'];
        print('Result: $result');

        // ref.read(uiProvider.notifier).showMessage('Response: ${response.body}');
        print('Response: ${response.body}');
        return result == "True";
      } catch (e) {
        ref.read(uiProvider.notifier).showMessage('Error: $e');
      }
    },
  ),
  BlockBluePrint(
    name: 'Oauth2.0',
    fields: [
      Field(
        label: 'Client ID',
        type: FieldTypes.string,
        value: '',
      ),
      Field(
        label: 'Client Secret',
        type: FieldTypes.string,
        value: '',
      ),
      Field(
        label: 'Refresh token',
        type: FieldTypes.string,
        value: '',
      )
    ],
    children: [],
    returnType: BlockTypes.string,
    originalFunc: (WidgetRef ref, Block block) async {
      try {
        final clientId = block.fields[0].value;
        final clientSecret = block.fields[1].value;
        final refreshToken = block.fields[2].value;

        if (clientId is! String ||
            clientSecret is! String ||
            refreshToken is! String) {
          ref.read(uiProvider.notifier).showMessage('Invalid client ID/secret');
          return;
        }

        final url = Uri.parse('https://api.twitter.com/2/oauth2/token');
        final resopnse = await http.post(url, headers: {
          HttpHeaders.authorizationHeader:
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        }, body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        });
        ref.read(uiProvider.notifier).showMessage('Response: ${resopnse.body}');
      } catch (e) {
        ref.read(uiProvider.notifier).showMessage('Error: $e');
      }
    },
  ),
  BlockBluePrint(
    name: 'Twitter Auth',
    fields: [
      Field(
        label: 'Bearer Token',
        type: FieldTypes.string,
        value: '',
      )
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final bearerToken = block.fields[0].value;

      if (bearerToken is! String) {
        ref
            .read(uiProvider.notifier)
            .showMessage('Bearer Token must be a string');
        return;
      }
      final twitter = v2.TwitterApi(
        bearerToken: bearerToken,
        retryConfig: v2.RetryConfig.ofRegularIntervals(
          maxAttempts: 5,
          onExecute: (event) {
            ref.read(uiProvider.notifier).showMessage('Retrying...');
          },
        ),
      );

      ref.read(variablesProvider.notifier).setVariable(
            '_twitter',
            twitter,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: 'Post',
    fields: [],
    children: [
      ValueInput(
        label: 'Content',
        block: null,
        filter: [BlockTypes.string],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) async {
      try {
        final twitter =
            ref.read(variablesProvider.notifier).getVariable('_twitter');
        if (twitter is! v2.TwitterApi) {
          ref
              .read(uiProvider.notifier)
              .showMessage('Twitter API not initialized');
          return;
        }
        twitter as v2.TwitterApi;

        final contentInput = block.children[0] as ValueInput;
        final contentBlock = contentInput.block;
        if (contentBlock is! Block) {
          ref.read(uiProvider.notifier).showMessage('Invalid content');
          return;
        }

        final content = contentBlock.execute(ref);

        await twitter.tweetsService.createTweet(
          text: content.toString(),
        );
      } catch (e) {
        ref.read(uiProvider.notifier).showMessage('Error: $e');
      }
    },
  ),
];
