React Native DatePicker For iOS
---
> An API way to provide datepicker for ios

based on: [Cordova DatePicker Plugin](https://github.com/VitaliiBlagodir/cordova-plugin-datepicker)

origin ios [https://github.com/sectore/phonegap3-ios-datepicker-plugin](https://github.com/sectore/phonegap3-ios-datepicker-plugin)


## Installation
```shell
react-native link react-native-datepicker-ios
```

### Copy DatePicker.xib to Bundle Resources
```
Target > Build Phases > Copy Bundle Resources > Add > select DatePicker.xib in node_modules react-native-datepicker-ios directory
```

## Usage

**pickDate.js**
```js
import { NativeEventEmitter, NativeModules } from 'react-native'
import moment from 'moment'

const { RNDatepickerIOS } = NativeModules
const DatePickerEvent = new NativeEventEmitter(RNDatepickerIOS)

export default ({ date = moment().format('YYYY-MM-DD'), minDate, maxDate }) =>
  new Promise((resolve, reject) => {
    try {
      RNCMBDatepicker.show({
        date, minDate, maxDate
      })
    } catch (error) {
      reject(error)
    }
    const datePickerListener = DatePickerEvent.addListener('DATEPICKER_NATIVE_INVOKE', evt => {
      if (evt.status === 'success') {
        const toMSUnit = parseFloat(evt.value) * 1000
        const dateFormatted = moment(toMSUnit).format('YYYY-MM-DD')
        resolve(dateFormatted)
      }
      reject(new Error('User cancel'))
      datePickerListener && datePickerListener.remove()
    })
  })
```

**Demo.js**
```js
import React from 'react'
import pickDate from 'xxx/pickDate'

class Demo extends React.Component {
  ...

  onPressHandler = async () => {
    try {
      const date = await pickDate()
    } catch (error) {
    }
  }
}
```

LICENSE
---

MIT
