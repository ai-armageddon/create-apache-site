# create-apache-site
Create-apache-site is an easy-to-use globally installed NPM package for quickk setup of new Apache websites.

Developed and tested on Ubuntu 18.04, it can create virtual host configuration files and public static file folders with the option of adding SSL via Certbot.

You may also customize the default HTML template located in the /assets/static folder where the package is installed.

# Installation
The create-apache-site package can be installed globally via NPM:

`npm install -g create-apache-site`

# Usage
To create a new virtual host, use the following command:

`create-apache-site -d example.com [--ssl]`

The -d or --domain option specifies the domain name for the new virtual host. The --ssl option can be used to obtain an SSL certificate for the domain using Certbot. Use -h or --help for a list of all available options.

# Dependencies
- Apache (tested on 2.4.x)
- Certbot (optional for SSL)

# Contributing
If you encounter any issues or have suggestions for improvements, please submit an issue or pull request on the GitHub repository.

# License
This package is licensed under the MIT License. See the LICENSE file for details.