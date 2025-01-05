// lib/view/gerar_senha_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GerarSenhaPage extends StatefulWidget {
  @override
  _GerarSenhaPageState createState() => _GerarSenhaPageState();
}

class _GerarSenhaPageState extends State<GerarSenhaPage> {
  int _comprimento = 12;
  bool _incluirMaiusculas = true;
  bool _incluirMinusculas = true;
  bool _incluirNumeros = true;
  bool _incluirSimbolos = true;
  String _senhaGerada = '';
  String _nivelConfiabilidade = '';

  void _gerarSenha() {
    String caracteres = '';
    if (_incluirMaiusculas) caracteres += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_incluirMinusculas) caracteres += 'abcdefghijklmnopqrstuvwxyz';
    if (_incluirNumeros) caracteres += '0123456789';
    if (_incluirSimbolos) caracteres += '!@#\$%^&*()-_=+[]{}|;:,.<>?';

    if (caracteres.isEmpty) {
      setState(() {
        _senhaGerada = '';
        _nivelConfiabilidade = 'Selecione pelo menos uma opção.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione pelo menos uma opção para gerar a senha.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Random random = Random.secure();
    String senha = List.generate(_comprimento, (index) {
      return caracteres[random.nextInt(caracteres.length)];
    }).join();

    String nivel = _avaliarConfiabilidade(
      _comprimento,
      _incluirMaiusculas,
      _incluirMinusculas,
      _incluirNumeros,
      _incluirSimbolos,
    );

    setState(() {
      _senhaGerada = senha;
      _nivelConfiabilidade = nivel;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Senha gerada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _avaliarConfiabilidade(
    int comprimento,
    bool maiusculas,
    bool minusculas,
    bool numeros,
    bool simbolos,
  ) {
    int complexidade = 0;
    if (maiusculas) complexidade += 1;
    if (minusculas) complexidade += 1;
    if (numeros) complexidade += 1;
    if (simbolos) complexidade += 1;

    if (comprimento >= 16 && complexidade == 4) {
      return 'Muito Forte';
    } else if (comprimento >= 12 && complexidade >= 3) {
      return 'Forte';
    } else if (comprimento >= 8 && complexidade >= 2) {
      return 'Média';
    } else {
      return ' Era melhor\n sem senha';
    }
  }

  Color _obterCorConfiabilidade() {
    switch (_nivelConfiabilidade) {
      case 'Muito Forte':
        return Colors.green;
      case 'Forte':
        return Colors.lightGreen;
      case 'Média':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerar Senha Segura'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slider para comprimento da senha
                Text(
                  'Comprimento da Senha: $_comprimento',
                  style: Theme.of(context).textTheme.bodyMedium, // Alterado de bodyMedium para bodyText2
                ),
                Slider(
                  value: _comprimento.toDouble(),
                  min: 4,
                  max: 32,
                  divisions: 28,
                  label: '$_comprimento',
                  activeColor: Colors.purple,
                  inactiveColor: Colors.grey[600],
                  onChanged: (double value) {
                    setState(() {
                      _comprimento = value.toInt();
                    });
                  },
                ),
                SizedBox(height: 24.0),
                // Switches para tipos de caracteres
                SwitchListTile(
                  title: Text('Incluir Letras Maiúsculas'),
                  value: _incluirMaiusculas,
                  onChanged: (bool value) {
                    setState(() {
                      _incluirMaiusculas = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveTrackColor: Colors.grey,
                  secondary: Icon(Icons.text_fields, color: Colors.white),
                ),
                SwitchListTile(
                  title: Text('Incluir Letras Minúsculas'),
                  value: _incluirMinusculas,
                  onChanged: (bool value) {
                    setState(() {
                      _incluirMinusculas = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveTrackColor: Colors.grey,
                  secondary: Icon(Icons.text_fields, color: Colors.white),
                ),
                SwitchListTile(
                  title: Text('Incluir Números'),
                  value: _incluirNumeros,
                  onChanged: (bool value) {
                    setState(() {
                      _incluirNumeros = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveTrackColor: Colors.grey,
                  secondary: Icon(Icons.dialpad, color: Colors.white),
                ),
                SwitchListTile(
                  title: Text('Incluir Símbolos'),
                  value: _incluirSimbolos,
                  onChanged: (bool value) {
                    setState(() {
                      _incluirSimbolos = value;
                    });
                  },
                  activeColor: Colors.purple,
                  inactiveTrackColor: Colors.grey,
                  secondary: Icon(Icons.emoji_symbols, color: Colors.white),
                ),
                SizedBox(height: 30.0),
                // Botão para gerar a senha
                Center(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.autorenew),
                    label: Text('Gerar Senha'),
                    onPressed: _gerarSenha,
                  ),
                ),
                SizedBox(height: 30.0),
                // Exibição da senha gerada
                if (_senhaGerada.isNotEmpty) ...[
                  Text(
                    'Senha Gerada:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _senhaGerada,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy, color: Colors.purple),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _senhaGerada),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Senha copiada!'),
                                backgroundColor: Colors.purple,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Exibição do nível de confiabilidade
                  Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: _obterCorConfiabilidade(),
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Nível de Confiabilidade: ',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[300],
                        ),
                      ),
                      Expanded( // Para evitar o overflow
                        child: Text(
                          _nivelConfiabilidade,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: _obterCorConfiabilidade(),
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Garantir que o texto não ultrapasse
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}