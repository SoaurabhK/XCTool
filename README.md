XCTool: To build performance testing pipeline
======================================

```XCTool``` is a command line tool for executing tests, automatically re-running failures and parsing ```.xcresult``` bundle(s). It is currently intended to be integerated with your performance testing CI pipeline.

## Usage
To invoke XCTool use the following command:<br/>
```$ ./XCTool -workspace <workspace-path> -project <project-path> -scheme <scheme-name> -destination <destination(platform,name,OS(for simulator)>```

Refer project [.xcscheme](XCTool.xcodeproj/xcshareddata/xcschemes/XCTool.xcscheme#L53-L86) file for an example usage of the command line arguments.

##  How It Works
It starts by executing tests using ```xcodebuild test``` command. Test-failures(i.e. flaky environment) are handled by re-running the failing tests. ```XCTool``` extracts performance test-summaries from ```.xcresult``` bundle(s) produced in a test-run. On completion, test summaries are dump(ed) on the console and ```.xcresult``` bundle(s) are inside project-relative ```ResultBundles``` directory.

## Types Involved
1.  ```XCTool``` struct takes path to ```xcresultBundle``` as input and executes ```xcresulttool``` to parse performance test-summaries.
2.  ```ArgParser``` struct parses command-line arguments passed during launch. It has a static var to provide ```launchArgs```.
3.  ```ResultBundle``` class takes path to ```xcodeproj``` as input. It provides project-relative bundle-path for a given test-run.
4.  ```Constants``` enum contains constants for executable paths, command-line arguments for ```xcresulttool```, ```xcodebuild``` and maxRetries on failure. Paths may vary dependending on Xcode's install location.
5.  ```ActionsInvocationRecord``` struct contains ```actions```, ```metadataRef``` and ```metrics``` parsed from the result-bundle. We extract ```testsRefIds``` from this nested data-model.
6.  ```ActionTestPlanRunSummaries``` struct contains ```summaries``` parsed from the result-bundle. We extract ```summaryRefIds``` correspoding to each test from this nested data-model.
7.  ```ActionTestSummary``` struct contains ```performanceMetrics```, ```duration```, ```identifier```, ```name``` and ```testStatus``` parsed from the result-bundle. ```TestSummary``` representing a performance test summary, is created from ```ActionTestSummary``` by associating an additional ```targetName``` for each test.
8.  ```REPLExecutor``` struct takes ```REPLCommand``` as input and executes that command. It's sync-version decodes the result in a given data-model and the async-version streams standardOutput buffer line-by-line.
9.  ```REPLCommand``` struct takes ```launchPath``` and ```arguments``` as input. It has sync/async ```run``` methods which launch a ```Process``` with given inputs and attach a ```Pipe``` for reading standardOutput.
10.   ```REPLBuffer``` struct temporarily holds  ```Data``` buffer as it gets streamed from standardOutput. It has mutating methods to ```append``` data in buffer and get ```outstandingText``` from buffer.
11.  ```TestFailure``` struct takes ```testSummaries``` and project-configuration to retry/re-run failed-tests, due to flaky environment i.e. mostly XCUITests-Runner issues.

## Commands Used
1. Execute tests ```xcodebuild test -workspace <workspace-path> -scheme <scheme-name> -destination <destination(platform, name, OS)> -resultBundlePath <bundle-path>```
2. Run specific tests without building ```xcodebuild test-without-building -workspace <workspace-path> -scheme <scheme-name> -destination <destination(platform, name, OS)> -resultBundlePath <bundle-path> -only-testing:<test-identifier>```
3. JSON representation of the root object of the result bundle ```xcrun xcresulttool get --format json --path <xcresult-bundle-path>```
4. Nested object in result bundle can be identified by its reference ```xcrun xcresulttool get --format json --path <xcresult-bundle-path> --id REF```
5. ```xcresulttool``` provides description of its format using ```xcrun xcresulttool formatDescription```

## Tools & OS Version
1.  ```$ xcrun xcresulttool version``` <br/>
xcresulttool version 17017, format version 3.26 (current)
2.  ```$ xcodebuild -version``` <br/>
Xcode 12.0<br/>
Build version 12A8189n
3.  macOS 10.15 and later.

## Future Improvements
1.  Automatically run tests on a connected device:<br/>
       https://github.com/fastlane/fastlane/blob/master/fastlane_core/lib/fastlane_core/device_manager.rb#L68<br/>
       http://www.maytro.com/2014/05/11/using-xcodebuild-to-automatically-run-tests-on-connected-device.html<br/>
2.  Use ```-xctestrun``` option in ```xcodebuild test-without-building``` for distributed build and test machines:<br/>
       https://developer.apple.com/videos/play/wwdc2016/409/<br/>
       https://stackoverflow.com/a/47019252<br/>
3.  Send performance output to customisable server endpoints.<br/>
4.  Failure reporting by sending filtered logs and crash-reports to customisable server endpoints.<br/>
5.  Pretty logging without using ```xcpretty```.<br/>

PRs, issues, [ideas and suggestions](https://twitter.com/soaurabh) are very welcome!

## Contributing
XCTool welcomes contributions in the form of GitHub issues and pull-requests: <br/>
1.  For PRs, please add the purpose and summary of your changes in the PR description.<br/>
2.  For issues, please add the steps to reproduce and tools/OS version.<br/>
3.  Make sure you test your contributions.<br/>

By submitting a pull request, you represent that you have the right to license your contribution to Soaurabh Kakkar and the community, and agree by submitting the patch that your contributions are licensed under the XCTool project license.

## License
XCTool is licensed under the [MIT License](LICENSE.md)

## References
https://developer.apple.com/library/archive/technotes/tn2339/_index.html<br/>
https://developer.apple.com/videos/play/wwdc2019/413/?time=2932<br/>
https://developer.apple.com/documentation/xcode-release-notes/xcode-11-release-notes<br/>
https://www.chargepoint.com/engineering/xcparse/
