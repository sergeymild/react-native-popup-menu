import React, {forwardRef, memo} from 'react';
import {requireNativeComponent, TouchableOpacityProps, View} from 'react-native';

const ScalePressManager = requireNativeComponent<any>('ScalePressView');

type Props = Pick<
  TouchableOpacityProps,
  'accessibilityLabel' | 'style' | 'onPress' | 'onLongPress' | 'children'
> & { scale?: number; durationIn?: number; durationOut?: number };

export const SKIP_SCALE_PRESS = 'skipScalePress';

export const ScalePress = memo(forwardRef<View, Props>((props, ref) => {
  return (
    <ScalePressManager
      ref={ref}
      onLongPress={props.onLongPress}
      scale={props.scale}
      durationIn={props.durationIn}
      durationOut={props.durationOut}
      accessibilityLabel={props.accessibilityLabel}
      style={props.style}
      onPress={props.onPress}
      children={props.children}
    />
  );
}));
