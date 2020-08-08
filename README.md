##  About
```XCParser``` is a command line tool for executing tests and parsing ```.xcresult``` bundle.

##  How It Works
It starts by executing tests using ```xcodebuild``` command. The output ```.xcresult``` bundle is fed to ```XCParser``` to parse performance test-summaries.

## Types Involved
1.  ```XCParser``` struct takes path to ```xcresultBundle``` as input and executes ```xcresulttool``` to parse performance test-summaries.
2.  ```Constants``` enum contains constants for executable paths, command-line arguments for ```xcresulttool``` and ```xcodebuild```, project-path and scheme-name.
3.  ```ActionsInvocationRecord``` struct contains ```actions```, ```metadataRef``` and ```metrics```. We extract ```testsRefId``` from this nested data-model.
4.  ```ActionTestPlanRunSummaries``` struct contains ```summaries```. We extract ```summaryRefIds``` correspoding to each test from this data-model.
5.  ```ActionTestSummary``` struct contains ```performanceMetrics```, ```duration```, ```identifier```, ```name``` and ```testStatus```. We log this data-model corresponding to each performance test.
6.  ```REPLExecutor``` struct takes ```REPLCommand``` as input and executes that command. It also formats/decode the output as needed.
7.  ```REPLCommand``` struct takes ```launchPath``` and ```arguments``` as input. It has ```run``` methods which launch a ```Process``` with given inputs and attach a ```Pipe``` for reading standardOutput.
8.   ```REPLBuffer``` struct temporarily holds  ```Data``` buffer as it gets streamed from standardOutput. It has mutating methods to ```append``` data in buffer and get ```outstandingText``` from buffer.

## Commands Used
1. Execute tests ```xcodebuild -project <project-path> -scheme <scheme-name> -destination <destination(platform, name, OS)> test```
2. JSON representation of the root object of the result bundle ```xcrun xcresulttool get --format json --path <xcresult-bundle-path>```
3. Nested object in result bundle can be identified by its reference ```xcrun xcresulttool get --format json --path <xcresult-bundle-path> --id REF```
4. ```xcresulttool``` provides description of its format using ```xcrun xcresulttool formatDescription```

## References
https://developer.apple.com/videos/play/wwdc2019/413/?time=2932<br/>
https://developer.apple.com/documentation/xcode-release-notes/xcode-11-release-notes<br/>
https://www.chargepoint.com/engineering/xcparse/
