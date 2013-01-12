# Open Tracker

## What is it?
Open Tracker is a time tracking ruby script for Windows. 
This is my first proper programming project. Any code-reviews will be highly appreciated :)

## Features
* Tracks time by the second on active foreground processes
* Suspends tracking if user is inactive
* Logs all data locally into CSV files. 

## Getting Started

You need to have Ruby installed.

Clone the repository

```sh
cd OpenTracker
bundle install
rubyw.exe openTracker.rb 
```

## Adding Custom Definitions to Programs.yaml

Open Tracker tracks processes by the Process Name. If you wish to change it to a more human-readable format
you can edit the Programs.yaml file to reflect the change.
Examples have been added, I'll be looking to update it with a common list of programs soon.

## Adding Open Tracker to start at Start-up

Open Tracker can be made to run on start-up by adding the ruby script using the Windows Task Scheduler

## Graphing Data

Right now I am looking to work on using a graphing library to be able to automatically graph the data.

## Known Bugs

There is usually an unknown nul process that pops up in the logs sometimes. This usually occurs when the tracker tries
to track during the process of switching windows I believe. It does not cause the program to crash.
If there are any other bugs, please let me know by e-mail

## TO DO / Features Requests

Add Browser Integration to record active website usage.

## License
The code is licensed under Creative-Commons Attribution-NonCommercial 3.0 Unported






