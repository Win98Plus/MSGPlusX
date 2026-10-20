#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSwitchTableCell.h>

@interface MSGIconPickerController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)applyIcon:(NSString *)iconName;
- (void)closeSheet;
@end

@interface MSGSettingsViewController : PSListController
- (void)dissmissSettingsController;
- (void)showIconPicker;
- (void)info;
- (PSSpecifier *)labelTitle:(NSString *)title detailTitle:(NSString *)detailTitle key:(NSString *)key;
- (PSSpecifier *)Section:(NSString *)title;
- (PSSpecifier *)switchTitle:(NSString *)title detailTitle:(NSString *)detailTitle key:(NSString *)key defaultValue:(BOOL)defaultValue Action:(SEL)action;
- (PSSpecifier *)newbutton:(NSString *)title detailTitle:(NSString *)detailTitle action:(SEL)action color:(UIColor *)color;
- (PSSpecifier *)button:(NSString *)title detailTitle:(NSString *)detailTitle action:(SEL)action color:(UIColor *)color image:(UIImage *)image;
- (UIImage *)getWhiteIconWithName:(NSString *)name;
- (void)value:(id)value specifier:(PSSpecifier *)specifier;
- (id)readValue:(PSSpecifier *)specifier;
- (void)twitter;
- (void)paypal;
- (void)telegram;
- (void)noScreenshotDetection:(UISwitch *)sender;
- (void)videoAsVoiceMessage:(UISwitch *)sender;
@end

@interface MSGButtonTableViewCell : PSTableCell {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIStackView *_textStack;
}
@end

@interface MSGSwitchTableCell : PSSwitchTableCell {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIStackView *_textStack;
}
@end
