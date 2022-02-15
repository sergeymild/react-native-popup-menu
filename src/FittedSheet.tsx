import React, { createContext, useContext } from 'react';
import { requireNativeComponent } from 'react-native';

export const _FitterSheet = requireNativeComponent<any>('AppFitterSheet');

interface Props {
  readonly sheetSize?: number;
  readonly maxWidth?: number;
}

interface State {
  show: boolean;
  sheetSize?: number;
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
    };
  }

  show = () => {
    this.setState({ show: true });
  };

  hide = () => {
    this.setState({ show: false, sheetSize: undefined });
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
        sheetSize={this.state.sheetSize ?? this.props.sheetSize}
      >
        <FittedSheetContext.Provider value={this}>
          {this.props.children}
        </FittedSheetContext.Provider>
      </_FitterSheet>
    );
  }
}
