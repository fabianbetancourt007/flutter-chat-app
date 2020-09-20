import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:chat_flutter/models/usuario.dart';
import 'package:chat_flutter/global/environment.dart';
import 'package:chat_flutter/models/login_response.dart';

class AuthService with ChangeNotifier {
  final _storage = new FlutterSecureStorage();

  Usuario usuario;
  bool _autenticando = false;
  bool get autenticando => this._autenticando;
  set autenticando(bool valor) {
    this._autenticando = valor;
    notifyListeners();
  }

  static Future<String> getToken() async {
    final _storage = new FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = new FlutterSecureStorage();
    await _storage.delete(key: 'token');
  }

  Future<bool> login(String email, String password) async {
    this.autenticando = true;

    final data = {
      'email': email,
      'password': password,
    };

    final resp = await http.post(
      '${Environment.apiUrl}/login',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    print(resp.body);
    this.autenticando = false;
    if (resp.statusCode == 200) {
      final loginResponce = loginResponceFromJson(resp.body);
      this.usuario = loginResponce.usuario;

// guardar token en lugar seguro
      await this._guardarToken(loginResponce.token);

      return true;
    } else {
      return false;
    }

    // print(jsonEncode(data));
  }

  Future<dynamic> register(String nombre, String email, String password) async {
    this.autenticando = true;

    final data = {
      'nombre': nombre,
      'email': email,
      'password': password,
    };
    final resp = await http.post(
      '${Environment.apiUrl}/login/new',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print(resp.body);
    this.autenticando = false;
    if (resp.statusCode == 200) {
      final registerResponce = loginResponceFromJson(resp.body);
      this.usuario = registerResponce.usuario;
      await this._guardarToken(registerResponce.token);

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await this._storage.read(key: 'token');

    final resp = await http.get(
      '${Environment.apiUrl}/login/renew',
      headers: {'Content-Type': 'application/json', 'x-token': token},
    );
    print(resp.body);
    if (resp.statusCode == 200) {
      final registerResponce = loginResponceFromJson(resp.body);
      this.usuario = registerResponce.usuario;
      await this._guardarToken(registerResponce.token);

      return true;
    } else {
      this.logout();
      return false;
    }
  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    await _storage.delete(key: 'token');
  }
}
