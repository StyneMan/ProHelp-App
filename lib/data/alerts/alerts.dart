class Alerts {
  String summary;
  String type;
  String createdAt;
  String status;

  Alerts({
    required this.createdAt,
    required this.summary,
    required this.type,
    required this.status,
  });
}

List<Alerts> alerts = [
  Alerts(
    createdAt: "2022-11-04 22:33:31",
    summary:
        "You have received payment of ₦2,000 for the verification of Desmond Kelvin.",
    type: "payment",
    status: "info",
  ),
  Alerts(
    createdAt: "2022-11-04 22:33:31",
    summary: "Employee verification for Blessing James was not approved. ",
    type: "verification",
    status: "failed",
  ),
  Alerts(
    createdAt: "2022-11-04 22:33:31",
    summary: "Address verification for Bola King was approved.",
    type: "verification",
    status: "success",
  ),
  Alerts(
    createdAt: "2022-11-04 22:33:31",
    summary: "You have received payment of ₦1,500 for the verification of Adaora Fred.",
    type: "payment",
    status: "info",
  ),
  Alerts(
    createdAt: "2022-11-04 22:33:31",
    summary: "Your Bio Data update request has been approved.",
    type: "bio",
    status: "success",
  ),
];
