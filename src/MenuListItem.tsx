import React, { memo } from 'react';
import {
  Image,
  ImageStyle,
  Text,
  TextStyle,
  TouchableOpacity,
  View,
  ViewStyle,
} from 'react-native';

import type {
  InternalParams,
  PopupMenuButton,
  PopupMenuConfigure,
} from './types';

interface Props {
  readonly isLast: boolean;
  readonly index: number;
  readonly button: PopupMenuButton;
  readonly defaultParams: PopupMenuConfigure;
  readonly params: InternalParams;
  readonly onPress: (index: number) => void;
}

export const MenuListItem: React.FC<Props> = memo((props) => {
  const touchableStyle: ViewStyle = {
    padding: props.params.item?.paddingHorizontal,
    minHeight: props.params.item?.height ?? 48,
    alignItems: 'center',
    justifyContent: 'space-between',
    flexDirection: 'row',
  };

  const textStyle: TextStyle = {
    fontSize: props.params.item?.fontSize ?? 14,
    color: props.button.textColor ?? props.params.item?.textColor,
    fontFamily: props.defaultParams.item?.fontFamily,
    maxWidth: props.button.icon ? '90%' : undefined,
  };

  let separatorStyle: ViewStyle | undefined;
  if (!props.isLast) {
    separatorStyle = {
      borderBottomWidth:
        props.button.separatorHeight ?? props.params.item?.separatorHeight,
      borderBottomColor:
        props.button.separatorColor ?? props.params.item?.separatorColor,
    };
  }

  let iconStyle: ImageStyle | undefined;
  if (props.button.icon) {
    iconStyle = {
      width: props.defaultParams.item?.iconSize ?? 20,
      height: props.defaultParams.item?.iconSize ?? 20,
      marginEnd: props.defaultParams.isIconsFromRight ? undefined : 12,
      marginStart: props.defaultParams.isIconsFromRight ? 12 : 0,
      tintColor: props.defaultParams.item?.iconTint ?? props.button.iconTint
    };
  }

  return (
    <>
      <TouchableOpacity
        onPress={() => props.onPress(props.index)}
        activeOpacity={0.8}
        style={touchableStyle}
      >
        {!!props.button.icon && !props.defaultParams.isIconsFromRight && (
          <Image source={props.button.icon} style={iconStyle} />
        )}
        <Text
          numberOfLines={1}
          children={props.button.text}
          style={textStyle}
        />

        {!!props.button.icon && props.defaultParams.isIconsFromRight && (
          <Image source={props.button.icon} style={iconStyle} />
        )}
      </TouchableOpacity>
      {!props.isLast && <View style={separatorStyle} />}
    </>
  );
});
