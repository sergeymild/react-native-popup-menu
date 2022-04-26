import * as React from 'react';
import { useEffect, useRef } from 'react';

import {
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ViewProps,
} from 'react-native';
import {
  configurePopup,
  FITTED_SHEET_SCROLL_VIEW,
  FittedSheet,
  useFittedSheetContext,
} from 'react-native-popup-menu';

configurePopup({
  cornerRadius: 20,
  backgroundColor: 'white',
  isIconsFromRight: false,
  minWidth: 250,
  item: {
    fontSize: 17,
    paddingHorizontal: 16,
    // separatorColor: '#F4F4F4',
    //separatorHeight: StyleSheet.hairlineWidth,
    tint: 'rgba(18, 18, 18, 1)',
  },
  shadow: {
    color: 'rgba(0, 0, 0, 0.16)',
    offset: { width: 0, height: 16 },
    opacity: 0.5,
    radius: 30,
  },
});

const data = [...Array(200)].map((_, index) => index);

const renderItem = (info: any) => (
  <Text
    key={info}
    style={{ height: 56, width: '100%', borderBottomWidth: 1 }}
    children={info}
  />
);

export const CustomV: React.FC<ViewProps> = (props) => {
  const sheetContext = useFittedSheetContext();

  return (
    <View
      {...props}
      accessibilityLabel={'sheetView'}
      onLayout={(e) => console.log('[App.root]', e.nativeEvent.layout)}
    >
      {/*<TouchableOpacity*/}
      {/*  style={{ width: '100%', height: 100 }}*/}
      {/*  onPress={() => {*/}
      {/*    sheetContext?.setSize(500);*/}
      {/*  }}*/}
      {/*>*/}
      {/*  <Text style={{ color: 'black', height: 50, backgroundColor: 'red' }}>*/}
      {/*    SetSize*/}
      {/*  </Text>*/}
      {/*</TouchableOpacity>*/}
      {/*<View style={{ height: 100, width: '100%', backgroundColor: 'yellow' }} />*/}
      {/*<FlatList*/}
      {/*  data={data}*/}
      {/*  onLayout={(e) => console.log('[FlatList.]', e.nativeEvent.layout)}*/}
      {/*  nestedScrollEnabled*/}
      {/*  style={{ flex: 1 }}*/}
      {/*  windowSize={2}*/}
      {/*  keyExtractor={(item) => item.toString()}*/}
      {/*  renderItem={(info) => (*/}
      {/*    <Text style={{ height: 56, width: '100%', borderBottomWidth: 1 }}>*/}
      {/*      {info.item}*/}
      {/*    </Text>*/}
      {/*  )}*/}
      {/*/>*/}
      <ScrollView
        nestedScrollEnabled
        nativeID={FITTED_SHEET_SCROLL_VIEW}
        style={{ flex: 1, backgroundColor: 'yellow' }}
      >
        {data.map((item) => (
          <React.Fragment key={item}>{renderItem(item)}</React.Fragment>
        ))}
      </ScrollView>
    </View>
  );
};

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  const sheetRef = useRef<FittedSheet>(null);

  useEffect(() => {
    setTimeout(() => {
      sheetRef.current?.show();
    }, 2000);
  }, []);

  return (
    <>
      <View style={styles.container} accessibilityLabel={'container'}>
        <Text style={{ marginBottom: 10 }} accessibilityLabel={'text'}>
          The constructor is init(controller:, sizes:, options:). Sizes is
          optional, but if specified, the first size in the array will determine
          the initial size of the sheet. Options is also optional, if not
          specified, the default options will be used.
        </Text>
      </View>

      <FittedSheet sheetSize={-1} ref={sheetRef} topLeftRightCornerRadius={30}>
        {() => {
          return (
            <CustomV
              style={{
                width: '100%',
                height: 400,
                backgroundColor: 'red',
              }}
            />
          );
        }}
      </FittedSheet>
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 100,
    flex: 1,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
