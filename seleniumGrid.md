# How to run a local Selenium Grid on OSX

This is to run a selenium grid supporting firefox, chrome, phantomjs, and iOS Simulators, this is a subset of https://github.com/plessbd/macInstallScript so if you have used that skip to the config files

## prerequisites

* Homebrew (http://brew.sh/)
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
* caskroom (http://caskroom.io/)
```bash
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
brew tap caskroom/versions
brew install caskroom/cask/brew-cask
```
* node.js (https://nodejs.org/)
```bash
brew install nodejs
npm install -g npm@latest
```
* appium (http://appium.io)
```bash
npm -g appium
authorize_ios
```
* selenium-standalone (for now my version https://github.com/plessbd/selenium-standalone)
`npm -g install plessbd/selenium-standalone`
* Browsers
	* FireFox `cask install firefox`
	* Chrome `cask install google-chrome`
	* phantomjs `brew install -g phantomjs`
	* MobileSafari (requires xcode from Apple App Store and Simulators from xcode downloads)

## Config Files

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

to view the grid in your browser goto:
http://localhost:4444/grid/console


#android
`brew cask install intel-haxm`
### links
https://github.com/appium/appium/blob/master/docs/en/advanced-concepts/grid.md
https://www.npmjs.com/package/selenium-standalone#selenium-start-opts-cb
http://www.mkyong.com/java/how-to-set-java_home-environment-variable-on-mac-os-x/
https://github.com/SeleniumHQ/selenium/wiki/Grid2
