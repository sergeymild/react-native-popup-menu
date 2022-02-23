import React from 'react';
import { requireNativeComponent } from 'react-native';

const DynamicViewManager = requireNativeComponent<any>('DynamicView');

export const DynamicView: React.FC = (props) => {
  return <DynamicViewManager>{props.children}</DynamicViewManager>;
};
