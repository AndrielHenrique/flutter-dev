import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static late Database _instance;
  static const String dbName = 'aula14.db';

  static Future<Database> getInstance() async {
    String databasesPath = await getDatabasesPath();
    var path = join(databasesPath, dbName);

    _instance = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _instance;
  }

  static void _onCreate(Database db, int ver) async {
    await db.execute(
      'CREATE TABLE usuario(id INTEGER PRIMARY KEY, nome TEXT, email TEXT)',
    );
    await db.execute(
      'CREATE TABLE fornecedor(id INTEGER PRIMARY KEY, nome TEXT, cnpj TEXT)',
    );
    await db.execute(
      'CREATE TABLE produto(id INTEGER PRIMARY KEY, nome TEXT, preco REAL, quantidade INTEGER)',
    );
    await db.execute(
      'CREATE TABLE permissao(id INTEGER PRIMARY KEY, nomePermissao TEXT, descricao TEXT)',
    );
    await db.execute(
      'CREATE TABLE af(id INTEGER PRIMARY KEY AUTOINCREMENT, numAF TEXT NOT NULL UNIQUE, descricao TEXT NOT NULL, fornecedor TEXT NOT NULL, pesoTotal REAL NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE barra(id INTEGER PRIMARY KEY AUTOINCREMENT, numAF TEXT NOT NULL, linha INTEGER NOT NULL, codigoMP TEXT, descricao TEXT, fornecedor TEXT, corrida INTEGER, pesoBarra REAL DEFAULT 0, numeroBarra TEXT, isRasurada INTEGER NOT NULL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE recebimento(id INTEGER PRIMARY KEY AUTOINCREMENT, numAF TEXT NOT NULL, descricao TEXT NOT NULL, fornecedor TEXT NOT NULL, totalBarras INTEGER NOT NULL, pesoTotal REAL NOT NULL, obs TEXT, dataHora TEXT NOT NULL, barrasJson TEXT NOT NULL DEFAULT "[]")',
    );
  }
}
