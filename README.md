# react-native-popup-menu

This library allows to create simple popup menus

## Installation

```sh
"react-native-popup-menu": "sergeymild/react-native-popup-menu"
```

## Usage

```js
import { showPopup, configurePopup, PopupHostView } from "react-native-popup-menu";

// ...

export interface PopupMenuButton {
  readonly text: string;
  readonly data?: any;
  readonly tint?: string;
  readonly icon?: ImageRequireSource;
}

interface PopupMenuConfigure {
  readonly isIconsFromRight?: boolean;
  readonly backgroundColor?: string;
  readonly cornerRadius?: number;
  readonly gravity?: 'top' | 'bottom';
  readonly overlayColor?: string;

  readonly item?: {
    readonly fontFamily?: string;
    readonly fontSize?: number;
    readonly height?: number;
    readonly iconSize?: number;
    readonly paddingHorizontal?: number;
    readonly separatorHeight?: number;
    readonly separatorColor?: string;
    readonly tint?: string;
  };

  readonly shadow?: {
    offset: { width: number; height: number };
    color: string;
    radius: number;
    opacity: number;
  };
  elevation?: number;
}

interface PopupMenuProperties {
  readonly isIconsFromRight?: boolean;
  readonly cornerRadius?: number;
  readonly buttons: PopupMenuButton[];
  readonly theme?: 'light' | 'dark';
  readonly frame?: { x: number; y: number; width: number; height: number };
  readonly gravity?: 'top' | 'bottom';
}

// default configuration for all popups
configurePopup(params: PopupMenuConfigure)

// in App.tsx
const App = () => {

  return (
    <>
      {...project}
      {/*add this to show popup above all views*/}
      <PopupHostView/>
    </>
  )
}

const selected = await showPopup({
  frame: { x, y, width, height },
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
