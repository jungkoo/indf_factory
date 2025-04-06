# indf-flutter-factory
프로젝트를 쉽게 구성하기위한 로직을 보유한다

다음과 같이 선언후 사용가능 하다.

- pubsec.yaml
    ```yaml
    dependencies:
      indf_factory:
        git:
          url: https://github.com/jungkoo/indf_factory.git
          ref: main
    ```
  

# supabase 사용하기
기본적으로는 아래와 같이 선언하여 정보를 기입해준다.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {   
    SupabaseInstance().initialize(
        'URL 입력',
        'KEY 입력'
    );
    runApp(const MyApp());
}
```