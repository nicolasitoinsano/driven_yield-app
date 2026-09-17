class EmailConfig {
  static const serviceId = 'service_th4jyax';
  static const templateId = 'template_e0jbu2h';
  static const publicKey = 'jin3QDN3HSyQi42dm';

  static bool get isConfigured =>
      serviceId.isNotEmpty &&
      templateId.isNotEmpty &&
      publicKey.isNotEmpty &&
      serviceId != 'TU_SERVICE_ID' &&
      templateId != 'TU_TEMPLATE_ID' &&
      publicKey != 'TU_PUBLIC_KEY';
}
