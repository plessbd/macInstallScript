# How to run a local Selenium Grid on OSX

This is to run a selenium grid supporting firefox, chrome, phantomjs, iOS Simulators, and Android Simulators 

## prerequisites

* [Homebrew](http://brew.sh/)
```bash
which -s brew
if [[ $? != 0 ]] ; then
	# Install Homebrew
	# http://brew.sh/
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
	brew update
fi
brew doctor
```
* [Homebrew Cask](http://caskroom.io/)
```bash
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew tap caskroom/versions
brew install caskroom/cask/brew-cask
```
* [node.js](https://nodejs.org/)
```bash
brew install nodejs
npm install -g npm@latest
```
* [appium](http://appium.io)
```bash
npm -g appium
authorize_ios
```
* selenium-standalone (My version until this [issue](https://github.com/vvo/selenium-standalone/issues/97) is fixed)
`npm -g install plessbd/selenium-standalone`
* Browsers
	* MobileSafari (requires xcode from Apple App Store and Simulators from xcode downloads)
	* [FireFox](http://getfirefox.com) `cask install firefox`
	* [Chrome](http://google.com/chrome) `cask install google-chrome`
	* [PhantomJS](http://phantomjs.org/) `brew install -g phantomjs`
	* Android SDK
		* [android sdk](https://developer.android.com/sdk/index.html "Android") `brew install android-sdk`
		* [intel HAXM](https://software.intel.com/en-us/android/articles/intel-hardware-accelerated-execution-manager) `cask install intel-haxm`
		* android support `android update sdk --no-ui --all --filter tools,platform-tools,build-tools-22.0.1,android-22,extra-intel-Hardware_Accelerated_Execution_Manager,extra-google-simulators,sys-img-x86_64-addon-google_apis-google-22`
		* I got an error of: Skipping 'Google APIs Intel x86 Atom_64 System Image, Google Inc. API 22, revision 1'; it depends on 'Google APIs, Android API 22, revision 1' which was not installed.  I had to run android and get the GUI to install the system image. `android`
		* [android virtual device](https://developer.android.com/tools/devices/index.html) `android create avd -n AVD_for_Nexus_7_by_Google -t 1 --abi default/x86_64`
			* devices
				* https://github.com/j5at/AndroidAVDRepo/tree/master/avd
				* http://developer.samsung.com/technical-doc/view.do;jsessionid=5xlTVhtbhYCx53ZynVpqyGq6GlQGGQJmnCN2D1qJtwnnygFDxT5m!167119927?v=T000000095
				* https://github.com/mingchen/android-emulator-skins
				* http://stackoverflow.com/questions/16608530/how-to-reuse-the-existing-avds-for-android-studio

## Config Files

appium_nodeconfig.json
```json
{
	"capabilities":[{
		"browserName": "safari",
		"version":"iOS8.3",
		"maxInstances": 1,
		"platform":"MAC"
	}],
	"configuration":
	{
		"cleanUpCycle":2000,
		"timeout":30000,
		"proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
		"url":"http://localhost:4723/wd/hub",
		"host": "localhost",
		"port": 4723,
		"maxSession": 1,
		"register": true,
		"registerCycle": 5000,
		"hubPort": 4444,
		"hubHost": "localhost"
	}
}
```
browsers.json
used for programatically setting clients
```json
{
	"chrome":{
		"desiredCapabilities":{
			"browserName":"chrome"
		}
	},
	"firefox":{
		"desiredCapabilities":{
			"browserName":"firefox"
		}
	},
	"phantomjs":{
		"desiredCapabilities":{
			"browserName":"phantomjs"
		}
	},
	"iPad2": {
		"desiredCapabilities": {
			"browserName": "safari",
			"appiumVersion": "1.4.0",
			"deviceName": "iPad 2",
			"device-orientation": "portrait",
			"platformName": "iOS"
		}
	}
}
```

## Running grid

###Without config files, in different terminal windows
```bash
selenium-standalone start -- -role hub
```
```bash
selenium-standalone start -- -role node -browser browserName=firefox,maxInstances=1 -browser browserName=chrome,maxInstances=1
```
```bash
appium --nodeconfig "<path to appium_nodeconfig.json>" --platform-version "8.3" --platform-name "iOS"
```

### do some exporting
```bash
export ANDROID_HOME=/Volumes/750GBHD/usr/local/opt/android-sdk
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```
### Start the android emulator
`emulator -avd AVD_for_Nexus_7_by_Google`

to [view](http://localhost:4444/grid/console) the grid in your browser goto: http://localhost:4444/grid/console



### Extra

https://www.addthis.com/blog/2013/07/22/10-tips-for-android-emulator/#.VVqqu2RViko
https://github.com/appium/appium/blob/master/docs/en/advanced-concepts/grid.md
https://www.npmjs.com/package/selenium-standalone#selenium-start-opts-cb
http://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
https://github.com/SeleniumHQ/selenium/wiki/Grid2

#### Useful commands for android
android list targets
android list sdk --all --extended

