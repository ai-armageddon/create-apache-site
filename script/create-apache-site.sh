#!/bin/bash

# create the directory structure
create_directory() {
    domain="$1"
    directory="/var/www/$domain/public_html"

    mkdir -p "$directory"

    # copy HTML files to site directories
    cp -R ./assets/static/. "$directory"

    # Specify output file
    output_file="index.html"

    # Create a temporary script file with variable updates
    temp_script="$directory/temp_script.sh"
    echo "#!/bin/bash" > "$temp_script"
    echo "sed -i 's/{{DOMAIN_NAME}}/$domain/g' $output_file" >> "$temp_script"
    chmod +x "$temp_script"

    # Execute the temporary script within the directory
    (cd "$directory" && ./temp_script.sh)

    # Delete the temporary script file
    rm "$temp_script"
}

# create Apache config file
create_apache_config() {
    domain=$1
    template_file="./assets/server/template.conf"
    config_file="/etc/apache2/sites-available/$domain.conf"

    # replace variables in the template file
    cp "$template_file" "$config_file"
    sed -i "s/{{DOMAIN_NAME}}/$domain/g" "$config_file"

    echo "Created Apache configuration file: $config_file"
}

# enable website
enable_site() {
    domain=$1
    config_file="/etc/apache2/sites-available/$domain.conf"
    
    a2ensite "$domain.conf"

    echo "Apache website enabled"

    # reload, restart Apache
    systemctl reload apache2
    systemctl restart apache2

    # handle errors if Apache fails to reload or restart
    if [[ $? -ne 0 ]]; then
        echo "Error: failed to reload or restart Apache."
        exit 1
    fi
}

# obtain SSL certs with Certbot
run_certbot() {
    domain="$1"

    certbot --apache -d "$domain" -d "www.$domain" --redirect

    echo "Obtained SSL certificates for domain: $domain"

    if [[ $? -ne 0 ]]; then
        echo "Error: failed to obtain SSL certificates."
        exit 1
    fi
}

# print usage
print_usage() {
    echo "Usage: $0 -d|--domain <domain_name> [--no-ssl] [-h|--help]"
}

# parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--domain)
            domain_name="$2"
            shift 2
            ;;
        --ssl)
            ssl=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Invalid option: $1" >&2
            print_usage
            exit 1
            ;;
    esac
done

# set default values if not provided
if [[ -z "$domain_name" ]]; then
    echo "Error: you must provide a domain name as a parameter using the -d or --domain option."
    print_usage
    exit 1
fi

echo "Domain: $domain_name"

# call the functions
create_directory "$domain_name"
create_apache_config "$domain_name"
enable_site "$domain_name"
    
# Run certbot if --ssl flag is passed
if [[ "$ssl" == true ]]; then
    echo "SSL: enabled"
    run_certbot "$domain_name"
else
    echo "SSL: none"
fi

echo "Setup complete for domain: $domain_name"