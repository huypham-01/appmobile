import 'dart:convert';
import 'dart:math';

class MockWorkingInstructionService {
  static Future<Map<String, dynamic>> getWorkingInstructions() async {
    await Future.delayed(const Duration(seconds: 1)); // giả lập delay API

    return {
      "status": "success",
      "message": "Lấy dữ liệu thành công",
      "data": [
        {
          "id": "a0928b46-7517-4727-83aa-5edb3821ab69",
          "code": "DI-AC-000008",
          "name": "Water connectors and water pipes",
          "type": "Daily Inspection",
          "schema":
              "[{\"stepIndex\":1,\"items\":[{\"id\":\"frzbetix\",\"type\":\"label\",\"text\":\"Water connectors and water pipes\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
          "updated_at": "2025-09-16 14:34:19",
          "frequency": "Daily",
          "unit_type": "",
          "unit_value": "",
          "category": "VD",
        },
        {
          "id": "1a554f34-9d24-44e2-a394-59ca352aa6a1",
          "code": "DI-VD-000004",
          "name": "Parting line venting",
          "type": "Daily Inspection",
          "schema":
              "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"9qos3qqv\",\"type\":\"label\",\"text\":\"Parting line venting\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
          "updated_at": "2025-10-18 16:58:03",
          "frequency": "Daily",
          "unit_type": "",
          "unit_value": "",
          "category": "VD",
        },
        {
          "id": "25f13955-190f-4106-8c0f-89f87cec385f",
          "code": "ML01-VT-000017",
          "name": "copper wire tensile inspection",
          "type": "Maintenance Level 1",
          "schema":
              "[{\"stepIndex\":1,\"isVisible\":true,\"items\":[{\"id\":\"too2xhsf\",\"type\":\"label\",\"text\":\"Induced tensile force...\"}]}]",
          "updated_at": "2025-11-27 13:33:13",
          "frequency": "Unit",
          "unit_type": "cycle",
          "unit_value": "5000000",
          "category": "VT",
        },
      ],
      "total_items": 17,
      "total_pages": 1,
      "total_in_all_page": 17,
    };
  }
}

class MockEquipmentService {
  static Future<Map<String, dynamic>> getEquipments({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock raw data
    final List<Map<String, dynamic>> allData = List.generate(50, (i) {
      return {
        "uuid": "uuid-$i",
        "machine_id": "MC-${1000 + i}",
        "family": ["Family A", "Family B", "Family C"][i % 3],
        "model": "Model ${i + 1}",
        "cavity": "${(i % 4) + 1}",
        "manufacturer": "Maker ${i % 5}",
        "manufacturing_date": "2024-01-${(i % 28) + 1}",
        "history_count": Random().nextInt(200),
        "unit": "pcs",
        "category": ["VD", "VT", "AC"][i % 3],
      };
    });

    // Apply search
    List<Map<String, dynamic>> filtered = [...allData];
    if (search != null && search.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e["machine_id"].toLowerCase().contains(search.toLowerCase()) ||
                e["family"].toLowerCase().contains(search.toLowerCase()),
          )
          .toList();
    }

    // Filter category
    if (category != null && category.isNotEmpty && category != "All") {
      filtered = filtered.where((e) => e["category"] == category).toList();
    }

    // Filter status (mock)
    if (status != null && status.isNotEmpty && status != "All") {
      filtered = filtered.where((e) {
        final mockStatus = [
          "Active",
          "Inactive",
          "Maintenance",
        ][e["uuid"].hashCode % 3];
        return mockStatus == status;
      }).toList();
    }

    // Pagination
    int totalItems = filtered.length;
    int totalPages = (totalItems / limit).ceil();
    int start = (page - 1) * limit;
    int end = min(start + limit, filtered.length);

    final pageData = (start < filtered.length)
        ? filtered.sublist(start, end)
        : [];

    return {
      "status": "success",
      "message": "Mock equipment loaded",
      "data": pageData,
      "total_items": totalItems,
      "total_pages": totalPages,
      "total_in_all_page": totalItems,
    };
  }
}

const mockInspectionJson = {
  "status": "success",
  "date": "2025-12-01",
  "data": [
    {
      "equipment_id": "837db74f-178e-499b-b6e8-5c8bd0feb388",
      "machine_id": "TGN001_IN",
      "model": null,
      "cavity": null,
      "count_done": 0,
      "count_pending": 8,
      "category_name": "TGN",
      "history_count": "1599",
      "manufacturing_date": "0000-00-00",
      "unit": "h",
      "manufacturer": null,
      "status": "incomplete",
      "inspectors": "",
      "inspected_date": "2025-11-27 11:48:36",
    },
    {
      "equipment_id": "837db74f-178e-499b-b6e8-5c8bd0feb314",
      "machine_id": "TGN001_TA",
      "model": null,
      "cavity": null,
      "count_done": 0,
      "count_pending": 8,
      "category_name": "TGN",
      "history_count": "1599",
      "manufacturing_date": "0000-00-00",
      "unit": "h",
      "manufacturer": null,
      "status": "incomplete",
      "inspectors": "",
      "inspected_date": "2025-11-27 11:48:36",
    },
    {
      "equipment_id": "837db74f-178e-499b-b6e8-5c8bd0feb303",
      "machine_id": "TGN001_BS",
      "model": null,
      "cavity": null,
      "count_done": 0,
      "count_pending": 8,
      "category_name": "TGN",
      "history_count": "1599",
      "manufacturing_date": "0000-00-00",
      "unit": "h",
      "manufacturer": null,
      "status": "incomplete",
      "inspectors": "",
      "inspected_date": "2025-11-27 11:48:36",
    },
  ],
};
const mockEquipmentDetailJson = {
  "status": "success",
  "data": [
    {
      "code": "DI-AC-000008",
      "wi_id": "e7a4b49f-a444-4134-9f6e-c0163b7cee9c",
      "content": "Water connectors and water pipesss",
      "inspected_date": null,
      "date_start": "2025-11-06 00:00:00",
      "status": null,
      "result": null,
      "inspector_id": null,
      "inspector_name": null,
    },
    {
      "code": "DI-AC-000008",
      "wi_id": "e1758fb2-189d-45ac-8f89-53d0c55e0fbd",
      "content": "Water connectors and water pipes pipes",
      "inspected_date": null,
      "date_start": "2025-12-01 00:00:00",
      "status": null,
      "result": null,
      "inspector_id": null,
      "inspector_name": null,
    },
  ],
};
const mockFormJson = {
  "status": "success",
  "message": "Lấy dữ liệu thành công",
  "data": [
    {
      "uuid": "e7a4b49f-a444-4134-9f6e-c0163b7cee9c",
      "wi_id": "a0928b46-7517-4727-83aa-5edb3821ab69",
      "code": "DI-AC-000008",
      "name": "Water connectors and water pipes",
      "type": "Daily Inspection",

      // ★★★★★ NHIỀU STEP ★★★★★
      "schema": """
      [
        {
          "stepIndex": 1,
          "items": [
            {
              "id": "label001",
              "type": "label",
              "text": "General Information",
              "heading": "h2",
              "bold": true,
              "italic": false,
              "underline": false
            },
            {
              "id": "yesno001",
              "type": "yesno",
              "question": "Is the machine operating normally?",
              "default": null
            }
          ]
        },
        {
          "stepIndex": 2,
          "items": [
            {
              "id": "label002",
              "type": "label",
              "text": "Select inspection options",
              "heading": "h3",
              "bold": false,
              "italic": false,
              "underline": false
            },
            {
              "id": "single001",
              "type": "single",
              "question": "Oil level status",
              "options": ["Good", "Low", "Needs refill"],
              "default": null
            }
          ]
        },
        {
          "stepIndex": 3,
          "items": [
            {
              "id": "multi001",
              "type": "multiple",
              "question": "Which issues did you find?",
              "options": ["Leak", "Noise", "Vibration", "Heat"],
              "default": []
            },
            {
              "id": "staticImg001",
              "type": "staticImage",
              "url": "https://picsum.photos/300/200"
            }
          ]
        }
      ]
      """,

      "category_id": "3bdb2847-2ad1-4eb7-b263-fde581aeebd3",
      "equipment_id": "837db74f-178e-499b-b6e8-5c8bd0feb388",
      "status": null,
      "result": null,
      "date_start": "2025-11-06 00:00:00",
      "inspected_date": null,
      "inspector_id": null,
      "created_by": null,
      "updated_by": null,
      "deleted_by": null,
      "created_at": "2025-11-06 08:10:22",
      "updated_at": "2025-11-06 08:10:22",
      "deleted_at": null,
    },
  ],
};
const mockMaintenanceJson = {
  "status": "success",
  "date": "2025-12-01",
  "data": [
    {
      "uuid": "5a106201-4856-4358-badb-0aaae21ae1c2",
      "machine_id": "test11",
      "model": "test11",
      "cavity": "123",
      "manufacturer": "test1",
      "manufacturing_date": "0000-00-00",
      "history_count": "39000",
      "unit": "shot",
      "daily_rate": "1100",
      "category_name": "Injection",
      "category_id": "002ab1c3-b86e-49fc-98fd-3393b420bd73",
      "created_by": null,
      "updated_by": null,
      "deleted_by": null,
      "created_at": "2025-10-29 14:31:52",
      "updated_at": "2025-10-29 15:05:08",
      "deleted_at": null,
      "total": "2",
      "done": "0",
      "status": "pending",
      "inspectors": null,
      "inspected_date": null,
    },
    {
      "uuid": "837db74f-178e-499b-b6e8-5c8bd0feb388",
      "machine_id": "TGN001_AC",
      "model": null,
      "cavity": null,
      "manufacturer": null,
      "manufacturing_date": "0000-00-00",
      "history_count": "1599",
      "unit": "h",
      "daily_rate": "24",
      "category_name": "TGN",
      "category_id": "3760c33e-95df-4f9e-b825-bf80fabe4020",
      "created_by": null,
      "updated_by": null,
      "deleted_by": null,
      "created_at": "2025-10-15 16:06:39",
      "updated_at": "2025-11-19 10:49:57",
      "deleted_at": null,
      "total": "1",
      "done": "0",
      "status": "pending",
      "inspectors": null,
      "inspected_date": null,
    },
  ],
};
const mockMaintenanceDetailJson = {
  "status": "success",
  "date": "2025-12-01",
  "data": [
    {
      "uuid": "96fbc31c-1e21-4503-b628-88e2a4670501",
      "wi_id": "4b32bdcb-2a77-43b9-adea-aea32e8ed6d9",
      "equipment_id": "5a106201-4856-4358-badb-0aaae21ae1c2",
      "code": "ML01-AJ-000015",
      "name": "test m1",
      "type": "Maintenance Level 1",
      "schema":
          "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":true,\"items\":[{\"id\":\"gsfddqql\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false},{\"id\":\"snfj0hjq\",\"type\":\"yesno\",\"question\":\"test 1\"}]},{\"stepIndex\":2,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"4oqkde9z\",\"type\":\"yesno\",\"question\":\"test 1\"},{\"id\":\"yd2qajkk\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
      "category_id": "0bbb36f4-8356-4a82-bb53-972f7252f5a0",
      "frequency": "Unit",
      "unit_value": "19000",
      "unit_type": "shot",
      "status": "pending",
      "result": null,
      "times": "1",
      "count_target": "57000",
      "date_start": "2025-11-14 15:05:09",
      "inspected_date": null,
      "inspector_id": null,
      "created_by": null,
      "updated_by": null,
      "deleted_by": null,
      "created_at": null,
      "updated_at": null,
      "deleted_at": null,
      "username": null,
    },
    {
      "uuid": "96fbc31c-1e21-4503-b628-88e2a4670501",
      "wi_id": "4b32bdcb-2a77-43b9-adea-aea32e8ed6d9",
      "equipment_id": "5a106201-4856-4358-badb-0aaae21ae1c2",
      "code": "ML01-AJ-000015",
      "name": "test m2",
      "type": "Maintenance Level 2",
      "schema":
          "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":true,\"items\":[{\"id\":\"gsfddqql\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false},{\"id\":\"snfj0hjq\",\"type\":\"yesno\",\"question\":\"test 1\"}]},{\"stepIndex\":2,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"4oqkde9z\",\"type\":\"yesno\",\"question\":\"test 1\"},{\"id\":\"yd2qajkk\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
      "category_id": "0bbb36f4-8356-4a82-bb53-972f7252f5a0",
      "frequency": "Unit",
      "unit_value": "19000",
      "unit_type": "shot",
      "status": "pending",
      "result": null,
      "times": "1",
      "count_target": "57000",
      "date_start": "2025-11-14 15:05:09",
      "inspected_date": null,
      "inspector_id": null,
      "created_by": null,
      "updated_by": null,
      "deleted_by": null,
      "created_at": null,
      "updated_at": null,
      "deleted_at": null,
      "username": null,
    },
  ],
};
const mockOverdueJson = {
  "data": [
    {
      "uuid": "837db74f-178e-499b-b6e8-5c8bd0feb388",
      "machine_id": "TGN001_AC",
      "model": null,
      "cavity": null,
      "total_overdue": "8",
    },
    {
      "uuid": "5a106201-4856-4358-badb-0aaae21ae1c2",
      "machine_id": "test11",
      "model": "test1",
      "cavity": "123",
      "total_overdue": "2",
    },
  ],
};
const mockOverdueDetailJson = {
  "data": [
    {
      "code": "ML01-AJ-000015",
      "description": "test m1",
      "type": "Maintenance Level 1",
      "date_start": "2025-11-14 15:05:09",
      "schema":
          "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":true,\"items\":[{\"id\":\"gsfddqql\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false},{\"id\":\"snfj0hjq\",\"type\":\"yesno\",\"question\":\"test 1\"}]},{\"stepIndex\":2,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"4oqkde9z\",\"type\":\"yesno\",\"question\":\"test 1\"},{\"id\":\"yd2qajkk\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
      "uuid": "96fbc31c-1e21-4503-b628-88e2a4670501",
    },
    {
      "code": "ML01-AJ-000015",
      "description": "test m2",
      "type": "Maintenance Level 2",
      "date_start": "2025-11-14 15:05:09",
      "schema":
          "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":true,\"items\":[{\"id\":\"gsfddqql\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false},{\"id\":\"snfj0hjq\",\"type\":\"yesno\",\"question\":\"test 1\"}]},{\"stepIndex\":2,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"4oqkde9z\",\"type\":\"yesno\",\"question\":\"test 1\"},{\"id\":\"yd2qajkk\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
      "uuid": "96fbc31c-1e21-4503-b628-88e2a4670501",
    },
    {
      "code": "ML01-AJ-000015",
      "description": "test m3",
      "type": "Maintenance Level 3",
      "date_start": "2025-11-14 15:05:09",
      "schema":
          "[{\"stepIndex\":1,\"isVisible\":true,\"preparation\":true,\"items\":[{\"id\":\"gsfddqql\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false},{\"id\":\"snfj0hjq\",\"type\":\"yesno\",\"question\":\"test 1\"}]},{\"stepIndex\":2,\"isVisible\":true,\"preparation\":false,\"items\":[{\"id\":\"4oqkde9z\",\"type\":\"yesno\",\"question\":\"test 1\"},{\"id\":\"yd2qajkk\",\"type\":\"label\",\"text\":\"test 1\",\"heading\":\"h3\",\"bold\":false,\"italic\":false,\"underline\":false}]}]",
      "uuid": "96fbc31c-1e21-4503-b628-88e2a4670501",
    },
  ],
};
const _fakeJwtPayload = {
  "sub": "12345",
  "username": "admin",
  "role": "admin",
  "exp": 1893456000, // năm 2030
};

String generateMockJwt() {
  final header = base64Url.encode(utf8.encode(jsonEncode({"alg": "HS256"})));
  final payload = base64Url.encode(utf8.encode(jsonEncode(_fakeJwtPayload)));
  const signature = "mocksignature";
  return "$header.$payload.$signature";
}

const mockLoginResponse = {
  "accessToken": "MOCK WILL BE REPLACED",
  "refreshToken": "MOCK_REFRESH",
  "message": "Login success (mock)"
};
