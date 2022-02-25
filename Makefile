.PHONY: bindings
bindings: bindings-android bindings-ios

.PHONY: bindings-android
bindings-android:
	mkdir -p android/app/src/libs
	gomobile bind -o android/app/src/libs/kubenav.aar -target=android github.com/kubenav/kubenav/cmd/kubenav

.PHONY: bindings-ios
bindings-ios:
	mkdir -p ios/Runner/libs
	gomobile bind -o ios/Runner/libs/Kubenav.xcframework -target=ios github.com/kubenav/kubenav/cmd/kubenav
