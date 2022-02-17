import * as React from 'react';
import { useEffect, useRef } from 'react';

import {
  FlatList,
  Modal,
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

export const CustomV: React.FC<ViewProps> = (props) => {
  const sheetContext = useFittedSheetContext();

  const renderItem = (info: any) => (
    <Text
      key={info.item}
      style={{ height: 56, width: '100%', borderBottomWidth: 1 }}
    >
      {info.item}
    </Text>
  );

  return (
    <View
      {...props}
      accessibilityLabel={'sheetView'}
      onLayout={(e) => console.log('[App.]', e.nativeEvent.layout)}
    >
      <FlatList
        data={data}
        onLayout={(e) => console.log('[FlatList.]', e.nativeEvent.layout)}
        nestedScrollEnabled
        style={{ flex: 1 }}
        windowSize={2}
        keyExtractor={(item) => item.toString()}
        renderItem={(info) => (
          <Text style={{ height: 56, width: '100%', borderBottomWidth: 1 }}>
            {info.item}
          </Text>
        )}
      />
      {/*<ScrollView*/}
      {/*  nestedScrollEnabled*/}
      {/*  nativeID={FITTED_SHEET_SCROLL_VIEW}*/}
      {/*  style={{ flex: 1, backgroundColor: 'yellow' }}*/}
      {/*  contentContainerStyle={{ paddingBottom: 20 }}*/}
      {/*>*/}
      {/*  {data.map(renderItem)}*/}
      {/*</ScrollView>*/}
    </View>
  );
};

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  const sheetRef = useRef<FittedSheet>(null);

  useEffect(() => {
    setTimeout(() => {
      //sheetRef.current?.show();
    }, 2000);
  }, []);

  return (
    <>
      <View style={styles.container} accessibilityLabel={'container'}>
        <TouchableOpacity
          accessibilityLabel={'TouchableOpacity'}
          onPress={() => sheetRef.current?.show()}
          style={{ marginTop: 100 }}
        >
          <Text>Press</Text>
        </TouchableOpacity>

        <View accessibilityLabel={'flexOne'} style={{ flex: 1 }} />

        <Text style={{ marginBottom: 10 }} accessibilityLabel={'text'}>
          The constructor is init(controller:, sizes:, options:). Sizes is
          optional, but if specified, the first size in the array will determine
          the initial size of the sheet. Options is also optional, if not
          specified, the default options will be used.
        </Text>
        {/*<ScrollView style={{ flex: 1, backgroundColor: 'white' }}>*/}
        {/*  <TouchableOpacity*/}
        {/*    ref={ref}*/}
        {/*    accessibilityLabel={'Pressable'}*/}
        {/*    style={{*/}
        {/*      height: 56,*/}
        {/*      width: 56,*/}
        {/*      marginTop: 100,*/}
        {/*      marginStart: Dimensions.get('window').width - 156,*/}
        {/*      backgroundColor: 'red',*/}
        {/*      alignItems: 'center',*/}
        {/*      justifyContent: 'center',*/}
        {/*    }}*/}
        {/*    onPress={() => {*/}
        {/*      ref.current?.measureInWindow(async (x, y, width, height) => {*/}
        {/*        const selected = await showPopup({*/}
        {/*          frame: { x, y, width, height },*/}
        {/*          gravity: 'bottom',*/}
        {/*          buttons: [*/}
        {/*            {*/}
        {/*              text: 'SHARE',*/}
        {/*              data: 'SHARE',*/}
        {/*              // icon: require('./assets/icShare.png'),*/}
        {/*            },*/}
        {/*            {*/}
        {/*              text: 'М',*/}
        {/*              data: 'VIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEW',*/}
        {/*              separatorHeight: 19,*/}
        {/*              separatorColor: 'red',*/}
        {/*              // showSeparator: true,*/}
        {/*              // icon: require('./assets/icViews.png'),*/}
        {/*            },*/}
        {/*            {*/}
        {/*              text: 'SETTINGS',*/}
        {/*              data: 'SETTINGS',*/}
        {/*              // icon: require('./assets/icSettings.png'),*/}
        {/*            },*/}
        {/*          ],*/}
        {/*        });*/}
        {/*        console.log(selected);*/}
        {/*      });*/}
        {/*    }}*/}
        {/*  >*/}
        {/*    <Text nativeID={'oneNative'}>One</Text>*/}
        {/*  </TouchableOpacity>*/}
        {/*  <View style={{ height: 550 }} />*/}
        {/*  <TouchableOpacity*/}
        {/*    ref={ref2}*/}
        {/*    style={{*/}
        {/*      height: 100,*/}
        {/*      width: '100%',*/}
        {/*      backgroundColor: 'green',*/}
        {/*      alignItems: 'center',*/}
        {/*      justifyContent: 'center',*/}
        {/*    }}*/}
        {/*    onPress={async () => {*/}
        {/*      ref2.current?.measureInWindow(async (x, y, width, height) => {*/}
        {/*        console.log('-----', y, height);*/}
        {/*        const selected = await showPopup({*/}
        {/*          isIconsFromRight: true,*/}
        {/*          cornerRadius: 10,*/}
        {/*          gravity: 'top',*/}
        {/*          frame: { x, y, width, height },*/}
        {/*          buttons: [*/}
        {/*            {*/}
        {/*              text: 'Firstsadkjk',*/}
        {/*              data: '1',*/}
        {/*              icon: require('./assets/icShare.png'),*/}
        {/*            },*/}
        {/*            {*/}
        {/*              text: 'SecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecond',*/}
        {/*              data: '2',*/}
        {/*              icon: require('./assets/icUnsave.png'),*/}
        {/*            },*/}
        {/*          ],*/}
        {/*        });*/}
        {/*        console.log('[App.selected]', selected);*/}
        {/*      });*/}
        {/*    }}*/}
        {/*  >*/}
        {/*    <Text nativeID={'twoNative'}>two</Text>*/}
        {/*  </TouchableOpacity>*/}
        {/*</ScrollView>*/}
      </View>

      <FittedSheet sheetSize={400} ref={sheetRef}>
        <CustomV style={{ flex: 1, backgroundColor: 'white' }} />
      </FittedSheet>

      {/*<Modal animationType={'none'} transparent>*/}
      {/*  <FittedSheet sheetSize={200} ref={sheetRef}>*/}
      {/*    <CustomV*/}
      {/*      style={{ height: 500, width: '100%', backgroundColor: 'red' }}*/}
      {/*    />*/}
      {/*  </FittedSheet>*/}
      {/*</Modal>*/}
    </>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
