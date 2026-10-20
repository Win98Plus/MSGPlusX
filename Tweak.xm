#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Intents/Intents.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <substrate.h>
#import "MSGSettingsViewController.h"

static NSString *MSGPlusX_version = @"1.1";
UIViewController *customAlertVC12 = nil;
static UILabel *label = nil;
static BOOL isCheckingForUpdate = NO;
static BOOL updateAlertShown = NO;

@interface MSGThreadListViewController : UIViewController
- (void)checkForUpdate;
- (void)cancelButton;
- (void)update;
- (BOOL)version:(NSString *)v1 isLowerThan:(NSString *)v2;
@end

@interface MSGVoiceClipCreationViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (void)voiceClipCreationViewDidTapSend:(id)sender;
@end

@interface LSMediaVideoViewController : UIViewController
- (void)mediaVideoControlsViewDidTapPlay:(id)sender;
- (void)shareMedia;
- (void)longpre:(UILongPressGestureRecognizer *)sender;
@end

@interface LSMediaPickerViewController : UIViewController
- (void)_didTapHDToggle:(id)sender;
@end

@interface LSRTCCallButton : UIView
- (void)handleButtonTap;
@end

@interface MSGMessengerWordmarkView : UIView
- (void)msgWordmarkTapped;
@end

@interface MSGApplication : UIApplication
- (void)_handleScreenshot;
@end

@interface LSNetworkImageView : UIImageView
- (void)longpreSE:(UILongPressGestureRecognizer *)sender;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@interface LSMediaViewController : UIViewController
- (void)markViewOnceMessageAsOpened:(id)message;
@end

@interface MSGMessageListViewController : UIViewController
@end

@interface MSGStoryBucketsDataManager : NSObject
- (void)markStoriesAsSeen:(id)stories bucketID:(id)bucketID isStoryPeekView:(BOOL)isPeek completion:(id)completion;
- (void)markTabViewTimeAndClearBadgeCount;
@end

@interface LSStoryBucketViewControllerBase : UIViewController
- (void)startTimer;
@end

@interface LSStoryBucketViewController : LSStoryBucketViewControllerBase
- (void)startTimer;
- (void)_addReplyBarViewController;
@end

@interface MSGInboxTrayViewController : UIViewController
- (void)_setInboxTrayItems:(NSArray *)items;
- (void)_setInboxTrayItems:(NSArray *)items originalItemsForBottomSheet:(NSArray *)originalItems;
- (void)_didFetchInboxUnitItems:(id)items;
- (void)inboxTrayDataManagerDidReceiveUpdate:(id)update;
@end

static void alertm(NSString *message, NSString *title) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:ok];
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    [topVC presentViewController:alert animated:YES completion:nil];
}

static void handleMSGPlusTap(void) {
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    MSGSettingsViewController *settingsVC = [[MSGSettingsViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [topVC presentViewController:nav animated:YES completion:nil];
}

%hook MSGThreadListViewController

- (void)viewDidLoad {
    %orig;
    [self checkForUpdate];
}

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    [self checkForUpdate];
}

%new
- (void)checkForUpdate {
    if (isCheckingForUpdate || updateAlertShown) {
        return;
    }
    isCheckingForUpdate = YES;
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/6gr8/IGFormat/refs/heads/main/msg.json"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        isCheckingForUpdate = NO;
        if (!data || error) {
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSString *latestVersion = json[@"latest_version"];
        if (!latestVersion) {
            return;
        }
        if ([self version:MSGPlusX_version isLowerThan:latestVersion]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (updateAlertShown || customAlertVC12) {
                    return;
                }
                updateAlertShown = YES;
                UIWindow *keyWindow = nil;
                for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                        UIWindowScene *windowScene = (UIWindowScene *)scene;
                        for (UIWindow *win in windowScene.windows) {
                            if (win.isKeyWindow) {
                                keyWindow = win;
                                break;
                            }
                        }
                    }
                    if (keyWindow) {
                        break;
                    }
                }
                UIViewController *topVC = keyWindow.rootViewController;
                while (topVC.presentedViewController) {
                    topVC = topVC.presentedViewController;
                }
                if (!topVC) {
                    updateAlertShown = NO;
                    return;
                }
                customAlertVC12 = [[UIViewController alloc] init];
                customAlertVC12.modalPresentationStyle = UIModalPresentationOverFullScreen;
                customAlertVC12.view.backgroundColor = [UIColor clearColor];

                UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
                blurView.frame = customAlertVC12.view.bounds;
                blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [customAlertVC12.view addSubview:blurView];

                NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] init];
                NSString *titleString = [NSString stringWithFormat:@"New Version Available : %@\n\n", latestVersion];
                NSDictionary *titleAttrs = @{
                    NSForegroundColorAttributeName: [UIColor whiteColor],
                    NSFontAttributeName: [UIFont systemFontOfSize:20.0 weight:UIFontWeightSemibold]
                };
                [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:titleString attributes:titleAttrs]];

                NSString *bodyString = @"Please update MSGPlusX to enjoy the latest features and fixes. If you choose to cancel, please don't post on Reddit saying \n'DeNsor is not helping me'. 🙏";
                NSDictionary *bodyAttrs = @{
                    NSForegroundColorAttributeName: [UIColor lightGrayColor],
                    NSFontAttributeName: [UIFont systemFontOfSize:14.0 weight:UIFontWeightRegular]
                };
                [attrText appendAttributedString:[[NSAttributedString alloc] initWithString:bodyString attributes:bodyAttrs]];

                UILabel *msgLabel = [[UILabel alloc] init];
                msgLabel.attributedText = attrText;
                msgLabel.textAlignment = NSTextAlignmentCenter;
                msgLabel.numberOfLines = 0;
                msgLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [customAlertVC12.view addSubview:msgLabel];

                UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                [updateBtn setTitle:@"Update" forState:UIControlStateNormal];
                [updateBtn setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
                updateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
                updateBtn.translatesAutoresizingMaskIntoConstraints = NO;
                [updateBtn addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];

                UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
                [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
                [cancelBtn setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
                cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
                cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
                [cancelBtn addTarget:self action:@selector(cancelButton) forControlEvents:UIControlEventTouchUpInside];

                UIView *btnContainer = [[UIView alloc] init];
                btnContainer.translatesAutoresizingMaskIntoConstraints = NO;
                [btnContainer addSubview:updateBtn];
                [btnContainer addSubview:cancelBtn];
                [customAlertVC12.view addSubview:btnContainer];

                [NSLayoutConstraint activateConstraints:@[
                    [msgLabel.centerXAnchor constraintEqualToAnchor:customAlertVC12.view.centerXAnchor],
                    [msgLabel.centerYAnchor constraintEqualToAnchor:customAlertVC12.view.centerYAnchor constant:-40.0],
                    [msgLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:customAlertVC12.view.leadingAnchor constant:30.0],
                    [msgLabel.trailingAnchor constraintLessThanOrEqualToAnchor:customAlertVC12.view.trailingAnchor constant:-30.0],
                    [btnContainer.topAnchor constraintEqualToAnchor:msgLabel.bottomAnchor constant:30.0],
                    [btnContainer.centerXAnchor constraintEqualToAnchor:customAlertVC12.view.centerXAnchor],
                    [updateBtn.leadingAnchor constraintEqualToAnchor:btnContainer.leadingAnchor],
                    [updateBtn.topAnchor constraintEqualToAnchor:btnContainer.topAnchor],
                    [updateBtn.bottomAnchor constraintEqualToAnchor:btnContainer.bottomAnchor],
                    [updateBtn.widthAnchor constraintGreaterThanOrEqualToConstant:80.0],
                    [cancelBtn.leadingAnchor constraintEqualToAnchor:updateBtn.trailingAnchor constant:40.0],
                    [cancelBtn.trailingAnchor constraintEqualToAnchor:btnContainer.trailingAnchor],
                    [cancelBtn.topAnchor constraintEqualToAnchor:btnContainer.topAnchor],
                    [cancelBtn.bottomAnchor constraintEqualToAnchor:btnContainer.bottomAnchor],
                    [cancelBtn.widthAnchor constraintGreaterThanOrEqualToConstant:80.0],
                    [btnContainer.heightAnchor constraintEqualToConstant:36.0]
                ]];

                [topVC presentViewController:customAlertVC12 animated:YES completion:nil];
            });
        }
    }];
    [task resume];
}

%new
- (void)cancelButton {
    if (customAlertVC12) {
        [customAlertVC12 dismissViewControllerAnimated:YES completion:nil];
        customAlertVC12 = nil;
    }
}

%new
- (void)update {
    NSURL *url = [NSURL URLWithString:@"https://t.me/DENS0R"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

%new
- (BOOL)version:(NSString *)v1 isLowerThan:(NSString *)v2 {
    NSArray<NSString *> *c1 = [v1 componentsSeparatedByString:@"."];
    NSArray<NSString *> *c2 = [v2 componentsSeparatedByString:@"."];
    NSUInteger maxCount = MAX(c1.count, c2.count);
    for (NSUInteger i = 0; i < maxCount; i++) {
        NSInteger n1 = (i < c1.count) ? [c1[i] integerValue] : 0;
        NSInteger n2 = (i < c2.count) ? [c2[i] integerValue] : 0;
        if (n1 < n2) {
            return YES;
        }
        if (n1 > n2) {
            return NO;
        }
    }
    return NO;
}

%end

%hook MSGVoiceClipCreationViewController

- (void)viewDidAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"uploadvideos_voice"]) {
        %orig(animated);
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MSGPlusX" message:@"Upload video to voice message" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *recordAction = [UIAlertAction actionWithTitle:@"Record" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        %orig(animated);
    }];
    UIAlertAction *uploadAction = [UIAlertAction actionWithTitle:@"Upload Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = @[@"public.movie"];
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:recordAction];
    [alert addAction:uploadAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

%new
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *videoURL = info[UIImagePickerControllerMediaURL];
    if (!videoURL) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MSGPlusXVoice.ogg"];
        NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
        exportSession.outputURL = outputURL;
        exportSession.outputFileType = AVFileTypeAppleM4A;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if (exportSession.status == AVAssetExportSessionStatusCompleted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    id recorder = [self valueForKey:@"_recorderController"];
                    if (!recorder) {
                        alertm(@"Recorder not found", @"MSGPlusX");
                        return;
                    }
                    NSURL *assetUrl = [recorder valueForKey:@"assetUrl"];
                    [[NSFileManager defaultManager] removeItemAtURL:assetUrl error:nil];
                    [[NSFileManager defaultManager] copyItemAtURL:outputURL toURL:assetUrl error:nil];
                    [self voiceClipCreationViewDidTapSend:nil];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    alertm(@"Export failed", @"MSGPlusX");
                });
            }
        }];
    });
}

%new
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

%end

%hook LSMediaVideoViewController

- (void)playDidEnd {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loop_videos"]) {
        [self mediaVideoControlsViewDidTapPlay:nil];
    }
}

- (void)viewDidLoad {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"download_videos"]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpre:)];
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 0.5;
        [self.view addGestureRecognizer:longPress];
    }
}

%new
- (void)longpre:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self shareMedia];
    }
}

%end

%hook LSMediaPickerViewController

- (void)viewDidLoad {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"upload_hd_photos"]) {
        if ([self respondsToSelector:@selector(_didTapHDToggle:)]) {
            [self _didTapHDToggle:nil];
        }
    }
}

%end

%hook LSRTCCallButton

- (void)handleButtonTap {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"call_confirmation"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MSGPlusX" message:@"Do you want to call?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            %orig;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:yesAction];
        [alert addAction:cancelAction];
        UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }
        [topVC presentViewController:alert animated:YES completion:nil];
    } else {
        %orig;
    }
}

%end

%hook MSGMessengerWordmarkView

- (void)layoutSubviews {
    %orig;
    UIImageView *imgView = MSHookIvar<UIImageView *>(self, "_imageView");
    if (imgView) {
        imgView.hidden = YES;
        label = [self viewWithTag:9911];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:self.bounds];
            label.tag = 9911;
            label.text = @"MSGPLusX";
            label.font = [UIFont boldSystemFontOfSize:28.0];
            label.textColor = [UIColor labelColor];
            label.adjustsFontSizeToFitWidth = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.userInteractionEnabled = YES;
            [self addSubview:label];
        } else {
            label.frame = self.bounds;
        }
        self.userInteractionEnabled = YES;
        BOOL hasTap = NO;
        for (UIGestureRecognizer *gr in self.gestureRecognizers) {
            if ([gr isKindOfClass:[UITapGestureRecognizer class]] && [gr.name isEqualToString:@"msgWordmarkTap"]) {
                hasTap = YES;
                break;
            }
        }
        if (!hasTap) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(msgWordmarkTapped)];
            tap.name = @"msgWordmarkTap";
            tap.cancelsTouchesInView = NO;
            [self addGestureRecognizer:tap];
        }
    }
}

%new
- (void)msgWordmarkTapped {
    handleMSGPlusTap();
}

%end

%hook MSGApplication

- (void)_handleScreenshot {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"no_screenshot_detection"]) {
        return;
    }
    %orig;
}

%end

%hook UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle {
    if ([title containsString:@"icon"] || [message containsString:@"icon"]) {
        return nil;
    }
    return %orig(title, message, preferredStyle);
}

%end

%hook UIApplication

- (void)setAlternateIconName:(NSString *)alternateIconName completionHandler:(void (^)(NSError *error))completionHandler {
    NSString *selected = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSGSelectedAppIcon"];
    if (selected && ![selected isEqualToString:@"AppIcon60x60"]) {
        alternateIconName = selected;
    }
    NSString *lastApplied = [[NSUserDefaults standardUserDefaults] objectForKey:@"MSGLastAppliedIcon"];
    if ((lastApplied == nil && alternateIconName == nil) || [lastApplied isEqualToString:alternateIconName]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:alternateIconName forKey:@"MSGLastAppliedIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    %orig(alternateIconName, completionHandler);
}

%end

%hook UITabBar

- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
    BOOL hideChats = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_chats"];
    BOOL hideStories = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Stories"];
    BOOL hideMenu = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Menu"];
    BOOL hideNotifications = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Notifications"];

    NSMutableArray *filtered = [NSMutableArray array];
    for (id item in items) {
        BOOL shouldHide = NO;
        if ([item isKindOfClass:objc_getClass("MDSTabBarItem")]) {
            id props = [item valueForKey:@"_props"];
            NSString *accID = [props valueForKey:@"accessibilityIdentifierText"];
            if ((hideChats && [accID isEqualToString:@"tabbar-chats"]) ||
                (hideStories && [accID isEqualToString:@"tabbar-stories"]) ||
                (hideMenu && [accID isEqualToString:@"tabbar-more-menu"]) ||
                (hideNotifications && [accID isEqualToString:@"tabbar-jewel-notification-menu"])) {
                shouldHide = YES;
            }
        }
        if (!shouldHide && [item isKindOfClass:[UITabBarItem class]]) {
            NSString *title = [(UITabBarItem *)item title];
            if ((hideChats && [title isEqualToString:@"Chats"]) ||
                (hideStories && [title isEqualToString:@"Stories"]) ||
                (hideMenu && [title isEqualToString:@"Menu"]) ||
                (hideNotifications && [title isEqualToString:@"Notifications"])) {
                shouldHide = YES;
            }
        }
        if (!shouldHide) {
            [filtered addObject:item];
        }
    }

    UITabBarItem *msgPlusItem = [[UITabBarItem alloc] initWithTitle:@"MSG+" image:[UIImage systemImageNamed:@"staroflife.fill"] tag:99];
    [filtered addObject:msgPlusItem];
    %orig(filtered, animated);
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem {
    if ([selectedItem.title isEqualToString:@"MSG+"]) {
        handleMSGPlusTap();
    }
    %orig(selectedItem);
}

%end

%hook _TtC15MDSModernTabBar15MDSModernTabBar

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    BOOL hideChats = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_chats"];
    BOOL hideStories = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Stories"];
    BOOL hideMenu = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Menu"];
    BOOL hideNotifications = [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_Notifications"];

    NSMutableArray *filtered = [NSMutableArray array];
    for (id item in items) {
        BOOL shouldHide = NO;
        if ([item isKindOfClass:objc_getClass("MDSTabBarItem")]) {
            id props = [item valueForKey:@"_props"];
            NSString *accID = [props valueForKey:@"accessibilityIdentifierText"];
            if ((hideChats && [accID isEqualToString:@"tabbar-chats"]) ||
                (hideStories && [accID isEqualToString:@"tabbar-stories"]) ||
                (hideMenu && [accID isEqualToString:@"tabbar-more-menu"]) ||
                (hideNotifications && [accID isEqualToString:@"tabbar-jewel-notification-menu"])) {
                shouldHide = YES;
            }
        }
        if (!shouldHide && [item isKindOfClass:[UITabBarItem class]]) {
            NSString *title = [(UITabBarItem *)item title];
            if ((hideChats && [title isEqualToString:@"Chats"]) ||
                (hideStories && [title isEqualToString:@"Stories"]) ||
                (hideMenu && [title isEqualToString:@"Menu"]) ||
                (hideNotifications && [title isEqualToString:@"Notifications"])) {
                shouldHide = YES;
            }
        }
        if (!shouldHide) {
            [filtered addObject:item];
        }
    }
    %orig(filtered, animated);
}

%end

%hook LSNetworkImageView

- (void)layoutSubviews {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"download_photos"]) {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpreSE:)];
        longPress.numberOfTouchesRequired = 1;
        longPress.minimumPressDuration = 0.5;
        [self addGestureRecognizer:longPress];
    }
}

%new
- (void)longpreSE:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

%new
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        alertm(@"Failed to save photo", @"MSGPlusX");
    } else {
        alertm(@"Photo saved", @"MSGPlusX");
    }
}

%end

%hook LSMediaViewController

- (void)markViewOnceMessageAsOpened:(id)message {
    BOOL unlimitedVideos = [[NSUserDefaults standardUserDefaults] boolForKey:@"unlimited_videos"];
    BOOL unlimitedPhotos = [[NSUserDefaults standardUserDefaults] boolForKey:@"unlimited_photos"];
    int mediaType = [[self valueForKey:@"mediaType"] intValue];
    if (mediaType == 9) {
        if (unlimitedVideos) {
            return;
        }
    } else {
        if (unlimitedPhotos) {
            return;
        }
    }
    %orig(message);
}

%end

%hook MSGMessageListViewController

- (void)viewDidLoad {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"read_chats_anonymously"]) {
        MSHookIvar<BOOL>(self, "_disableReadReceipts") = YES;
    }
}

%end

%hook MSGStoryBucketsDataManager

- (void)markStoriesAsSeen:(id)stories bucketID:(id)bucketID isStoryPeekView:(BOOL)isPeek completion:(id)completion {
    %orig(stories, bucketID, isPeek, completion);
}

- (void)markTabViewTimeAndClearBadgeCount {
    %orig;
}

%end

%hook LSStoryBucketViewController

- (void)startTimer {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"watch_stories_anonymously"]) {
        struct objc_super superInfo = {
            .receiver = self,
            .super_class = objc_getClass("LSStoryBucketViewControllerBase")
        };
        ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&superInfo, @selector(startTimer));
    } else {
        %orig;
    }
}

- (void)_addReplyBarViewController {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hide_reply_bar"]) {
        return;
    }
    %orig;
}

%end

%hook MSGInboxTrayViewController

- (void)_setInboxTrayItems:(NSArray *)items {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remove_trays_stories"]) {
        %orig(@[]);
        return;
    }
    %orig(items);
}

- (void)_setInboxTrayItems:(NSArray *)items originalItemsForBottomSheet:(NSArray *)originalItems {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remove_trays_stories"]) {
        %orig(@[], @[]);
        return;
    }
    %orig(items, originalItems);
}

- (void)_didFetchInboxUnitItems:(id)items {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remove_trays_stories"]) {
        %orig(nil);
        return;
    }
    %orig(items);
}

- (void)inboxTrayDataManagerDidReceiveUpdate:(id)update {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remove_trays_stories"]) {
        return;
    }
    %orig(update);
}

%end

%hook INVocabulary

+ (id)sharedVocabulary {
    return nil;
}

%end

@implementation MSGIconPickerController {
    NSArray<NSString *> *_icons;
    NSString *_selectedIcon;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.145 green:0.153 blue:0.157 alpha:1.0];

    UIView *headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerView];

    UIView *grabber = [[UIView alloc] init];
    grabber.backgroundColor = [[UIColor labelColor] colorWithAlphaComponent:0.2];
    grabber.layer.cornerRadius = 2.5;
    grabber.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:grabber];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Select App Icon";
    titleLabel.font = [UIFont systemFontOfSize:19.0 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor labelColor];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *symConfig = [UIImageSymbolConfiguration configurationWithPointSize:14.0 weight:UIImageSymbolWeightBold];
    UIImage *closeImg = [UIImage systemImageNamed:@"xmark" withConfiguration:symConfig];
    [closeButton setImage:closeImg forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor secondaryLabelColor];
    closeButton.backgroundColor = [UIColor secondarySystemFillColor];
    closeButton.layer.cornerRadius = 15.0;
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [closeButton addTarget:self action:@selector(closeSheet) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:closeButton];

    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [headerView.heightAnchor constraintEqualToConstant:72.0],
        [grabber.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:8.0],
        [grabber.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [grabber.widthAnchor constraintEqualToConstant:36.0],
        [grabber.heightAnchor constraintEqualToConstant:5.0],
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:20.0],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-12.0],
        [closeButton.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-20.0],
        [closeButton.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
        [closeButton.widthAnchor constraintEqualToConstant:30.0],
        [closeButton.heightAnchor constraintEqualToConstant:30.0]
    ]];

    _icons = @[
        @"AppIcon60x60",
        @"AlternateAppIconChill",
        @"AlternateAppIconDreamy",
        @"AlternateAppIconFab",
        @"AlternateAppIconFierce",
        @"AlternateAppIconLovey",
        @"AlternateAppIconVaporwave"
    ];

    _selectedIcon = [[NSUserDefaults standardUserDefaults] stringForKey:@"MSGSelectedAppIcon"];
    if (!_selectedIcon) {
        _selectedIcon = @"AppIcon60x60";
    }

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = (self.view.bounds.size.width - 72.0) / 3.0;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth + 28.0);
    layout.minimumInteritemSpacing = 16.0;
    layout.minimumLineSpacing = 20.0;
    layout.sectionInset = UIEdgeInsetsMake(12.0, 20.0, 28.0, 20.0);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"IconCell"];
    [self.view addSubview:self.collectionView];

    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _icons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"IconCell" forIndexPath:indexPath];
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    NSString *iconName = _icons[indexPath.item];
    BOOL isSelected = [iconName isEqualToString:_selectedIcon];
    CGFloat width = cell.bounds.size.width;

    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, width)];
    cardView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    cardView.layer.cornerRadius = 20.0;
    cardView.layer.cornerCurve = kCACornerCurveContinuous;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOpacity = 0.12;
    cardView.layer.shadowOffset = CGSizeMake(0.0, 4.0);
    cardView.layer.shadowRadius = 8.0;
    [cell.contentView addSubview:cardView];

    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, width - 16.0, width - 16.0)];
    iconImageView.layer.cornerRadius = 15.0;
    iconImageView.layer.cornerCurve = kCACornerCurveContinuous;
    iconImageView.clipsToBounds = YES;
    iconImageView.contentMode = UIViewContentModeScaleAspectFill;

    UIImage *img = [UIImage imageNamed:iconName];
    if (!img) {
        NSString *resPath = [[NSBundle mainBundle] resourcePath];
        for (NSString *suffix in @[@"@3x.png", @"@2x.png", @"60x60@2x.png"]) {
            NSString *fullPath = [resPath stringByAppendingPathComponent:[iconName stringByAppendingString:suffix]];
            img = [UIImage imageWithContentsOfFile:fullPath];
            if (img) {
                break;
            }
        }
    }
    iconImageView.image = img;
    [cardView addSubview:iconImageView];

    if (isSelected) {
        cardView.layer.borderWidth = 2.5;
        cardView.layer.borderColor = [UIColor colorWithRed:0.47 green:0.65 blue:1.0 alpha:1.0].CGColor;

        UIImageView *checkBadge = [[UIImageView alloc] initWithFrame:CGRectMake(width - 24.0, width - 24.0, 20.0, 20.0)];
        checkBadge.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        checkBadge.tintColor = [UIColor colorWithRed:0.47 green:0.65 blue:1.0 alpha:1.0];
        checkBadge.backgroundColor = [UIColor systemBackgroundColor];
        checkBadge.layer.cornerRadius = 10.0;
        checkBadge.clipsToBounds = YES;
        [cardView addSubview:checkBadge];
    }

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, width + 6.0, width, 16.0)];
    NSString *displayTitle = [iconName isEqualToString:@"AppIcon60x60"] ? @"Default" : [iconName stringByReplacingOccurrencesOfString:@"AlternateAppIcon" withString:@""];
    nameLabel.text = displayTitle;
    nameLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium];
    nameLabel.textColor = isSelected ? [UIColor labelColor] : [UIColor secondaryLabelColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:nameLabel];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iconName = _icons[indexPath.item];
    _selectedIcon = iconName;
    [[NSUserDefaults standardUserDefaults] setObject:iconName forKey:@"MSGSelectedAppIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.12 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }];

    [collectionView reloadData];
    [self applyIcon:iconName];
}

- (void)applyIcon:(NSString *)iconName {
    UIApplication *app = [UIApplication sharedApplication];
    if (![app supportsAlternateIcons]) {
        return;
    }
    NSString *targetIcon = [iconName isEqualToString:@"AppIcon60x60"] ? nil : iconName;
    [app setAlternateIconName:targetIcon completionHandler:nil];
}

- (void)closeSheet {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
