import { Image, NativeModules, Platform, processColor } from 'react-native';
import type { PopupMenuConfigure, PopupMenuProperties } from './types';
// @ts-ignore
import { PopupMenuButton } from './types';

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

export function configurePopup(params: PopupMenuConfigure) {
  PopupMenu.configurePopup({
    ...params,
    backgroundColor: params.backgroundColor
      ? processColor(params.backgroundColor)
      : undefined,
    item: {
      ...params.item,
      separatorColor: params.item?.separatorColor
        ? processColor(params.item.separatorColor)
        : undefined,
      iconTint: params.item?.iconTint ? processColor(params.item.iconTint) : undefined,
      textColor: params.item?.textColor ? processColor(params.item.textColor) : undefined
    },

    shadow: !params.shadow
      ? undefined
      : {
          ...params.shadow,
          color: processColor(params.shadow.color),
        },
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
          iconTint: b.iconTint ? processColor(b.iconTint) : undefined,
          textColor: b.textColor ? processColor(b.textColor) : undefined,
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

export { PopupMenuButton };
