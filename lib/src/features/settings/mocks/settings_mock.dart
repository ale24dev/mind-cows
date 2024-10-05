import 'package:supabase_flutter/supabase_flutter.dart';

/// Mocks for the settings feature
final profileImagesMock = List.generate(5, (index) {
  return FileObject(
    name: 'avatar${index + 1}.png',
    id: index.toString(),
    updatedAt: '',
    createdAt: '',
    lastAccessedAt: '',
    metadata: {
      'eTag': '"c5e8c553235d9af30ef4f6e280790b92"',
      'size': 32175,
      'mimetype': 'image/png',
      'cacheControl': 'max-age=3600',
      'lastModified': '2024-05-22T23:06:05.574Z',
      'contentLength': 32175,
      'httpStatusCode': 200,
    },
    owner: 'owner-id',
    buckets: null,
    bucketId: index.toString(),
  );
});
