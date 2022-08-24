---
2022-08-22 10:10
description: Swift development without desktop
tags: Swift Package, CLI, GitHub, Working Copy
---
# NEED TO CHECK WITH LATEST CODE SAMPLES AND FILE NAMES IN NoDesktop repo

# Desktop-less Development

## New Repo

Create new GitHub repo using GitHub website (mobile version works ok).
    
Enable “create `.gitignore`” option by selecting `Swift`.


## New Workflow

Add new workflow via GitHub.com: in the repo Actions tab select `Skip this and set up a workflow yourself ->` (suggested name is `swift-package-init.yml`) with the following content:

```yml
# This is a simple workflow to initialize swift package and commit it to the new branch

name: Swift Package Init

# Controls when the workflow will run
on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job to initialize swift package
  package_init:
    # The type of runner that the job will run on
    runs-on: macos-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - uses: actions/checkout@v3

      # Runs a single command using the runners shell
      - name: Swift Package init
        run: swift package init

      # Commit changes made in the workflow run directly to the repo
      - uses: EndBug/add-and-commit@v9
        with:

          # If this input is set, the action will push the commit to a new branch with this name.
          # Default: ‘’
          new_branch: swift-package-init
```

Commit directly into the `main` branch.


## Initialize Swift Package

Manually run `Swift Package Init` workflow from the `Actions` tab (select workflow and run).
    
After the workflow is successfully done you’ll have a swift package initialized in the repo root directory and committed to the `swift-package-init` branch. If the workflow fails, look into the workflow execution details for debugging.

Checkout `swift-package-init` branch. If everything looks good, merge to `main` and delete `swift-package-init` branch.


## Testing

### Another Workflow

# ADD WORKFLOW WITHOUT SCRIPT AS WELL

Add another workflow (suggested name is `run_clean_build_test_script.yml`) with the following content:

```yml
# This is a simple workflow to run clean build test script

name: Run Clean Build Test Script

# Controls when the workflow will run
on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job to call clean build test script
  run_clean_build_test_script:
    # The type of runner that the job will run on
    runs-on: macos-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
    - uses: actions/checkout@v3
    
    # Change script file permissions
    - name: Make executeable
      run: chmod +x ./.github/scripts/clean_build_test.sh
    
    - name: Run Clean Build Test Script
      run: exec ./.github/scripts/clean_build_test.sh
```

That’s right, it’s referencing `clean_build_test.sh` script that we will create on the next step.

Commit to `main` and move to the next step.

### Add Script

Using `Working Copy` app create sub-directory `scripts` in the `.gitgub` directory (I find it’s convenient to separate workflows and scrips).

Add new file `clean_build_test.sh` to `scripts` with the following contents:

```bash
#!/bin/bash

# Run Swift clean build and test

# Do not forget to make this file executable with `chmod +x the_file_name`

# `set -o pipefail` causes a pipeline (for example,
# `curl -s https://sipb.mit.edu/ | grep foo`) to produce
# a failure return code if any command errors.
# Normally, pipelines only return a failure if the last command errors.
# In combination with `set -e`, this will make your script exit
# if any command in a pipeline errors.
set -eo pipefail

swift package clean

swift build

swift test
```

Commit to `main`.

### Run Tests

On `Actions` tab select `Run Clean Build Test Script` workflow tab and run it.

Inspect logs if the workflow failed.


### Test Failing Test

Add new test function `testFailing()` to the `XCTestCase` subclass in swift test file in the Swift Package test target:

```swift
func testFailing() {
    XCTFail(“Testing failing test”)
}
```

Commit to `main` and run `Run Clean Build Test Script` workflow to see it failing. Inspecting workflow run log will show you that failing test is the reason for workflow failure.

Remove `testFailing` function. Commit and run workflow again to see passing tests.


## CI

We’ll add a check that would be triggered automatically every time a pull request into the `main` branch is opened (it highly advised to protect your significant branch(es) by enabling at least “Require a pull request before merging” flag in repo Settings/Branches/Branch protection rules).

First, add new `ci.yml` file to `.github/workflows`:

```yml
# This workflow runs when a pull request into the `main` branch is created

name: CI

# Controls when the workflow will run
on:
  # Run this workflow if pull request into branch `main` is created
  pull_request:
    types:
      - opened
    branches:
      - main

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job
  ci:
    # Calls reusable workflow Run Clean Build Test
      uses: ./.github/workflows/run_clean_build_test_script.yml
```

Note that this workflow would run when pull request is created. In order to auto run it when more commits are added or other pull request events, remove _type: - open_:

```yml
pull_request:
    types:     # remove this line
      - opened # remove this line
```


Second, add `workflow_call` (# 2) after `workflow_dispatch` (# 1) in `run_clean_build_test_script.yml`:

```yml
# Controls when the workflow will run
on:
  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch: # 1
  
  # Allows to reuse this workflow (call from workflows)
  workflow_call:     # 2

```

This would make `Run Clean Build Test Script` workflow reusable, i.e., callable from another workflow, as we do in `CI` (`ci.yml`).


Commit both changes to `main`.

Checkout new branch `feature`, add empty new file to `Sources` folder , commit to `feature` branch, make pull request into `main`.

In the `Pull requests` tab (github.com) you’ll see check(s) running for the new open pull request, at least your `CI` with clean build and test.
Merge pull request, remove `feature` branch. Remove local branch(es) other than main in `Working Copy`.


## Features and Fixes

Edit `ci.yml` - add the following after `branches: main`:

```yml
on:
  # Run this workflow if pull request into branch `main` is created
  pull_request:
    types:
      - opened
    branches:
      - main
 
  # Triggers the workflow on push events but only for the `feature` or `fix` branches
  push:
    branches: 
      - ‘feature/**’
      - ‘fix/**’
```


Now you’re good to go with development without desktop 😎.

Just follow:

- checkout `feature/featureX` or `fix/fixX` branch,
- use __TDD__ to write tests and production code,
- push to remote
- create pull requests into `main` if workflows run green.