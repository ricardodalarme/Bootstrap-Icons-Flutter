# Boostrap Icons for Flutter

Implementation of [bootstrap icons](https://github.com/twbs/icons) v1.5.0 in Flutter  with over 1,300 icons.

[![Bootstrap Icons preview](https://github.com/twbs/icons/blob/main/.github/preview.png)](https://icons.getbootstrap.com)

<a href="https://icons.getbootstrap.com/"><strong>Explore Bootstrap Icons »</strong></a>

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  bootstrap_icons: ^1.5.0
```

### Usage

```dart
import 'package:boostrap_icons/boostrap_icons.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(BootstrapIcons.alarm),
     );
  }
}
```

### Contributing

If you want to contribute to this project, you may easily create issues and send PRs. Please take note that your code contributions will be applicable under MIT license unless specified otherwise.

### Credits

- Ricardo Dalarme (Package)
- @twbs (Icons)