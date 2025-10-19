#import <UIKit/UIKit.h>
#include <objc/runtime.h>
#include <objc/message.h>

namespace ktrf_FriendsTabViewController {
    namespace viewDidLoad {
        void (*original)(__kindof UIViewController *self, SEL _cmd);
        void custom(__kindof UIViewController *self, SEL _cmd) {
            original(self, _cmd);

            __kindof UIViewController *old = [[objc_lookUpClass("_TtC9KakaoTalk21FriendsViewController") alloc] init];
            [self addChildViewController:old];
            [self.view addSubview:old.view];
            old.view.frame = self.view.bounds;
            old.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [old didMoveToParentViewController:self];
            [old release];
        }
        void hook(void) {
            Method method = class_getInstanceMethod(objc_getClass("_TtC23FriendsFeedPresentation24FriendsTabViewController"), @selector(viewDidLoad));
            if (method == NULL) return;
            original = reinterpret_cast<decltype(original)>(method_getImplementation(method));
            method_setImplementation(method, reinterpret_cast<IMP>(custom));
        }
    }
}

__attribute__((constructor)) static void init() {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    ktrf_FriendsTabViewController::viewDidLoad::hook();

    [pool release];
}
