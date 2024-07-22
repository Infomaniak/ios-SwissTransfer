# SwissTransfer
SwissTransfer application for iOS

Send up to 50 GB - Free and without registration - Keep your transfers for up to 30 days.

## Installation

This project uses [Mise](https://github.com/jdx/mise) to manage build tools versions. Once installed you can run in the project directory `mise install` to get all the tools.

This project uses [Tuist](https://docs.tuist.io/guides/quick-start/install-tuist) to prevent conflicts on xcodeproj files. To generate the Xcode project, you need to install Tuist and run the `tuist install` and `tuist generate` commands. Refer to their documentation for more information.

## Architecture

A [KMP library](https://github.com/Infomaniak/multiplatform-SwissTransfer) is used to share code between the iOS and Android versions of the app.
This app uses a modular architecture. Each feature is placed in a module.

## Contributing

If you see a bug or an enhancement point, feel free to create an issue, so that we can discuss it. Once approved, we or you (
depending on the priority of the bug/improvement) will take care of the issue and apply a merge request. Please, don't do a merge
request before creating an issue.

## License

This project is under GPLv3 license. See the LICENSE file for more details.
