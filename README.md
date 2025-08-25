# Processing.py Documentation [![How are we doing?](https://travis-ci.org/jdf/processing-py-site.svg)](https://travis-ci.org/jdf/processing-py-site)

This repository contains the files and executable code used to build
[py.processing.org](http://py.processing.org), the official documentation for
[Processing.py](https://github.com/jdf/processing.py).

## Dependencies and installation

To build this project, you need to have the following software installed:

* Java (1.8+) *Note: prior to [JEP 223](https://openjdk.org/jeps/223) Java version `X` was internally specified as `1.X` (so Java 1.8+ here means Java 8+)*
* Python (2.7+, untested with Python 3)

(Both `java` and `python` should be in your path.)

You'll need to install the various Python library requirements as well. These
requirements are provided in this repository in the standard `pip`-formatted
`requirements.txt`. The
easiest way to do this is to [create and activate a Python virtual
environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/) and then
install the requirements with `pip` like so:

    pip install -r requirements.txt

(Tip: For most platforms, it's easier to install `lxml` if you upgrade `pip`
first. With your virtual environment activated, type `pip install -U pip` and
then install the packages with the command above.)

Finally, you'll need the standalone Processing.py JAR file. You can build
Processing.py from source to obtain this file, or download the pre-built JAR
for your platform using the appropriate link below:

* [Mac OS X](http://py.processing.org/processing.py-macosx.tgz)
* Windows: [64-bit](http://py.processing.org/processing.py-windows64.zip),
  [32-bit](http://py.processing.org/processing.py-windows32.zip)
* Linux: [64-bit](http://py.processing.org/processing.py-linux64.tgz)
  [32-bit](http://py.processing.org/processing.py-linux32.tgz)

Unarchive the file you downloaded and copy the two files with a `.jar`
extension into your `processing-py-site` directory.

## Overview

The `generator.py` script takes the various files in this repository, processes
them and generates a static HTML site. (You can think of `generator.py` as
being a kind of bespoke static site generator, akin to, e.g.,
[Jekyll](https://jekyllrb.com/).) Running the following command will build the
entire site:

    python generator.py build --all --images

(See below for further discussion of the command line options available
in `generator.py`.) The best way to understand how the site is generated is to
study `generator.py`'s source code, but here's the basic overview.

* The `Reference/api_en` directory contains a number of XML files. These files
  are used to generate the "Reference" section of the documentation, including
  the images, which are automatically generated from the `<code>` blocks in the
  XML files. (The order of sections in the Reference index is hard-coded in
  `generator.py`.)
* The `Tutorials` directory has a number of subdirectories, each containing a
  tutorial that appears on in the "Tutorials" section. The tutorials themselves
  are written in plain HTML. The Tutorials index page is generated using the
  `tutorials.xml` file to determine the order, and using the `tutorial.xml`
  file in each subdirectory to determine metadata.
* The `content` directory contains static files used in the site layout, such
  as stylesheets and images. The contents of this directory are simply copied
  verbatim to the generated site.
* The `templates` directory contains a number of HTML templates, written in the
  [Jinja](http://jinja.pocoo.org/docs/dev/) templating language. These are
  mostly used to produce the various index pages for the reference and
  tutorials. The XML source code for each reference item is rendered by the
  `reference_item_template.jinja` template; there's a (fairly) straightforward
  correspondence between the name of the XML tag and the variable used to
  reference the tag in the template.
* The `jython` directory contains a single script, `generate_images.py`, which
  is used to generate images from the example code in the reference items.
  (This program is executed automatically by the build process; there's no
  reason for you to run it yourself.)

On successful completion of `generator.py`, the static site ends up in the
`generated` directory.

## Building the documentation

As noted above, the `generator.py` script builds the site from the source
files in the repository. Run `python generator.py --help` for full details on
its command line options. Here's an overview:

To build all content:

    python generator.py build --all --images

To build the site without performing the image generation process:

    python generator.py build

To build only `a.xml`, `b.xml` and `c.xml` files from the reference (remove
`--images` to skip the image generation process):

    python generator.py build --images --files a.xml b.xml c.xml

To test the site in a local server:

    python generator.py test

### Building with Docker
Using Docker, you can have a complete, consistent development environment without having to manually install dependencies and set up your environment. It also helps isolate these dependencies and their data from other projects that you may have on the same computer that use different/conflicting versions, etc.

Note that this takes up a significant amount of space on your machine. Make sure you have at least 5GB free.

#### Included Files

Two files are included for Docker configuration:

- **`Dockerfile`**: Contains instructions for setting up the Docker environment.
- **`docker-compose.yml`**: Defines services for managing the application lifecycle:
  - `build`: Build the container from the included Dockerfile
  - `fetch-jar`: Automatically downloads the appropriate Processing.py JAR file for image generation.
  - `site-build`: Builds the static site without images.
  - `site-build-all`: Builds the static site including images.
  - `site-serve`: Serves the generated site using Python's built-in HTTP server on port 8080.

#### Setup Instructions

1. **Install Docker**:
   - For Mac: [Docker for Mac](https://www.docker.com/docker-mac)
   - For Windows: [Docker for Windows](https://www.docker.com/docker-windows)
   - Ensure [Docker Desktop](https://www.docker.com/products/docker-desktop/) is installed and running.
2. **Prepare the Project**:
   - Clone this repository and navigate into the project directory.
   - Build the Docker image: `docker build -t processing-py-site .`. This command creates a Docker image named `processing-py-site`, based on the `Dockerfile`.

#### Building the Static Site

- **Fetch Processing.py JAR** (if needed): 
  - Run `docker-compose run --rm fetch-jar` to automatically download the correct Processing.py JAR file for your architecture.
- **Build the Site**: 
  - Execute `docker-compose run --rm site-build-all` to build the entire site, including images. Use `docker-compose run --rm site-build` to build without images.
  - The `--rm` flag ensures the container is removed after completion.

#### Serving the Site Locally

- Start the server with `docker-compose up serve`. This serves the site on `http://localhost:8080`.
- Access the site via your web browser.

## Troubleshooting

Here are a few common and/or possible scenarios you might run into...

### Error: Could not find or load main class org.python.util.jython

You're missing the Jython code necessary to execute the image generation
script. Ensure that you've copied (or linked) `processing-py.jar` from the
standalone Processing.py distribution into your `processing-py-site` directory.

### NullPointerException - foo is probably dynamic-mode; fix that, please.

The image generation process only creates images for "static-mode" sketches,
i.e., sketches that don't have a `draw()` function and therefore can't be
animated or interactive. To fix this, rewrite the code example so it isn't
interactive, or add `<notest /><noimage />` as children of the `<example>` tag
in the XML to suppress image generation for that item.

### Could not initialize class com.jogamp.newt.NewtFactory

I've seen this error when trying to build on Linux without 
`processing-py-natives-linux-amd64.jar` in the `processing-py-site` directory.
Ensure this file (or the file appropriate for your platform) is present and try
again.

### I can't run the image generation process in a headless environment

If you're running on a Linux machine without a connected display (say, an EC2
box), you'll need to install `xvfb` using the package manager for your
operating system. Then run the build script like so:

    xvfb-run python generator.py build --images

## Reporting Issues

Before opening a new issue, please review existing [issues](issues).

Issues should include as many details as possible, including URLs and/or
excerpts from the related material, and a description of what is missing/wrong
or could be improved, and if possible how.

## Contributing:

see [CONTRIBUTING.md](CONTRIBUTING.md) 
