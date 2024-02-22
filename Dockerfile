FROM debian:stretch-slim

# Update the sources.list to use archived repositories
RUN echo "deb http://archive.debian.org/debian stretch main\n\
deb http://archive.debian.org/debian-security stretch/updates main" > /etc/apt/sources.list

# Disable the check for valid signatures on the archived repositories
# as the archived keys may not be up to date
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y --allow-unauthenticated \
    wget \
    tar \
    python2.7 \
    python-pip \
    openjdk-8-jdk \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
&& apt-get clean

# Create a symbolic link for python if it doesn't exist or points to a different version
RUN if [ ! -e /usr/bin/python ] || [ "$(readlink -f /usr/bin/python)" != "$(which python2.7)" ]; then ln -sf $(which python2.7) /usr/bin/python; fi

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy only the requirements.txt initially to leverage Docker cache
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt

# Copy the rest of your application code
COPY . .

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