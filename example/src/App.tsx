import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  StatusBar,
  Dimensions,
} from 'react-native';
import { configurePopup, showPopup } from 'react-native-popup-menu';
import { useRef } from 'react';

configurePopup({
  itemFontSize: 17,
  cornerRadius: 20,
  itemPaddingHorizontal: 16,
  backgroundColor: 'white',
  separatorColor: '#F4F4F4',
  separatorHeight: StyleSheet.hairlineWidth,
  shadow: {
    color: 'rgba(0, 0, 0, 0.16)',
    offset: { width: 0, height: 16 },
    opacity: 0.5,
    radius: 30,
  },
});

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  return (
    <View style={styles.container}>
      <ScrollView style={{ flex: 1, backgroundColor: 'white' }}>
        <TouchableOpacity
          ref={ref}
          style={{
            height: 56,
            width: 56,
            marginTop: 100,
            marginStart: Dimensions.get('window').width - 56,
            backgroundColor: 'red',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          onPress={() => {
            ref.current?.measureInWindow(async (x, y, width, height) => {
              const selected = await showPopup({
                nativeID: 'oneNative',
                frame: { x, y, width, height },
                buttons: [
                  {
                    text: 'SHARE',
                    data: 'SHARE',
                    icon: require('./assets/icShare.png'),
                  },
                  {
                    text: 'VIEW_PAGE_PREVIEW ',
                    data: 'VIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEW',
                    //icon: require('./assets/icViews.png'),
                  },
                  {
                    text: 'SETTINGS',
                    data: 'SETTINGS',
                    icon: require('./assets/icSettings.png'),
                  },
                ],
              });
              console.log(selected);
            });
          }}
        >
          <Text nativeID={'oneNative'}>One</Text>
        </TouchableOpacity>
        <View style={{ height: 350 }} />
        <TouchableOpacity
          ref={ref2}
          style={{
            height: 100,
            width: '100%',
            backgroundColor: 'green',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          onPress={async () => {
            ref2.current?.measureInWindow(async (x, y, width, height) => {
              console.log('-----', y, height);
              const selected = await showPopup({
                isIconsFromRight: true,
                cornerRadius: 10,
                frame: { x, y, width, height },
                // nativeID: 'twoNative',
                buttons: [
                  {
                    text: 'Firstsadkjk',
                    data: '1',
                    icon: require('./assets/icShare.png'),
                  },
                  {
                    text: 'Second',
                    data: '2',
                    icon: require('./assets/icUnsave.png'),
                  },
                ],
              });
              console.log(selected);
            });
          }}
        >
          <Text nativeID={'twoNative'}>two</Text>
        </TouchableOpacity>
      </ScrollView>
    </View>
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
