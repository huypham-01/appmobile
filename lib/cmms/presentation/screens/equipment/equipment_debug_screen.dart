// // File: lib/screens/equipment/equipment_debug_screen.dart

// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:mobile/utils/constants.dart';

// class EquipmentDebugScreen extends StatefulWidget {
//   const EquipmentDebugScreen({super.key});

//   @override
//   State<EquipmentDebugScreen> createState() => _EquipmentDebugScreenState();
// }

// class _EquipmentDebugScreenState extends State<EquipmentDebugScreen> {
//   String _debugLog = '';
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _addLog('🚀 Debug Screen initialized');
//   }

//   void _addLog(String message) {
//     setState(() {
//       _debugLog +=
//           '[${DateTime.now().toString().substring(11, 19)}] $message\n';
//     });
//     print(message); // Cũng in ra console
//   }

//   void _clearLog() {
//     setState(() {
//       _debugLog = '';
//     });
//   }

//   Future<void> _testRawAPI() async {
//     _clearLog();
//     _addLog('🔄 Starting RAW API Test...');

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // Test 1: Kiểm tra URL cơ bản
//       const baseUrl = '$baseUrl/cmms/cip3/index.php';
//       final queryParams = {
//         'c': 'EquipmentController',
//         'm': 'getAllEquipments',
//         'page': '1',
//         'limit': '5',
//       };

//       final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
//       _addLog('📡 Request URL: $uri');

//       // Test connection
//       _addLog('🔗 Testing connection...');
//       final response = await http
//           .get(
//             uri,
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//           )
//           .timeout(const Duration(seconds: 10));

//       _addLog('📊 Status Code: ${response.statusCode}');
//       _addLog('📏 Response Length: ${response.body.length} characters');

//       if (response.statusCode == 200) {
//         _addLog('✅ HTTP Success!');

//         // Log raw response
//         _addLog('📄 Raw Response (first 500 chars):');
//         _addLog(
//           response.body.length > 500
//               ? '${response.body.substring(0, 500)}...'
//               : response.body,
//         );

//         // Try parse JSON
//         try {
//           final jsonData = json.decode(response.body);
//           _addLog('✅ JSON Parse Success!');

//           // Check response structure
//           _addLog('🔍 Response Analysis:');
//           _addLog('   Type: ${jsonData.runtimeType}');

//           if (jsonData is Map) {
//             jsonData.forEach((key, value) {
//               if (value is List) {
//                 _addLog('   [$key]: List with ${value.length} items');
//               } else {
//                 _addLog('   [$key]: $value');
//               }
//             });

//             // Specific checks for expected fields
//             if (jsonData.containsKey('status')) {
//               _addLog('✅ Has "status" field: ${jsonData['status']}');
//             } else {
//               _addLog('❌ Missing "status" field');
//             }

//             if (jsonData.containsKey('data')) {
//               final data = jsonData['data'];
//               if (data is List) {
//                 _addLog('✅ Has "data" field: List with ${data.length} items');
//                 if (data.isNotEmpty) {
//                   _addLog('📦 First item structure:');
//                   final firstItem = data[0];
//                   if (firstItem is Map) {
//                     firstItem.forEach((key, value) {
//                       _addLog('     $key: $value');
//                     });
//                   }
//                 } else {
//                   _addLog('⚠️ Data array is empty');
//                 }
//               } else {
//                 _addLog(
//                   '❌ "data" field is not a List, type: ${data.runtimeType}',
//                 );
//               }
//             } else {
//               _addLog('❌ Missing "data" field');
//             }
//           } else {
//             _addLog('❌ Response is not a Map, type: ${jsonData.runtimeType}');
//           }
//         } catch (e) {
//           _addLog('❌ JSON Parse Error: $e');
//           _addLog('🔍 Raw response for debugging:');
//           _addLog(response.body);
//         }
//       } else {
//         _addLog('❌ HTTP Error: ${response.statusCode}');
//         _addLog('📄 Error Response: ${response.body}');
//       }
//     } catch (e) {
//       _addLog('💥 Network Error: $e');
//       _addLog('🔧 Possible causes:');
//       _addLog('   - Network connectivity issue');
//       _addLog('   - Server not running on 192.168.110.2');
//       _addLog('   - Firewall blocking request');
//       _addLog('   - Wrong IP/Port');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   Future<void> _testServiceMethod() async {
//     _addLog('\n🧪 Testing Service Method...');

//     try {
//       // Import your service
//       // final response = await EquipmentService.getEquipments(page: 1, limit: 5);
//       // _addLog('✅ Service Success: Got ${response.data.length} items');

//       _addLog('⚠️ Uncomment EquipmentService test in debug screen');
//     } catch (e) {
//       _addLog('❌ Service Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Equipment Debug'),
//         backgroundColor: Colors.orange,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.clear),
//             onPressed: _clearLog,
//             tooltip: 'Clear Log',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Test buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _testRawAPI,
//                     icon: const Icon(Icons.bug_report),
//                     label: const Text('Test Raw API'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: _isLoading ? null : _testServiceMethod,
//                     icon: const Icon(Icons.build),
//                     label: const Text('Test Service'),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Info card
//             Card(
//               color: Colors.blue.shade50,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '🔍 Debug Information',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'URL: $baseUrl/cmms/cip3/index.php\n'
//                       'Controller: EquipmentController\n'
//                       'Method: getAllEquipments\n'
//                       'Expected: JSON with status, data fields',
//                       style: TextStyle(fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Loading indicator
//             if (_isLoading) const LinearProgressIndicator(),

//             const SizedBox(height: 8),

//             // Log output
//             Expanded(
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Text(
//                     _debugLog.isEmpty
//                         ? 'Click "Test Raw API" to start debugging...\n\n'
//                               '💡 This will help identify:\n'
//                               '  • Network connectivity issues\n'
//                               '  • API response format\n'
//                               '  • JSON parsing problems\n'
//                               '  • Data structure mismatches'
//                         : _debugLog,
//                     style: const TextStyle(
//                       fontFamily: 'monospace',
//                       fontSize: 11,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // Quick actions
//             Wrap(
//               spacing: 8,
//               children: [
//                 ActionChip(
//                   label: const Text('Copy URL'),
//                   avatar: const Icon(Icons.copy, size: 16),
//                   onPressed: () {
//                     // Copy URL to clipboard
//                     _addLog(
//                       '📋 URL copied to clipboard (implement with clipboard package)',
//                     );
//                   },
//                 ),
//                 ActionChip(
//                   label: const Text('Test Browser'),
//                   avatar: const Icon(Icons.web, size: 16),
//                   onPressed: () {
//                     _addLog('🌐 Test this URL in browser:');
//                     _addLog(
//                       '$baseUrl/cmms/cip3/index.php?c=EquipmentController&m=getAllEquipments&page=1&limit=5',
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
