// import 'package:flutter/material.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';

// class ContactsPage extends StatefulWidget {
//   const ContactsPage({super.key});

//   @override
//   State<ContactsPage> createState() => _ContactsPageState();
// }

// class _ContactsPageState extends State<ContactsPage> {
//   List<Contact> _contacts = [];
//   List<Contact> _filteredContacts = [];
//   bool _isLoading = true;
//   final _searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchContacts();
//   }

//   Future<void> _fetchContacts() async {
//     if (await FlutterContacts.requestPermission()) {
//       final contacts = await FlutterContacts.getContacts(withProperties: true);
//       setState(() {
//         _contacts = contacts;
//         _filteredContacts = contacts;
//         _isLoading = false;
//       });
//     }
//   }

//   void _filterContacts(String query) {
//     setState(() {
//       _filteredContacts = _contacts.where((contact) {
//         final name = contact.displayName.toLowerCase();
//         return name.contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(title: const Text('Contacts')),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search contacts...',
//                 prefixIcon: const Icon(Icons.search),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onChanged: _filterContacts,
//             ),
//           ),
        
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: _filteredContacts.length,
//                     itemBuilder: (context, index) {
//                       final contact = _filteredContacts[index];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           child: Text(contact.displayName[0]),
//                         ),
//                         title: Text(contact.displayName),
//                         subtitle: Text(contact.phones.isNotEmpty
//                             ? contact.phones.first.number
//                             : 'No numbers in your phone'),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }
