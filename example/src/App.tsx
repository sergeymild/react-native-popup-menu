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
  minWidth: 140,
  maxWidth: 240,
  item: {
    textColor: 'red',
    fontSize: 17,
    paddingHorizontal: 16,
    // separatorColor: '#F4F4F4',
    //separatorHeight: StyleSheet.hairlineWidth,
    iconTint: 'rgba(18, 18, 18, 1)',
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
              console.log('[App.]', x, y, width, height)
              const selected = await showPopup({
                frame: { x, y, width, height },
                textAlign: 'center',
                gravity: 'bottom',
                buttons: [
                  {
                    text: '1',
                    data: 'SHARE',
                    fontSize: 16,
                    // icon: require('./assets/icShare.png'),
                  },
                  {
                    text: '1',
                    data: '1',
                    fontSize: 16,
                  },
                  // {
                  //   text: '1',
                  //   data: 'SETTINGS',
                  //   // icon: require('./assets/icSettings.png'),
                  // },
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
                //minWidth: 250,
                gravity: 'top',
                frame: { x, y, width, height },
                textAlign: 'center',
                buttons: [
                  {
                    text: 'FirstFirstFirstFirstFirstFirstFirst',
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
