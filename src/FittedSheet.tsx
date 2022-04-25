import React, { createContext, useContext } from 'react';
import { Platform, requireNativeComponent } from 'react-native';

export const _FitterSheet = requireNativeComponent<any>('AppFitterSheet');

interface Props {
  readonly sheetSize?: number;
  readonly maxWidth?: number;
  readonly maxHeight?: number;
  readonly topLeftRightCornerRadius?: number;
  readonly onSheetDismiss?: () => void;
  readonly children: (data: any) => React.ReactElement;
}

interface State {
  show: boolean;
  sheetSize?: number;
  data: any | null;
}

export const FITTED_SHEET_SCROLL_VIEW = 'fittedSheetScrollView';

interface Context {
  hide: () => void;
  setSize: (size: number) => void;
}

const FittedSheetContext = createContext<Context | null>(null);

export const useFittedSheetContext = () => {
  return useContext(FittedSheetContext);
};

export class FittedSheet extends React.PureComponent<Props, State> {
  private sheetRef = React.createRef<any>();
  constructor(props: Props) {
    super(props);
    this.state = {
      show: false,
      data: null,
    };
  }

  show = (data: any) => {
    console.log('[FittedSheet.show]');
    this.setState({ show: true, data });
  };

  hide = () => {
    console.log('[FittedSheet.hide]');
    this.setState({ show: false, sheetSize: undefined });
  };

  data = () => this.state.data;

  toggle = () => {
    console.log('[FittedSheet.toggle]');
    this.setState({ show: !this.state.show });
  };

  setSize = (size: number) => {
    console.log('[FittedSheet.setSize]', size);
    //this.setState({ sheetSize: size });
    this.sheetRef.current?.setNativeProps({ sheetSize: size });
  };

  increaseHeight = (by: number) => {
    console.log('[FittedSheet.increaseHeight]', by);
    this.sheetRef.current?.setNativeProps({ increaseHeight: by });
  };

  decreaseHeight = (by: number) => {
    console.log('[FittedSheet.decreaseHeight]', by);
    this.sheetRef.current?.setNativeProps({ decreaseHeight: by });
  };

  private onDismiss = () => {
    console.log('[FitterSheet.onDismiss]');
    this.hide();
    this.props.onSheetDismiss?.();
  };

  render() {
    if (!this.state.show) {
      console.log('[FitterSheet.render.remove]');
      return null;
    }
    let height = this.state.sheetSize ?? this.props.sheetSize;
    if (height === undefined && Platform.OS === 'android') height = -1;
    return (
      <_FitterSheet
        onSheetDismiss={this.onDismiss}
        ref={this.sheetRef}
        sheetMaxWidthSize={this.props.maxWidth}
        sheetMaxHeightSize={this.props.maxHeight}
        sheetSize={height}
      >
        <FittedSheetContext.Provider value={this}>
          {this.props.children(this.state.data)}
        </FittedSheetContext.Provider>
      </_FitterSheet>
    );
  }
}
