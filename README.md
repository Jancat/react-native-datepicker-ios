React Native DatePicker
---

> A React Native DatePicker without Tag

based on: [Cordova DatePicker Plugin](https://github.com/VitaliiBlagodir/cordova-plugin-datepicker)

origin ios [https://github.com/sectore/phonegap3-ios-datepicker-plugin](https://github.com/sectore/phonegap3-ios-datepicker-plugin)

example code

```
import {
  NativeEventEmitter,
  NativeModules
} from 'react-native';

const DatePickerHandler = {};
const RNNoTagDatepicker = NativeModules.RNNoTagDatepicker;

const DatePickerEvent = new NativeEventEmitter(NativeModules.RNNoTagDatepicker);

DatePickerEvent.addListener('DATEPICKER_NATIVE_INVOKE', (evt: Event) => {
if(evt.status === 'success') {
  const toMSUnit = parseFloat(evt.value) * 1000;
  const date =  new Date(toMSUnit);
  webView.postMessage(JSON.stringify({
    type: 'DATE_PICKER',
    success: true,
    date
  }));
}
});

const showPicker = async (options) => {
  RNNoTagDatepicker.show(options);
};

showPicker({
  date: payload.date,
  maxDate: payload.maxDate,
});
```

LICENSE
---

MIT
