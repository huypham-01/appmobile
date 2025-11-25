import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String description;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // return InkWell(
    //   onTap: onTap,
    //   child: Container(
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(30), // cong đều 4 góc
    //       border: Border.all(
    //         color: const Color.fromARGB(57, 84, 84, 91),
    //         width: 0.4,
    //       ),
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.black.withOpacity(0.05),
    //           blurRadius: 6,
    //           offset: const Offset(0, 3),
    //         ),
    //       ],
    //     ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Thanh màu phía trên (không cần borderRadius riêng nữa)
    //         Container(
    //           height: 4,
    //           width: double.infinity,
    //           decoration: const BoxDecoration(
    //             color: Color.fromARGB(255, 20, 79, 173),
    //           ),
    //         ),

    //         // Nội dung chính
    //         Padding(
    //           padding: const EdgeInsets.only(
    //             top: 14,
    //             left: 16,
    //             right: 16,
    //             bottom: 12,
    //           ),
    //           child: Row(
    //             children: [
    //               Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     title,
    //                     style: const TextStyle(
    //                       fontSize: 14,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                     overflow: TextOverflow.ellipsis,
    //                   ),
    //                   if (description.isNotEmpty)
    //                     Text(
    //                       description,
    //                       style: const TextStyle(
    //                         fontSize: 14,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                       overflow: TextOverflow.ellipsis,
    //                     ),
    //                   const SizedBox(height: 4),
    //                   Text(
    //                     value,
    //                     style: const TextStyle(
    //                       fontSize: 20,
    //                       fontWeight: FontWeight.bold,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               const Spacer(),
    //               Container(
    //                 padding: const EdgeInsets.all(8),
    //                 decoration: BoxDecoration(
    //                   color: color,
    //                   borderRadius: BorderRadius.circular(12),
    //                 ),
    //                 child: Icon(icon, color: Colors.black54),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15), // bo toàn card
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh màu phía trên
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(color: color),
              ),

              // Nội dung chính
              Padding(
                padding: const EdgeInsets.only(
                  top: 14,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột text chiếm không gian còn lại
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),

                          const SizedBox(height: 4),

                          // Value
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          // Description (chỉ hiện trên tablet trở lên)
                          if (MediaQuery.of(context).size.width >= 600 &&
                              description.isNotEmpty)
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color.fromARGB(255, 160, 156, 156),
                              ),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Icon bên phải
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.black54,
                        size:
                            22, // Điều chỉnh kích thước icon (giá trị nhỏ hơn để icon nhỏ lại)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
