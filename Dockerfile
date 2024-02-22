FROM debian:stretch-slim

# Update the sources.list to use archived repositories
RUN echo "deb http://archive.debian.org/debian stretch main\n\
deb http://archive.debian.org/debian-security stretch/updates main" > /etc/apt/sources.list

# Disable the check for valid signatures on the archived repositories
# as the archived keys may not be up to date
RUN apt-get -o Acquire::Check-Valid-Until=false update

# Install Python 2.7, pip, OpenJDK 8, libxml2-dev, libxslt-dev, and zlib1g-dev
RUN apt-get install -y --allow-unauthenticated \
    python2.7 \
    python-pip \
    openjdk-8-jdk \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
&& apt-get clean \
# Check if the python symlink exists and if it does, check if it points to python2.7
# If it doesn't exist or it points to a different version of python, create the symlink
&& ( [ ! -e /usr/bin/python ] || [ "$(readlink -f /usr/bin/python)" != "$(which python2.7)" ] ) && ln -sf $(which python2.7) /usr/bin/python || true

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Install Jinja2 and lxml using pip
RUN pip install --trusted-host pypi.python.org Jinja2 lxml

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# The default command keeps the container running without serving the site
CMD ["tail", "-f", "/dev/null"]

# # Run generator.py when the container launches
# CMD ["python", "generator.py", "build", "--all", "--images"]

# Assuming the static site is generated in the 'generated' directory
# CMD ["sh", "-c", "cd generated && python -m SimpleHTTPServer 80"]