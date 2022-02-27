import React, { memo } from 'react';
import { requireNativeComponent, TouchableOpacityProps } from 'react-native';

const ScalePressManager = requireNativeComponent<any>('ScalePressView');

type Props = Pick<
  TouchableOpacityProps,
  'accessibilityLabel' | 'style' | 'onPress'
> & { scale?: number; durationIn?: number; durationOut?: number };

export const SKIP_SCALE_PRESS = 'skipScalePress';

export const ScalePress: React.FC<Props> = memo((props) => {
  return (
    <ScalePressManager
      scale={props.scale}
      durationIn={props.durationIn}
      durationOut={props.durationOut}
      accessibilityLabel={props.accessibilityLabel}
      style={props.style}
      onPress={props.onPress}
      children={props.children}
    />
  );
});
