#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <objc/message.h>

OBJC_EXPORT id objc_msgSendSuper2(void);

namespace ktrf_FriendsTabViewController {
    namespace viewDidLoad {
        void (*original)(__kindof UIViewController *self, SEL _cmd);
        void custom(__kindof UIViewController *self, SEL _cmd) {
            original(self, _cmd);

            NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
            BOOL shouldShowOldFriends;
            NSNumber * _Nullable object = [defaults objectForKey:@"ktrf_showOldFriends"];
            if (object != nil && [object isKindOfClass:[NSNumber class]]) {
                shouldShowOldFriends = object.boolValue;
            } else {
                shouldShowOldFriends = YES;
            }

            __kindof UIViewController *old = [[objc_lookUpClass("_TtC9KakaoTalk21FriendsViewController") alloc] init];
            [self addChildViewController:old];
            [self.view addSubview:old.view];
            old.view.frame = self.view.bounds;
            old.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [old didMoveToParentViewController:self];
            old.view.hidden = !shouldShowOldFriends;
            [old release];
        }
        void hook(void) {
            Method method = class_getInstanceMethod(objc_lookUpClass("_TtC23FriendsFeedPresentation24FriendsTabViewController"), @selector(viewDidLoad));
            if (method == NULL) return;
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

namespace ktrf_MainTabBarController {
   namespace tabBarController_shouldSelectViewController_ {
        BOOL (*original)(__kindof UITabBarController *self, SEL _cmd, __kindof UITabBarController *tabBarController, __kindof UIViewController *viewController);
        BOOL custom(__kindof UITabBarController *self, SEL _cmd, __kindof UITabBarController *tabBarController, __kindof UIViewController *viewController) {
            BOOL result = original(self, _cmd, tabBarController, viewController);

            if ([viewController isKindOfClass:objc_lookUpClass("_TtC11TalkAppBase23KUINavigationController")] && [self.selectedViewController isEqual:viewController]) {
                __kindof UIViewController *topViewController = ((UINavigationController *)viewController).topViewController;
                if ([topViewController isKindOfClass:objc_lookUpClass("_TtC23FriendsFeedPresentation24FriendsTabViewController")]) {
                    for (__kindof UIViewController *child in topViewController.childViewControllers) {
                        if ([child isKindOfClass:objc_lookUpClass("_TtC9KakaoTalk21FriendsViewController")]) {
                            child.view.hidden = !child.view.hidden;
                            [NSUserDefaults.standardUserDefaults setBool:!child.view.hidden forKey:@"ktrf_showOldFriends"];
                            break;
                        }
                    }
                }
            }

            return result;
        }
        void hook(void) {
            Method method = class_getInstanceMethod(objc_lookUpClass("_TtC9KakaoTalk20MainTabBarController"), @selector(tabBarController:shouldSelectViewController:));
            if (method == NULL) return;
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

__attribute__((constructor)) static void init() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    ktrf_FriendsTabViewController::viewDidLoad::hook();
    ktrf_MainTabBarController::tabBarController_shouldSelectViewController_::hook();

    [pool release];
}
