import {
  Image,
  ImageRequireSource,
  NativeModules,
  Platform,
  processColor,
} from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-popup-menu' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const PopupMenu = NativeModules.PopupMenu
  ? NativeModules.PopupMenu
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

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

export function showPopup(params: PopupMenuProperties) {
  return new Promise((resolve) => {
    PopupMenu.showPopup(
      {
        ...params,
        buttons: params.buttons.map((b) => ({
          ...b,
          icon: b.icon ? Image.resolveAssetSource(b.icon).uri : undefined,
          tint: b.tint ? processColor(b.tint) : undefined,
        })),
      },
      (index: number) => {
        const selected = params.buttons[index];
        resolve(selected);
      }
    );
  });
}
