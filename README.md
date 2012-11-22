ASBO
====

These docs are still largely TODO.

Asbo is a package-based build- and dependency-management system for projects.


Getting started
---------------

Asbo is not currently on rubyforge.
To install, you'll first need [ruby 1.9](http://rubyinstaller.org/downloads/).
Then clone (or [download](https://github.com/canton7/asbo/archive/master.zip)) this repo, cd to it, and run `rake install`.


sources.yml
-----------

### Introduction

This file lives in .asbo/sources.yml, and tells Asbo where to find packages.

Package fetching is handled by a particular backend, which knows how to talk to e.g. the local filesystem, or teamcity, etc.
You configure the backend to fetch a specific package of a specific version.

For example, the `file` backend has a rather simple config:

```yaml
release:
  driver: file
  path: path/to/repo/$project-$version
```

Here you've said that, when fetching release packages, Asbo should use the 'file' driver.
`path` is a key specific to the file driver, and tells it where to find the package.

`$project` and `$version` are variables (recognisable by their `$` prefix).
These two are defined by the `file` driver, but you can also define your own!
You can additionally override them on a per-package basis.

### Release and latest

You must define a `release` section, which defines the default driver used when fetching packages.
You can also define a `latest` section, which is used when fetching the latest release.
If you don't specify one, then the `release` driver is used, with `$version` set to 'release'.

The `latest` section selectively overrides the `release` one, so the following is valid config:

```yaml
release:
  driver: file
  path: path/to/repo/$project-$version

latest:
  path: path/to/repo/latest/$project
```

### Variables

Variables consist of a `$` followed by letters, numbers, and underscores (the first character must be a letter).
Some variables are defined by the driver, but you can define your own.

For example:

```yaml
$base: path/to/repo

release:
  driver: file
  path: $base/$project-$version

latest:
  path: $base/latest/$project
```

And you can override them on a per-project basis

```yaml
release:
  driver: file
  path: $base/$project_id

project_1:
  # Out of our control. We just provide a mapping
  $project_id: 4

project_2:
  $project_id: 18
```

### Drivers

There are currently two drivers defined, and the option to add more as time progresses.

Each driver requires a number of configuration keys, but also defines a number of variables you'll probably need to use when specifying those keys.
These are listed below.

#### file

The file driver is used when fetching a package off the local filesystem.
This is very used when testing, but could also form the basis of a network-share-based repo, for example.

##### Required keys:
 - `path`: This defines the place the file driver should look for a package

##### Defined variables
 - `$package`: The name of the package
 - `$version`: The version of the package  

#### teamcity

The teamcity driver can fetch packages off a TeamCity server.
It's currently work-in-development, and may only be partially finished, but details TODO.

##### Required keys:
 - `url`: The base url to use, e.g. 'http://my.teamcity.domain:8111'
 - `project`: The project to be used
 - `username`: The username to use to auth. GuestLogin is not currently supported
 - `password`: The password to use to auth. GuestLogin is not currently supported

##### Optional keys:
 - `package`: The TeamCity package name used. Defaults to `$package`.

##### Defined variables
 - `$package`: The name of the package
 - `$version`: The version of the package

 The teamcity backend currently does not support 'latest' builds.
 It assumes that the build name corresponds exactly to the version specified in `buildfile.yml`, and that the artifacts are packaged in a zip file called `<package>.zip`. 
 


buildfile.yml
-------------

This file lives in the root of each project, and defines its names and dependencies.

A sample file:

```yaml
package: project_1

dependencies:
  - project_2:Release:0.0.1
  - project_3:Debug:latest
  - project_4:source
```

The package key defines the name of the project, and the dependencies consist of a list of `<package>:<build-config>:<version>` triplets.
The build config may be ommitted, in which case the current build config is used.

'source' dependencies are not retrieved from the repo, and must instead be built locally.
This allows the developer to use a bleeding-edge version of a package.

