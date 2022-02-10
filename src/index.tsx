import {
  Dimensions,
  LayoutChangeEvent,
  Modal,
  Platform,
  StyleSheet,
  TouchableOpacity,
  View,
  ViewStyle,
} from 'react-native';
import React, { useCallback, useEffect, useRef, useState } from 'react';
import type {
  InternalParams,
  PopupMenuButton,
  PopupMenuConfigure,
  PopupMenuProperties,
} from './types';
import { MenuListItem } from './MenuListItem';

let defaultParams: PopupMenuConfigure = {};

export function configurePopup(params: PopupMenuConfigure) {
  defaultParams = { ...params };
}

type PopupFrame =
  | { x: number; y: number; width: number | undefined }
  | undefined;
type Listener = (params: InternalParams) => void;
let listener: Listener | undefined;

export const PopupHostView: React.FC = () => {
  const modalRef = useRef<Modal>(null);
  const [params, setParams] = useState<InternalParams | undefined>();
  const [popupFrame, setPopupFrame] = useState<PopupFrame>();

  useEffect(() => {
    listener = setParams;
    return () => {
      listener = undefined;
    };
  }, []);

  const onShow = () => {
  };

  const onDismiss = () => {
    setPopupFrame(undefined);
  };

  const onOverlayPress = () => {
    params?.resolve(undefined);
    setParams(undefined);
    setPopupFrame(undefined);
  };

  const onItemPress = useCallback(
    (index: number) => {
      params?.resolve(index);
      setParams(undefined);
      setPopupFrame(undefined);
    },
    [params]
  );

  const onLayout = (e: LayoutChangeEvent) => {
    if (!params?.frame) return;
    const layout = e.nativeEvent.layout;
    const { width, height } = Dimensions.get('screen');
    const maxHeight = (height - (params.safeArea?.bottom ?? 0))

    const additionalY =
      params.gravity === 'bottom' ? params.frame.height ?? 0 : 0;
    let newFrame: PopupFrame = {
      x: params.frame.x,
      y: params.frame.y + additionalY + (additionalY > 0 ? 8 : 0),
      width: Math.max(params.minWidth ?? 1, layout.width),
    };

    // calculate max width
    newFrame.width = Math.max(params.minWidth ?? 1, layout.width);
    if (newFrame.width > width - 32) {
      newFrame.width = width - 32;
    }

    // calculate right offset
    if (newFrame.width + layout.x >= width - 16) {
      newFrame.x = Math.max(16, width - newFrame.width - 16);
    }

    // calculate bottom offset
    if (layout.height + newFrame.y >= maxHeight) {
      newFrame.y = maxHeight - layout.height;
    }
    if (newFrame.x === 0) newFrame.x = 16;
    setPopupFrame(newFrame);
  };

  if (!params) return null;

  const containerStyle: ViewStyle = {
    position: 'absolute',
    width: popupFrame?.width,
    left: popupFrame?.x ?? params!.frame!.x,
    top: popupFrame?.y ?? params!.frame!.y,
    backgroundColor: params.backgroundColor,
    borderRadius: params.cornerRadius,
    ...Platform.select({
      ios: {
        shadowOpacity: defaultParams.shadow?.opacity ?? 0.5,
        shadowRadius: defaultParams.shadow?.radius ?? 30,
        shadowColor: defaultParams.shadow?.color ?? 'rgba(0, 0, 0, 0.16)',
        shadowOffset: {
          width: defaultParams.shadow?.offset.width ?? 0,
          height: defaultParams.shadow?.offset.height ?? 16,
        },
      },

      android: {
        elevation: defaultParams.elevation ?? 4,
      },
    }),
  };

  return (
    <Modal
      ref={modalRef}
      visible={!!params}
      hardwareAccelerated
      animationType={'fade'}
      transparent
      onShow={onShow}
      onDismiss={onDismiss}
    >
      <TouchableOpacity
        activeOpacity={1}
        onPress={onOverlayPress}
        style={[
          styles.overlay,
          defaultParams.overlayColor
            ? { backgroundColor: defaultParams.overlayColor }
            : undefined,
        ]}
      />

      {!!params && (
        <View
          onLayout={popupFrame ? undefined : onLayout}
          style={containerStyle}
        >
          {params!.buttons.map((b, index) => {
            const isLast = index === params!.buttons.length - 1;
            return (
              <MenuListItem
                index={index}
                onPress={onItemPress}
                isLast={isLast}
                button={b}
                defaultParams={defaultParams}
                params={params}
                key={index}
              />
            );
          })}
        </View>
      )}
    </Modal>
  );
};

export function showPopup(
  params: PopupMenuProperties
): Promise<PopupMenuButton | undefined> {
  return new Promise<PopupMenuButton | undefined>((resolve) => {
    listener?.({
      ...defaultParams,
      ...params,
      resolve: (index: number | undefined) => {
        if (index === undefined) return resolve(undefined);
        const selected = params.buttons[index];
        resolve(selected);
      },
    });
  });
}

export {PopupMenuButton}

const styles = StyleSheet.create({
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.2)',
  },
});
