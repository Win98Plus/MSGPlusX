#import "MSGSettingsViewController.h"

NSString *MSGPlusX_version = @"1.1";
BOOL isofficialIG = NO;

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

@implementation MSGSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"info.circle"] style:UIBarButtonItemStylePlain target:self action:@selector(info)];
    UIBarButtonItem *iconButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"paintbrush"] style:UIBarButtonItemStylePlain target:self action:@selector(showIconPicker)];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"xmark"] style:UIBarButtonItemStylePlain target:self action:@selector(dissmissSettingsController)];
    self.navigationItem.rightBarButtonItems = @[closeButton, iconButton];
    self.navigationItem.leftBarButtonItems = @[infoButton];
}

- (void)dissmissSettingsController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showIconPicker {
    MSGIconPickerController *vc = [[MSGIconPickerController alloc] init];
    if (@available(iOS 15.0, *)) {
        UISheetPresentationController *sheet = vc.sheetPresentationController;
        if (sheet) {
            sheet.detents = @[[UISheetPresentationControllerDetent mediumDetent]];
            sheet.prefersGrabberVisible = NO;
            sheet.preferredCornerRadius = 20.0;
        }
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)info {
    UIDevice *device = [UIDevice currentDevice];
    NSString *systemVersion = device.systemVersion;
    NSString *model = device.model;
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = infoDict[@"CFBundleShortVersionString"];
    NSString *bundleID = infoDict[@"CFBundleIdentifier"];
    if ([bundleID isEqualToString:@"com.facebook.Messenger"]) {
        isofficialIG = YES;
    } else {
        isofficialIG = NO;
    }
    NSString *status = isofficialIG ? @"OriginalBundle" : @"ModifiedBundle";
    NSString *msg = [NSString stringWithFormat:@"iOS Version : %@\nDevice : %@\nMessenger Version : %@\nMSGPlusX Version : %@\nBundle : %@\nStatus : %@", systemVersion, model, appVersion, MSGPlusX_version, bundleID, status];
    alertm(msg, @"MSGPlusX");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"MSGPlusX";
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIColor *darkColor = [UIColor colorWithRed:0.145 green:0.153 blue:0.157 alpha:1.0];
    UIColor *lightColor = [UIColor whiteColor];
    UIColor *dynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return darkColor;
        }
        return lightColor;
    }];
    UITableView *tableView = nil;
    if ([self respondsToSelector:@selector(table)]) {
        tableView = [self table];
    } else if ([self.view isKindOfClass:[UITableView class]]) {
        tableView = (UITableView *)self.view;
    }
    (void)dynamicColor;
    (void)tableView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *darkColor = [UIColor colorWithRed:0.145 green:0.153 blue:0.157 alpha:1.0];
    UIColor *lightColor = [UIColor whiteColor];
    UIColor *dynamicColor = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return darkColor;
        }
        return lightColor;
    }];
    cell.backgroundColor = dynamicColor;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}

- (PSSpecifier *)labelTitle:(NSString *)title detailTitle:(NSString *)detailTitle key:(NSString *)key {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title target:self set:nil get:nil detail:nil cell:PSStaticTextCell edit:nil];
    if (detailTitle) {
        [specifier setProperty:detailTitle forKey:@"subtitle"];
    }
    if (key) {
        [specifier setProperty:key forKey:@"key"];
    }
    return specifier;
}

- (PSSpecifier *)Section:(NSString *)title {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    return specifier;
}

- (PSSpecifier *)switchTitle:(NSString *)title detailTitle:(NSString *)detailTitle key:(NSString *)key defaultValue:(BOOL)defaultValue Action:(SEL)action {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title target:self set:@selector(value:specifier:) get:@selector(readValue:) detail:nil cell:PSSwitchCell edit:nil];
    [specifier setProperty:key forKey:@"key"];
    [specifier setProperty:key forKey:@"id"];
    [specifier setProperty:@YES forKey:@"big"];
    [specifier setProperty:[MSGSwitchTableCell class] forKey:@"cellClass"];
    [specifier setProperty:[[NSBundle mainBundle] bundleIdentifier] forKey:@"defaults"];
    [specifier setProperty:@(defaultValue) forKey:@"default"];
    if (action) {
        [specifier setProperty:NSStringFromSelector(action) forKey:@"switchAction"];
    }
    if (detailTitle) {
        [specifier setProperty:detailTitle forKey:@"subtitle"];
    }
    return specifier;
}

- (PSSpecifier *)newbutton:(NSString *)title detailTitle:(NSString *)detailTitle action:(SEL)action color:(UIColor *)color {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title target:self set:@selector(value:specifier:) get:@selector(readValue:) detail:nil cell:PSButtonCell edit:nil];
    [specifier setButtonAction:action];
    [specifier setProperty:@YES forKey:@"big"];
    [specifier setProperty:[MSGButtonTableViewCell class] forKey:@"cellClass"];
    if (detailTitle) {
        [specifier setProperty:detailTitle forKey:@"subtitle"];
    }
    if (color) {
        [specifier setProperty:color forKey:@"titleColor"];
    }
    return specifier;
}

- (PSSpecifier *)button:(NSString *)title detailTitle:(NSString *)detailTitle action:(SEL)action color:(UIColor *)color image:(UIImage *)image {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:title target:self set:@selector(value:specifier:) get:@selector(readValue:) detail:nil cell:PSButtonCell edit:nil];
    [specifier setButtonAction:action];
    [specifier setProperty:@YES forKey:@"big"];
    [specifier setProperty:[MSGButtonTableViewCell class] forKey:@"cellClass"];
    if (detailTitle) {
        [specifier setProperty:detailTitle forKey:@"subtitle"];
    }
    if (color) {
        [specifier setProperty:color forKey:@"titleColor"];
    }
    if (image) {
        [specifier setProperty:nil forKey:@"iconImage"];
    }
    return specifier;
}

- (UIImage *)getWhiteIconWithName:(NSString *)name {
    NSString *pluginPath = [[NSBundle mainBundle] pathForResource:@"InstagramWidgetExtensionLockScreenCameraControl" ofType:@"appex" inDirectory:@"PlugIns"];
    NSBundle *pluginBundle = [NSBundle bundleWithPath:pluginPath];
    if (![pluginBundle isLoaded]) {
        [pluginBundle load];
    }
    UIImage *image = [UIImage imageNamed:name inBundle:pluginBundle compatibleWithTraitCollection:nil];
    if (image) {
        CGSize canvasSize = CGSizeMake(29.0, 29.0);
        CGFloat iconSize = 24.0;
        CGRect iconRect = CGRectMake((canvasSize.width - iconSize) / 2.0, (canvasSize.height - iconSize) / 2.0, iconSize, iconSize);
        UIGraphicsBeginImageContextWithOptions(canvasSize, NO, 0.0);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, 0.0, canvasSize.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        [[UIColor labelColor] setFill];
        CGContextClipToMask(ctx, iconRect, image.CGImage);
        CGContextFillRect(ctx, iconRect);
        UIImage *tinted = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        image = [tinted imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return image;
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        PSSpecifier *chatSection = [self Section:@"Chat"];
        PSSpecifier *storiesSection = [self Section:@"Stories"];
        PSSpecifier *supportSection = [self Section:@"Support densor"];
        PSSpecifier *tabsSection = [self Section:@"TABS"];
        PSSpecifier *confirmationSection = [self Section:@"Confirmation"];

        PSSpecifier *unlimitedPhotos = [self switchTitle:@"View Photos Unlimited" detailTitle:@"View 'view once' photos more than once" key:@"unlimited_photos" defaultValue:YES Action:nil];
        PSSpecifier *unlimitedVideos = [self switchTitle:@"View Videos Unlimited" detailTitle:@"View 'view once' videos more than once" key:@"unlimited_videos" defaultValue:YES Action:nil];
        PSSpecifier *readChatsAnonymously = [self switchTitle:@"Read Chats Anonymously" detailTitle:@"Read chats without marking them as read" key:@"read_chats_anonymously" defaultValue:YES Action:nil];
        PSSpecifier *downloadPhotos = [self switchTitle:@"Download photos [HD]" detailTitle:@"Long-press to save 'view once' photos" key:@"download_photos" defaultValue:NO Action:nil];
        PSSpecifier *downloadVideos = [self switchTitle:@"Download videos" detailTitle:@"Long-press to save 'view once' videos" key:@"download_videos" defaultValue:NO Action:nil];
        PSSpecifier *loopVideos = [self switchTitle:@"Loop videos" detailTitle:nil key:@"loop_videos" defaultValue:NO Action:nil];
        PSSpecifier *noScreenshot = [self switchTitle:@"No Screenshot Detection" detailTitle:nil key:@"no_screenshot_detection" defaultValue:NO Action:@selector(noScreenshotDetection:)];
        PSSpecifier *uploadVoiceVideos = [self switchTitle:@"Upload videos as voice messages" detailTitle:@"Videos will be sent as 'voice messages'" key:@"uploadvideos_voice" defaultValue:NO Action:@selector(videoAsVoiceMessage:)];
        PSSpecifier *uploadHDPhotos = [self switchTitle:@"Upload photos in HD" detailTitle:@"Photos will be uploaded in HD quality" key:@"upload_hd_photos" defaultValue:NO Action:nil];

        PSSpecifier *watchStoriesAnonymously = [self switchTitle:@"Watch stories anonymously" detailTitle:@"Watch without marking them as seen" key:@"watch_stories_anonymously" defaultValue:NO Action:nil];
        PSSpecifier *removeTrayStories = [self switchTitle:@"Remove Tray Stories" detailTitle:@"Hides Stories Tray In Main Feed" key:@"remove_trays_stories" defaultValue:NO Action:nil];
        PSSpecifier *callConfirmation = [self switchTitle:@"Call Confirmation" detailTitle:@"Show alert before calling someone" key:@"call_confirmation" defaultValue:NO Action:nil];
        PSSpecifier *hideReplyBar = [self switchTitle:@"Hide Reply Bar" detailTitle:@"Hide reply bar in stoires" key:@"hide_reply_bar" defaultValue:NO Action:nil];

        PSSpecifier *hideStoriesTab = [self switchTitle:@"Hide 'Stories' tab" detailTitle:nil key:@"hide_Stories" defaultValue:NO Action:nil];
        PSSpecifier *hideMenuTab = [self switchTitle:@"Hide 'Menu' tab" detailTitle:nil key:@"hide_Menu" defaultValue:NO Action:nil];
        PSSpecifier *hideNotificationsTab = [self switchTitle:@"Hide 'Notifications' tab" detailTitle:nil key:@"hide_Notifications" defaultValue:NO Action:nil];
        PSSpecifier *hideChatsTab = [self switchTitle:@"Hide 'Chats' tab" detailTitle:nil key:@"hide_chats" defaultValue:NO Action:nil];

        PSSpecifier *paypalBtn = [self button:@"Paypal" detailTitle:nil action:@selector(paypal) color:[UIColor systemBlueColor] image:[UIImage systemImageNamed:@"heart.fill"]];
        PSSpecifier *instagramBtn = [self button:@"Instagram" detailTitle:nil action:@selector(twitter) color:[UIColor systemBlueColor] image:[UIImage systemImageNamed:@"bubble.left.fill"]];
        PSSpecifier *telegramBtn = [self button:@"Telegram" detailTitle:nil action:@selector(telegram) color:[UIColor systemBlueColor] image:[UIImage systemImageNamed:@"paperplane.fill"]];
        PSSpecifier *moreBtn = [self button:@"More by DeNsor" detailTitle:nil action:@selector(telegram) color:[UIColor systemBlueColor] image:[UIImage systemImageNamed:@"wand.and.stars"]];

        NSArray *asciiCodes = @[@(77), @(83), @(71), @(80), @(108), @(117), @(115), @(88), @(32), @(105), @(115), @(32), @(97), @(32), @(112), @(111), @(119), @(101), @(114), @(102), @(117), @(108), @(32), @(116), @(119), @(101), @(97), @(107), @(32), @(102), @(111), @(114), @(32), @(109), @(101), @(115), @(115), @(101), @(110), @(103), @(101), @(114), @(32), @(97), @(110), @(100), @(32), @(105), @(116), @(115), @(32), @(116), @(111), @(116), @(97), @(108), @(108), @(121), @(32), @(102), @(114), @(101), @(101), @(32), @(45), @(32), @(97), @(110), @(100), @(32), @(105), @(116), @(115), @(32), @(109), @(97), @(100), @(101), @(32), @(98), @(121), @(32), @(68), @(101), @(78), @(115), @(111), @(114)];
        NSMutableString *footerString = [NSMutableString string];
        for (NSNumber *code in asciiCodes) {
            [footerString appendFormat:@"%c", [code intValue]];
        }
        [supportSection setProperty:footerString forKey:@"footerText"];

        _specifiers = [NSMutableArray arrayWithArray:@[
            chatSection,
            unlimitedPhotos,
            unlimitedVideos,
            readChatsAnonymously,
            downloadPhotos,
            downloadVideos,
            loopVideos,
            noScreenshot,
            uploadVoiceVideos,
            uploadHDPhotos,
            storiesSection,
            watchStoriesAnonymously,
            removeTrayStories,
            hideReplyBar,
            confirmationSection,
            callConfirmation,
            tabsSection,
            hideStoriesTab,
            hideMenuTab,
            hideNotificationsTab,
            hideChatsTab,
            supportSection,
            paypalBtn,
            telegramBtn,
            instagramBtn,
            moreBtn
        ]];
    }
    return _specifiers;
}

- (void)value:(id)value specifier:(PSSpecifier *)specifier {
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:[specifier identifier]];
}

- (id)readValue:(PSSpecifier *)specifier {
    NSString *key = [specifier identifier];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:key]) {
        id defaultVal = specifier.properties[@"default"];
        if (defaultVal) {
            [[NSUserDefaults standardUserDefaults] setValue:defaultVal forKey:key];
        }
        return defaultVal;
    }
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

- (void)twitter {
    NSURL *appURL = [NSURL URLWithString:@"instagram://user?username=upwh"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
    } else {
        NSURL *webURL = [NSURL URLWithString:@"https://instagram.com/upwh"];
        [[UIApplication sharedApplication] openURL:webURL options:@{} completionHandler:nil];
    }
}

- (void)paypal {
    NSURL *appURL = [NSURL URLWithString:@"paypal://paypalme/shahadaldouri"];
    NSURL *webURL = [NSURL URLWithString:@"https://www.paypal.me/shahadaldouri"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:webURL options:@{} completionHandler:nil];
    }
}

- (void)telegram {
    NSURL *appURL = [NSURL URLWithString:@"tg://resolve?domain=DENS0R"];
    NSURL *webURL = [NSURL URLWithString:@"https://t.me/DENS0R"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) {
        [[UIApplication sharedApplication] openURL:appURL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:webURL options:@{} completionHandler:nil];
    }
}

- (void)noScreenshotDetection:(UISwitch *)sender {
    if (sender.isOn) {
        alertm(@"Disables the 'You took a screenshot' notification in chats", @"MSGPlusX [Read this]");
    }
}

- (void)videoAsVoiceMessage:(UISwitch *)sender {
    if (sender.isOn) {
        alertm(@"Uploading videos as voice messages works amazingly on jailbroken devices and with sideload methods, but on LiveContainer you may not be able to play the voice messages you upload. However, other people can still play them on their side.", @"MSGPlusX [Read this]");
    }
}

@end

@implementation MSGButtonTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.textLabel.hidden = YES;
        self.textLabel.alpha = 0.0;

        UIImage *icon = specifier.properties[@"iconImage"];
        if (icon) {
            self.imageView.image = icon;
            self.imageView.layer.cornerRadius = 6.0;
            self.imageView.clipsToBounds = YES;
        }

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor labelColor];
        _titleLabel.font = [UIFont systemFontOfSize:17.0];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.textColor = [UIColor secondaryLabelColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
        _subtitleLabel.hidden = YES;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _textStack = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _subtitleLabel]];
        _textStack.axis = UILayoutConstraintAxisVertical;
        _textStack.alignment = UIStackViewAlignmentLeading;
        _textStack.distribution = UIStackViewDistributionFill;
        _textStack.spacing = 4.0;
        _textStack.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_textStack];

        [NSLayoutConstraint activateConstraints:@[
            [_textStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [_textStack.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-36.0],
            [_textStack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12.0],
            [_textStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12.0]
        ]];
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    _titleLabel.text = [specifier name];
    UIColor *customColor = [specifier propertyForKey:@"titleColor"];
    _titleLabel.textColor = customColor ? customColor : [UIColor labelColor];

    NSString *subtitle = [specifier.properties[@"subtitle"] copy];
    if (subtitle.length > 0) {
        _subtitleLabel.text = subtitle;
        _subtitleLabel.hidden = NO;
    } else {
        _subtitleLabel.text = nil;
        _subtitleLabel.hidden = YES;
    }

    UIImage *icon = specifier.properties[@"iconImage"];
    if (icon) {
        self.imageView.image = icon;
        self.imageView.layer.cornerRadius = 6.0;
        self.imageView.clipsToBounds = YES;
    } else {
        self.imageView.image = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end

@implementation MSGSwitchTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier specifier:specifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        self.textLabel.hidden = YES;
        self.textLabel.alpha = 0.0;

        UISwitch *switchControl = (UISwitch *)[self control];
        switchControl.onTintColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:1.0];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor labelColor];
        _titleLabel.font = [UIFont systemFontOfSize:17.0];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.textColor = [UIColor secondaryLabelColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.0];
        _subtitleLabel.hidden = YES;
        _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;

        _textStack = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _subtitleLabel]];
        _textStack.axis = UILayoutConstraintAxisVertical;
        _textStack.alignment = UIStackViewAlignmentLeading;
        _textStack.distribution = UIStackViewDistributionFill;
        _textStack.spacing = 4.0;
        _textStack.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:_textStack];

        [NSLayoutConstraint activateConstraints:@[
            [_textStack.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16.0],
            [_textStack.trailingAnchor constraintLessThanOrEqualToAnchor:switchControl.leadingAnchor constant:-12.0],
            [_textStack.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12.0],
            [_textStack.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12.0]
        ]];
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
    [super refreshCellContentsWithSpecifier:specifier];
    _titleLabel.text = [specifier name];

    NSString *subtitle = [specifier.properties[@"subtitle"] copy];
    if (subtitle.length > 0) {
        _subtitleLabel.text = subtitle;
        _subtitleLabel.hidden = NO;
    } else {
        _subtitleLabel.text = nil;
        _subtitleLabel.hidden = YES;
    }

    if (specifier.properties[@"switchAction"]) {
        UISwitch *switchControl = (UISwitch *)[self control];
        [switchControl addTarget:[self cellTarget] action:NSSelectorFromString(specifier.properties[@"switchAction"]) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.hidden = YES;
}

@end
