/// Mirrors the backend's `CreateAgentSaleDto` (`POST /agent/sales`).
enum AgentPaymentType {
  cash,
  debt;

  String toWire() => this == cash ? 'CASH' : 'DEBT';
}

class AgentSaleLineParams {
  const AgentSaleLineParams({required this.agentProductId, required this.quantity, required this.unitPrice});

  final String agentProductId;
  final double quantity;
  final double unitPrice;

  Map<String, dynamic> toJson() => {'agentProductId': agentProductId, 'quantity': quantity, 'unitPrice': unitPrice};
}

class AgentSaleCustomerParams {
  const AgentSaleCustomerParams({required this.firstName, this.lastName, required this.phone});

  final String firstName;
  final String? lastName;
  final String phone;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        if (lastName != null && lastName!.isNotEmpty) 'lastName': lastName,
        'phone': phone,
      };
}

class CreateAgentSaleParams {
  const CreateAgentSaleParams({required this.lines, required this.paymentType, this.customer, this.notes});

  final List<AgentSaleLineParams> lines;
  final AgentPaymentType paymentType;

  /// Required on debt; optional for cash (otherwise the lead agent's walk-in buyer).
  final AgentSaleCustomerParams? customer;
  final String? notes;

  Map<String, dynamic> toRequestBody() => {
        'items': [for (final l in lines) l.toJson()],
        'paymentType': paymentType.toWire(),
        if (customer != null) 'customer': customer!.toJson(),
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}
