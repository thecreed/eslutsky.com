---
title: "Auto Deploy Gh Pages With Gh Action"
date: 2023-06-20T12:32:20+03:00
draft: true

categories: [ci,devops]
tags: [ghaction]
toc: false
author: "eslutsky"
---
# Auto-deploying built products to gh-pages with GitHub Actions

This is a set up for projects which want to check in only their source files, but have their gh-pages branch automatically updated with some compiled output every time they push.

A file below this one contains the steps for doing this with Travis CI. However, these days I recommend GitHub Actions, for the following reasons:

* It is much easier and requires less steps, because you are already authenticated with GitHub, so you don't need to share secret keys across services like you do when coordinate Travis CI and GitHub.
* It is free, with no [quotas](https://blog.travis-ci.com/2020-11-02-travis-ci-new-billing).
* Anecdotally, builds are much faster with GitHub Actions than with Travis CI, especially in terms of time spent waiting for a builder.

## Set up a build script

Set up your repository with a build script. This could be a checked-in `build.sh`, or a `make` command (I usually use `make ci`), or whatever.

Ensure that the build script outputs all the results to an `out/` directory. You'll probably want to update `.gitignore` to include `out/`.

## The build file

Add this file to `.github/workflows/build.yml`:

```yaml
name: Build
on:
  pull_request:
    branches:
    - master
  push:
    branches:
    - master
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build
      run: make ci
    - name: Deploy
      if: ${{ github.event_name == 'push' && github.ref == 'refs/heads/master' }}
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./out
```

Here, where it says `run: make ci`, replace it with whatever build script you have, e.g. `run: bash ./build.sh`.

Similarly, if you are using a different branch name than `master`, e.g. if you are using `main`, then update the three locations which reference `master`.

## Security considerations

This relies on third-party code in [`peaceiris/actions-gh-pages`](https://github.com/peaceiris/actions-gh-pages); this code is not maintained by GitHub. In theory, the @peaceiris user could update their action code to extract your `GITHUB_TOKEN`, and update their `v3` tag to point to this new malicious commit. [Read more about this in GitHub's docs](https://docs.github.com/en/free-pro-team@latest/actions/learn-github-actions/security-hardening-for-github-actions#using-third-party-actions)

The best security against this, if you are concerned, is to pin to a specific commit, e.g. by replacing `peaceiris/actions-gh-pages@v3` with `peaceiris/actions-gh-pages@bbdfb200618d235585ad98e965f4aafc39b4c501` (which is the commit for what is currently tagged as `v3.7.3`). But, this of course means you'll fail to get updates, perhaps even security updates. So on balance, I'm currently recommending using the `v3` tag. Your preferences may vary.

## Example project

A recent project I maintain which uses this approach is [WICG/import-maps](https://github.com/WICG/import-maps). Some features if it you may enjoy perusing:

- The [`Makefile`](https://github.com/WICG/import-maps/blob/master/Makefile), especially if you're interested in building specifications with [Bikeshed](https://tabatkins.github.io/bikeshed/)
- The [`.github/workflows/test.yml`](https://github.com/WICG/import-maps/blob/master/.github/workflows/test.yml) file, which shows how to run other build actions alongside the GitHub pages build action in `build.yml`.