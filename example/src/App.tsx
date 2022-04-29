import * as React from 'react';
import { useRef } from 'react';

import {
  Dimensions,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { configurePopup, showPopup } from 'react-native-popup-menu';

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

export default function App() {
  const ref = useRef<TouchableOpacity>(null);
  const ref2 = useRef<TouchableOpacity>(null);

  return (
    <View style={styles.container}>
      <ScrollView style={{ flex: 1, backgroundColor: 'white' }}>
        <TouchableOpacity
          ref={ref}
          accessibilityLabel={'Pressable'}
          style={{
            height: 56,
            width: 56,
            marginTop: 100,
            marginStart: Dimensions.get('window').width - 156,
            backgroundColor: 'red',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          onPress={() => {
            ref.current?.measureInWindow(async (x, y, width, height) => {
              const selected = await showPopup({
                frame: { x, y, width, height },
                gravity: 'bottom',
                buttons: [
                  {
                    text: 'SHARE',
                    data: 'SHARE',
                    // icon: require('./assets/icShare.png'),
                  },
                  {
                    text: 'М',
                    data: 'VIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEWVIEW_PAGE_PREVIEW',
                    separatorHeight: 19,
                    separatorColor: 'red',
                    // showSeparator: true,
                    // icon: require('./assets/icViews.png'),
                  },
                  {
                    text: 'SETTINGS',
                    data: 'SETTINGS',
                    // icon: require('./assets/icSettings.png'),
                  },
                ],
              });
              console.log(selected);
            });
          }}
        >
          <Text nativeID={'oneNative'}>One</Text>
        </TouchableOpacity>
        <View style={{ height: 550 }} />
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
                gravity: 'top',
                frame: { x, y, width, height },
                buttons: [
                  {
                    text: 'Firstsadkjk',
                    data: '1',
                    icon: require('./assets/icShare.png'),
                  },
                  {
                    text: 'SecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecondSecond',
                    data: '2',
                    icon: require('./assets/icUnsave.png'),
                  },
                ],
              });
              console.log('[App.selected]', selected);
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
