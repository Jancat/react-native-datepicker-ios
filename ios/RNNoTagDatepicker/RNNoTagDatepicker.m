#import "RNNoTagDatepicker.h"
#import <React/RCTBridge.h>

#define DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define ANIMATION_DURATION 0.3

@interface RNNoTagDatepicker ()

@property (nonatomic) IBOutlet UIView* datePickerContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerComponentsContainerVSpace;
@property (nonatomic) IBOutlet UIView* datePickerComponentsContainer;
@property (nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation RNNoTagDatepicker

@synthesize bridge = _bridge;

- (NSArray<NSString *> *) supportedEvents
{
    return @[@"DATEPICKER_NATIVE_INVOKE"];
}

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [UIDatePicker new];
}


- (void)hide {
    CGRect frame = CGRectOffset(self.datePickerComponentsContainer.frame,
                                0,
                                self.datePickerComponentsContainer.frame.size.height);
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.datePickerComponentsContainer.frame = frame;
                         self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
                         
                     } completion:^(BOOL finished) {
                         [self.datePickerContainer removeFromSuperview];
                     }];
  
}

#pragma mark - Actions
- (IBAction)doneAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval seconds = [self.datePicker.date timeIntervalSince1970];
        [self sendEventWithName:@"DATEPICKER_NATIVE_INVOKE" body: @{@"status": @"success", @"value": [NSString stringWithFormat:@"%f", seconds]}];
        [self hide];
    });
}

- (IBAction)cancelAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"DATEPICKER_NATIVE_INVOKE" body: @{@"status": @"cancel"}];
        [self hide];
    });
}


- (void)dateChangedAction:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval seconds = [self.datePicker.date timeIntervalSince1970];
        [self sendEventWithName:@"DATEPICKER_NATIVE_INVOKE" body: @{@"status": @"change", @"value": [NSString stringWithFormat:@"%f", seconds]}];
    });
}

- (NSDateFormatter *)createISODateFormatter:(NSString *)format timezone:(NSTimeZone *)timezone {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Locale needed to avoid formatter bug on phones set to 12-hour
    // time to avoid it adding AM/PM to the string we supply
    // See: http://stackoverflow.com/questions/6613110/what-is-the-best-way-to-deal-with-the-nsdateformatter-locale-feature
    NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale: loc];
    [dateFormatter setTimeZone:timezone];
    [dateFormatter setDateFormat:format];
    
    return dateFormatter;
}

RCT_EXPORT_METHOD(show:(NSDictionary *) options) {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *window = RCTKeyWindow();
        //    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        
        if(!self.datePickerContainer){
            [[NSBundle mainBundle] loadNibNamed:@"DatePicker" owner:self options:nil];
        } else {
            self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        }
        
        NSDateFormatter *formatter = [self createISODateFormatter: DATETIME_FORMAT timezone:[NSTimeZone defaultTimeZone]];
        
        NSString *dateString = [options objectForKey:@"date"];
        NSString *maxDateString = [options objectForKey:@"maxDate"];
        
        self.datePicker.date = [formatter dateFromString:dateString];
        
        if(maxDateString && maxDateString.length > 0){
            self.datePicker.maximumDate = [formatter dateFromString:maxDateString];
        }
        
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.doneButton setTitle:@"确认" forState:UIControlStateNormal];
        
        UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        CGFloat width;
        CGFloat height;
        
        [window addSubview: self.datePickerContainer];
        
        if(UIInterfaceOrientationIsLandscape(deviceOrientation)){
            width = window.frame.size.width;
            height= window.frame.size.height;
        } else {
            width = window.frame.size.width;
            height= window.frame.size.height;
        }
        
        NSLog(@"%.2f", width);
        NSLog(@"%.2f", height);
        
        self.datePickerContainer.frame = CGRectMake(0, 0, width, height);
        
        [self.datePickerContainer layoutIfNeeded];
        
        CGRect frame = self.datePickerComponentsContainer.frame;
        self.datePickerComponentsContainer.frame = CGRectOffset(frame,
                                                                0,
                                                                frame.size.height );
        
        self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];

        [UIView animateWithDuration:ANIMATION_DURATION
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.datePickerComponentsContainer.frame = frame;
                             self.datePickerContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                             
                         } completion:^(BOOL finished) {
                            
                         }];
        
        [window makeKeyAndVisible];
    });
//    return callback(@[[formatter stringFromDate:self.datePicker.date]]);
}

- (UIDatePicker *)createDatePicker:(NSMutableDictionary *)options frame:(CGRect)frame {
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:frame];
    return datePicker;
}

#pragma mark - Utilities

/*! Converts a hex string into UIColor
 It based on http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
 
 @param hexString The hex string which has to be converted
 */
- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
