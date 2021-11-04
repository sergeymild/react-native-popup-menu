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

export interface PopupMenuConfigure {
  readonly isIconsFromRight?: boolean;
  readonly backgroundColor?: string;
  readonly cornerRadius?: number;
  readonly itemHeight?: number;
  readonly itemFontFamily?: string;
  readonly itemFontSize?: number;
  readonly itemIconSize?: number;
  readonly itemPaddingHorizontal?: number;
  readonly theme?: 'light' | 'dark';
  readonly gravity?: 'top' | 'bottom';
  readonly separatorHeight?: number;
  readonly separatorColor?: string;
}

export interface PopupMenuButton {
  readonly text: string;
  readonly data?: any;
  readonly tint?: string;
  readonly icon?: ImageRequireSource;
  readonly showSeparator?: boolean;
  readonly separatorHeight?: number;
  readonly separatorColor?: string;
}

interface PopupMenuProperties extends PopupMenuConfigure {
  readonly buttons: PopupMenuButton[];
  readonly nativeID?: string;
  readonly frame?: { x: number; y: number; width: number; height: number };
}

export function configurePopup(params: PopupMenuConfigure) {
  PopupMenu.configurePopup({
    ...params,
    backgroundColor: params.backgroundColor
      ? processColor(params.backgroundColor)
      : undefined,
  });
}

export function showPopup(
  params: PopupMenuProperties
): Promise<PopupMenuButton | undefined> {
  return new Promise<PopupMenuButton | undefined>((resolve) => {
    PopupMenu.showPopup(
      {
        ...params,
        backgroundColor: params.backgroundColor
          ? processColor(params.backgroundColor)
          : undefined,
        buttons: params.buttons.map((b) => ({
          ...b,
          icon: b.icon ? Image.resolveAssetSource(b.icon).uri : undefined,
          tint: b.tint ? processColor(b.tint) : undefined,
          separatorColor: b.separatorColor
            ? processColor(b.separatorColor)
            : undefined,
        })),
      },
      (index: number | undefined) => {
        if (index === undefined) return resolve(undefined);
        const selected = params.buttons[index];
        resolve(selected);
      }
    );
  });
}
