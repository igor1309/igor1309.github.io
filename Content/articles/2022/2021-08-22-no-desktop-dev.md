---
2022-08-22 10:10
description: Swift development without desktop
tags: Swift Package, CLI, GitHub, Working Copy
---
# ADD TO EACH STEP WHERE IS MAKES SENSE: CHECKING OUT TO THE NEW BRACH AT THE BEGGING AND MERGING IN THE END

# Desktop-less Dev

## New Repo

Create new GitHub repo using GitHub website (mobile version works ok).
    
Enable “create `.gitignore`” option by selecting `Swift`.
    
## New Workflow

Add new workflow (suggested name is `swift-package-init.yml`) with the following content:

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

## Initialize Swift Package

Manually run `Swift Package Init` workflow from the `Actions` tab.
    
After workflow is successfully done you’ll have a swift package initialized in the repo root directory. If workflow fails, look into workflow execution details for debugging.

## Testing

### Another Workflow

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
    
    # Change script file permissions. Need to run just once 
    - name: Make executeable
      run: chmod +x ./.github/scripts/clean_build_test.sh
    
    - name: Run Clean Build Test Script
      run: exec ./.github/scripts/clean_build_test.sh
```

That’s right, it’s referencing `clean_build_test.sh` script that we will create on the next step.

### Add Script

Create sub-directory `scripts` in the `.gitgub` directory (I find it’s convenient to separate workflows and scrips).

Add new file `clean_build_test.sh` with the following contents:

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

### Run Tests

Select `Run Clean Build Test Script` workflow on `Actions` tab and run it.

### Test Failing Test
# CHECK OUT 

Change the content of the boilerplate function `testExample()` in the test target on your Swift Package to

```swift
XCTFail(“Testing failing test”)
```

Commit and run `Run Clean Build Test Script` workflow. You’ll see it failing. Inspecting workflow run log will show you that failing test is the reason for workflow failure.

# DELETE BRANCH

