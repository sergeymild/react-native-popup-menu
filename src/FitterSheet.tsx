import React from 'react';
import { requireNativeComponent } from 'react-native';

export const _FitterSheet = requireNativeComponent<any>('AppFitterSheet');

export interface FitterSheetRef {
  readonly show: () => void;
  readonly toggle: () => void;
}

interface Props {
  readonly sheetSize?: number;
  readonly maxWidth?: number;
}

interface State {
  show: boolean;
  sheetSize?: number;
}

export class FitterSheet extends React.PureComponent<Props, State> {
  private sheetRef = React.createRef<any>();
  constructor(props: Props) {
    super(props);
    this.state = {
      show: false,
      sheetSize: this.props.sheetSize,
    };
  }

  show = () => {
    this.setState({ show: true });
  };

  hide = () => {
    this.setState({ show: false });
  };

  toggle = () => {
    this.setState({ show: !this.state.show });
  };

  setSize = (size: number) => {
    this.setState({ sheetSize: size });
  };

  private onDismiss = () => {
    console.log('[FitterSheet.onDismiss]');
    this.hide();
  };

  render() {
    if (!this.state.show) {
      console.log('[FitterSheet.render.remove]');
      return null;
    }
    console.log('[FitterSheet.render.add]');
    return (
      <_FitterSheet
        onDismiss={this.onDismiss}
        ref={this.sheetRef}
        sheetMaxWidthSize={this.props.maxWidth}
        sheetSize={this.state.sheetSize}
        children={this.props.children}
      />
    );
  }
}
