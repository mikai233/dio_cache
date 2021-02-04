import 'dart:io';

bool isValidHttpStatusCode(int code) => const [
      HttpStatus.ok,
      HttpStatus.created,
      HttpStatus.accepted
    ].contains(code);
