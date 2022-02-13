import type { ImageRequireSource } from 'react-native';

export interface PopupMenuConfigure {
  readonly isIconsFromRight?: boolean;
  readonly backgroundColor?: string;
  readonly cornerRadius?: number;
  readonly gravity?: 'top' | 'bottom';
  readonly overlayColor?: string;
  readonly minWidth?: number;
  readonly safeArea?: {
    bottom?: number;
    top?: number;
  };

  readonly item?: {
    readonly fontFamily?: string;
    readonly fontSize?: number;
    readonly height?: number;
    readonly iconSize?: number;
    readonly paddingHorizontal?: number;
    readonly separatorHeight?: number;
    readonly separatorColor?: string;
    readonly tint: string;
  };

  readonly shadow?: {
    offset: { width: number; height: number };
    color: string;
    radius: number;
    opacity: number;
  };
  elevation?: number;
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

export interface PopupMenuProperties
  extends Omit<PopupMenuConfigure, 'shadow' | 'elevation'> {
  readonly nativeID: string;
  readonly buttons: PopupMenuButton[];
  readonly frame?: { x: number; y: number; width: number; height: number };
}

export type InternalParams = PopupMenuProperties & {
  resolve: (index: number | undefined) => void;
};
