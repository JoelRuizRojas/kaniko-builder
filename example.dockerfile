# Use the official PHP Apache base image
FROM php:8.3.0-apache

# Set working directory to the Apache document root
WORKDIR /var/www/html

# Add/copy dependencies
# ...
#
# Expose port 80 for web traffic
EXPOSE 80

# Start the Apache web server
CMD ["apache2-foreground"]

