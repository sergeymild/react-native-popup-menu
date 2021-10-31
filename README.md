# react-native-popup-menu

This library allows to create simple popup menus

## Installation

```sh
"react-native-popup-menu": "sergeymild/react-native-popup-menu"
```

## Usage

```js
import { showPopup } from "react-native-popup-menu";

// ...

export interface PopupMenuButton {
  readonly text: string;
  readonly data?: any;
  readonly tint?: string;
  readonly icon?: ImageRequireSource;
}

interface PopupMenuProperties {
  readonly isIconsFromRight?: boolean;
  readonly cornerRadius?: number;
  readonly buttons: PopupMenuButton[];
  readonly theme?: 'light' | 'dark';
  readonly nativeID?: string;
  readonly frame?: { x: number; y: number; width: number; height: number };
  readonly gravity?: 'top' | 'bottom';
}

const selected = await showPopup({
  frame: { x, y, width, height },
  nativeID: 'or view nativeID',
  gravity: 'top',
  theme: 'light',
  buttons: [
    {
      text: 'Firstsadkjkjldsa',
      data: '1',
      icon: require('./assets/icShare.png'),
    },
    {
      text: 'Second',
      data: '2',
      tint: 'red',
      icon: require('./assets/icUnsave.png'),
    },
  ],
});
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
