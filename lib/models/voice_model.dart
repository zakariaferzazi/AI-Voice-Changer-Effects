class Voice {
  final String voiceId;
  final String name;
  final String? previewUrl;
  final String? iconUrl;

  Voice({
    required this.voiceId,
    required this.name,
    this.previewUrl,
    this.iconUrl,
  });
}
