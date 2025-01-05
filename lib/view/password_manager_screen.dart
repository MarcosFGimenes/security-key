import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  _PasswordManagerScreenState createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Função para pegar o ID do usuário logado
  User? get _user => _auth.currentUser;

  // Carregar senhas do Firestore
  Future<List<Map<String, dynamic>>> _loadPasswords() async {
    if (_user == null) return [];

    // Pega os documentos da coleção 'senhas' do Firestore
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('senhas')
        .get();

    // Converte os documentos para uma lista de senhas com valores do tipo String
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // Adiciona o ID do documento
        'name': doc['name'].toString(),
        'password': doc['password'].toString(),
      };
    }).toList();
  }

  // Função para adicionar senha ao Firestore
  Future<void> _addPassword() async {
    final name = _nameController.text;
    final password = _passwordController.text;

    if (name.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha ambos os campos!')),
      );
      return;
    }

    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).collection('senhas').add({
        'name': name,
        'password': password,
      });
      _nameController.clear();
      _passwordController.clear();
      setState(() {});
    }
  }

  // Função para excluir uma senha do Firestore
  Future<void> _deletePassword(String docId) async {
    if (_user != null) {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('senhas')
          .doc(docId) // Usa o ID do documento para deletar
          .delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Senhas'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para nome da senha
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Senha (ex: Email Google)',
              ),
            ),
            const SizedBox(height: 10),
            // Campo para senha
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPassword,
              child: const Text('Adicionar Senha'),
            ),
            const SizedBox(height: 20),
            // Carregar senhas do Firestore
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadPasswords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }

                final passwords = snapshot.data ?? [];

                return Expanded(
                  child: ListView.builder(
                    itemCount: passwords.length,
                    itemBuilder: (context, index) {
                      final password = passwords[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(password['name']!),
                          subtitle: Text(password['password']!),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deletePassword(password['id']); // Passando o ID do documento
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
