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
  backgroundColor: 'red',
  itemFontSize: 10,
  cornerRadius: 20,
  itemPaddingHorizontal: 40,
});

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  return (
    <View style={styles.container}>
      <ScrollView style={{ flex: 1, backgroundColor: 'yellow' }}>
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
                itemPaddingHorizontal: 4,
                backgroundColor: 'white',
                gravity: 'top',
                itemFontSize: 17,
                theme: 'light',
                buttons: [
                  {
                    text: 'SHARE',
                    data: 'SHARE',
                    icon: require('./assets/icShare.png'),
                    showSeparator: true,
                    separatorHeight: 3,
                    separatorColor: 'yellow',
                    tint: 'red',
                  },
                  {
                    text: 'VIEW_PAGE_PREVIEW ',
                    data: 'VIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEW',
                    //icon: require('./assets/icViews.png'),
                    showSeparator: true,
                    separatorHeight: 10,
                    separatorColor: 'red',
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
                theme: 'light',
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
