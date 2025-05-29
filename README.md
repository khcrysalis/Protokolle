# Protokolle

[![GitHub Release](https://img.shields.io/github/v/release/khcrysalis/protokolle?include_prereleases)](https://github.com/khcrysalis/protokolle/releases)
[![GitHub License](https://img.shields.io/github/license/khcrysalis/protokolle?color=%23C96FAD)](https://github.com/khcrysalis/protokolle/blob/main/LICENSE)

The iOS/iPadOS equivalent to macOS's `Console.app`. This app uses [idevice](https://github.com/jkcoxson/idevice) and lockdownd pairing to stream messages from the trace relay, allowing you to see messages from other processes within iOS. Along with having advanced filtering and options for advanced debugging and performance.

### Demo

|					![Demo of streaming trace logs](Images/demo.webp)						 |
| :----------------------------------------------------------------------------------------: |
| Demo of streaming trace logs from [Feather-idevice](https://github.com/khcrysalis/feather) |

### Features

- Stream system logs (messages)
- View system logs with immense detail (i.e. `pid`, `name`, `message`, `sendor`, `date`, `type`).
- Advanced filtering options for log types, keywords, and process ID's.
- Performance options for logs, to prevent any excessive ram usage, and general usability of the app.
- Ability to import/export logs to be viewed later.
- Built-in tunnel VPN for making usage easier.
- Of course, open source and free.

## Download

Visit [releases](https://github.com/khcrysalis/Protokolle/releases) and get the latest `.ipa`.

## How does it work?
- Establish a heartbeat with a TCP provider (the app will need this for later).
  - For it to be successful, we need a pairing file from [JitterbugPair](https://github.com/osy/Jitterbug/releases) and a [VPN](https://apps.apple.com/us/app/stosvpn/id6744003051).
  - Once we have these and the connection was successfully established, we can move on to the streaming part.
  - Before streaming, we need to check for the connection to the socket that has been created, routed to `10.7.0.1`, if this succeeds we're ready.
- When preparing the stream, we need to establish another connection but for `syslog_relay` using our TCP provider and heartbeat provider.
- Then using out connection use a loop to get each message and feed it to a delegate, where its used to update our UI.

Due to how it works right now we need both a VPN and a lockdownd pairing file, this means you will need a computer for its initial setup.

## Building

#### Minimum requirements

- Xcode 16
- Swift 5.9
- iOS 16

1. Clone repository
    ```sh
    git clone https://github.com/khcrysalis/Protokolle
    ```

2. Compile
    ```sh
    cd Protokolle
    gmake
    ```

3. Updating
    ```sh
    git pull
    ```

Using the makefile will automatically create an adhoc ipa inside the packages directory, using this to debug or report issues is not recommend. When making a pull request or reporting issues, it's generally advised you've used Xcode to debug your changes properly.

## Star History

<a href="https://star-history.com/#khcrysalis/protokolle&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=khcrysalis/protokolle&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=khcrysalis/protokolle&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=khcrysalis/protokolle&type=Date" />
 </picture>
</a>

## Acknowledgements

- [Samara](https://github.com/khcrysalis) - The maker
- [Antoine](https://github.com/NSAntoine/Antoine) - Code for filtering, refresh, and the sole reason why I even made this.
- [idevice](https://github.com/jkcoxson/idevice) - Backend functionality, uses `os_trace_relay` to retrieve messages.
- [Stossy11](https://github.com/stossy11/) - [StosVPN](https://github.com/SideStore/StosVPN) tunnel code, very appreciated.

## License 

This project is licensed under the GPL-3.0 license. You can see the full details of the license [here](https://github.com/khcrysalis/Feather/blob/main/LICENSE). Code from Antoine is going to be under MIT, if you figure out where that is.

By contributing to this project, you agree to license your code under the GPL-3.0 license as well (including agreeing to license exceptions), ensuring that your work, like all other contributions, remains freely accessible and open.
