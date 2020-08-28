##  About
```XCTool``` is a command line tool for executing tests and parsing ```.xcresult``` bundle.

##  How It Works
It starts by executing tests using ```xcodebuild``` command. The output ```.xcresult``` bundle is fed to ```XCTool``` to parse performance test-summaries.

## Types Involved
1.  ```XCTool``` struct takes path to ```xcresultBundle``` as input and executes ```xcresulttool``` to parse performance test-summaries.
2.  ```ArgParser``` struct parses command-line arguments. It has a method to provide value for a given command-line tag.
3.  ```ResultBundle``` class takes path to ```xcodeproj``` as input. It has a lazy property to store ```xcresult``` bundle path relative to the project.
4.  ```Constants``` enum contains constants for executable paths, command-line arguments for ```xcresulttool``` and ```xcodebuild```, project-path and scheme-name.
5.  ```ActionsInvocationRecord``` struct contains ```actions```, ```metadataRef``` and ```metrics```. We extract ```testsRefId``` from this nested data-model.
6.  ```ActionTestPlanRunSummaries``` struct contains ```summaries```. We extract ```summaryRefIds``` correspoding to each test from this data-model.
7.  ```ActionTestSummary``` struct contains ```performanceMetrics```, ```duration```, ```identifier```, ```name``` and ```testStatus```. We log this data-model corresponding to each performance test.
8.  ```REPLExecutor``` struct takes ```REPLCommand``` as input and executes that command. It also formats/decode the output as needed.
9.  ```REPLCommand``` struct takes ```launchPath``` and ```arguments``` as input. It has ```run``` methods which launch a ```Process``` with given inputs and attach a ```Pipe``` for reading standardOutput.
10.   ```REPLBuffer``` struct temporarily holds  ```Data``` buffer as it gets streamed from standardOutput. It has mutating methods to ```append``` data in buffer and get ```outstandingText``` from buffer.

## Commands Used
1. Execute tests ```xcodebuild -project <project-path> -scheme <scheme-name> -destination <destination(platform, name, OS)> test```
2. JSON representation of the root object of the result bundle ```xcrun xcresulttool get --format json --path <xcresult-bundle-path>```
3. Nested object in result bundle can be identified by its reference ```xcrun xcresulttool get --format json --path <xcresult-bundle-path> --id REF```
4. ```xcresulttool``` provides description of its format using ```xcrun xcresulttool formatDescription```

## Tools Version
1.  ```$ xcrun xcresulttool version``` <br/>
xcresulttool version 17017, format version 3.26 (current)
2.  ```$ xcodebuild -version``` <br/>
Xcode 12.0<br/>
Build version 12A8189n

## Future Support
Automatically run tests on a connected device:<br/> https://github.com/fastlane/fastlane/blob/master/fastlane_core/lib/fastlane_core/device_manager.rb#L68<br/>
http://www.maytro.com/2014/05/11/using-xcodebuild-to-automatically-run-tests-on-connected-device.html

## References
https://developer.apple.com/videos/play/wwdc2019/413/?time=2932<br/>
https://developer.apple.com/documentation/xcode-release-notes/xcode-11-release-notes<br/>
https://www.chargepoint.com/engineering/xcparse/
