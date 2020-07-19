# godot-multi-builder
![Test Build](https://github.com/croconut/godot-debug-builder/workflows/Build%20tester/badge.svg)

Builds your Godot game for Android, Windows, Linux, MacOSX and/or HTML5.

status: 
- Android is only working for debug exports, will need to set up gathering Android credentials 
from user's github secrets. 

- UWP and iOS won't be supported for this action.

## get started

Create a workflow in .github/workflows, e.g. main.yaml.

Write something like this: 

Sidenote: Make sure you change the path to your godot game directory; if it's in 
your top level folder you can just delete the "path-to-game" line of code below as that's the default. 
You'll also need to set your exports in your godot project. Just add the exports in editor and ensure that
the export names don't have spaces in them.

~~~ yaml
name: Build tester

on:
  push:
    branches:
    - master

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: croconut/godot-multi-builder@v1
      with:
      #comma separated export presets
        names: "Linux/X11, HTML5, Android, WindowsDesktop, MacOSX"
        # if path is in the top level of your directory, skip
        path-to-game: "tester"
        # defaults to true, Android currently only exports to debug
        debug-mode: "true"
        # outputs to path-to-game/builds/builds.zip
        # if run multiple times, you can use the step's output variable
        # to retrieve the separate builds.zip files
        # if any zip files are too big for your purposes, unzipping is
        # likely your best bet
    - run: |
          unzip ./tester/builds/builds.zip
          git config user.email github-actions@github.com
          git config user.name github-actions
          git add ./tester/builds/*
          git reset -- ./tester/builds/builds.zip
          git commit -m 'builds generated'
          git push --force
~~~

## FAQ

Q: Where are the builds?

A: They're all in {path-to-godot-project-folder}/builds/builds.zip. They're also in the step's output, 
designated with builds. You'll want to set the id if you want to use outputs; your code could look something like this:

~~~ yaml
steps:
- uses: actions/checkout@v2
- uses: croconut/godot-multi-builder@v1
  id: builds
  with:
  #comma separated export presets
    names: "Linux/X11, HTML5, Android, WindowsDesktop, MacOSX"
    # if path is in the top level of your directory, skip
    path-to-game: "tester"
    # defaults to true, Android currently only exports to debug
    debug-mode: "true"
   
# because we set the id, we can access the output with:
# ${{ steps.build_package.outputs.builds }}
# but we'll just upload the .zip file directly as our artifact
- uses: actions/upload-artifact@v1
  with:
    name: my-builds
    path: tester/builds/builds.zip
# now another job would be able to access the my-builds artifact
# and do something with it
~~~

Q: My export ("Windows Desktop") isn't working!?

A: Rename your export so that it has no spaces. Godot does not like spaces.

Q: Android release isn't working?

A: Only debug exports are supported for Android builds right now. Should be able to get it up and running soon.

Q: builds/builds.zip is too big!

A: You could unzip it and deal with the individual exports.

Q: How should I use this to deploy?

A: Deploy actions using the given step output in the same job, or generating an artifact with the output and deploying with that.
