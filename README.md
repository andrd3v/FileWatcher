# FileWatcher

macOS daemon + client for monitoring file system changes on the Desktop via XPC.

## Architecture

- **filewatcher** (daemon) — LaunchAgent that uses FSEvents to watch `~/Desktop` for file creation and deletion. Communicates with clients over XPC (Mach service `com.andrd3v.filewatcher`).
- **filewatcherclient** — connects to the daemon, sends `startWatching` command, and receives real-time callbacks (`fileDidAppear:` / `fileDidDisappear:`) when files are created or removed.

## Example output

```
$ ./filewatcherclient
echo
start watching
/Users/andrei/Desktop/report.pdf
/Users/andrei/Desktop/screenshot.png
/Users/andrei/Desktop/report.pdf
/Users/andrei/Desktop/screenshot.png
```

## Project context

This is a student project. All code was written manually - I used Google and Apple documentation as references but did not ask any AI to write code for me.
