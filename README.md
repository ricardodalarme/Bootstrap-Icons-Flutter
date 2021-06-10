<p align="center">
  <a href="https://pub.dev/packages/bootstrap_icons">
    <img src="https://v5.getbootstrap.com/docs/5.0/assets/brand/bootstrap-logo-shadow.png" alt="Bootstrap logo" width="200" height="165">
  </a>
</p>

<h3 align="center"><a href="https://pub.dev/packages/bootstrap_icons">Bootstrap Icons for Flutter</a></h3>


<p align="center">
  Implementation of Bootstrap Icons v1.5.0 in Flutter with over 1,300 icons..
  <br>
  <a href="https://icons.getbootstrap.com/"><strong>Explore Bootstrap Icons »</strong></a>
  <br>

</p>

[![Bootstrap Icons preview](https://github.com/twbs/icons/blob/main/.github/preview.png)](https://icons.getbootstrap.com)

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  bootstrap_icons: ^1.5.0
```

### Usage

```dart
import 'package:bootstrap_icons/bootstrap_icons.dart';

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
- [@twbs](https://github.com/twbs) (Icons)
