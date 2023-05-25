class Messages {
  String senderId;
  String senderName;
  String senderImage;
  String receiverId;
  String createdAt;
  String updatedAt;
  String message;
  bool isRead;
  int unreadCount;
  bool isOnline;

  Messages({
    required this.createdAt,
    required this.isRead,
    required this.message,
    required this.receiverId,
    required this.senderId,
    required this.unreadCount,
    required this.updatedAt,
    required this.senderName,
    required this.senderImage,
    required this.isOnline,
  });
}

List<Messages> messages = [
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 2,
    updatedAt: "",
    senderImage:
        "https://img.freepik.com/free-photo/portrait-black-man-isolated_53876-40305.jpg",
    senderName: "Jane Marry",
    isOnline: true,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 0,
    updatedAt: "",
    senderName: "John Marry",
    senderImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isOnline: true,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 1,
    senderName: "Thankgod Marry",
    updatedAt: "",
    senderImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isOnline: true,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 2,
    updatedAt: "",
    senderName: "Marry Egusi",
    senderImage:
        "https://img.freepik.com/free-photo/portrait-black-man-isolated_53876-40305.jpg",
    isOnline: true,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 0,
    senderName: "John Doe",
    updatedAt: "",
    senderImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isOnline: false,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 0,
    updatedAt: "",
    senderName: "James Bond",
    senderImage:
        "https://img.freepik.com/free-photo/portrait-black-man-isolated_53876-40305.jpg",
    isOnline: true,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 02,
    updatedAt: "",
    senderName: "Jane Doe",
    senderImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT2z7U_ydkTIazhNUnGaqMXTuoVevZJouwHVg&usqp=CAU",
    isOnline: false,
  ),
  Messages(
    createdAt: "",
    isRead: false,
    message:
        "Lorem ipsum dolor sit amet consectetur. Pellentesque sed sit vitae enim. Quis posuere.",
    receiverId: "1",
    senderId: "2",
    unreadCount: 0,
    updatedAt: "",
    senderName: "Stanley Brown",
    senderImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWxKMI371kKqsWYkrfPUwH85i49XxS9jHUbQ&usqp=CAU",
    isOnline: true,
  ),
];
