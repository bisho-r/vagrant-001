# Introduction

Think of Nginx as a High-Speed Traffic Controller. It stands at the entrance of your server (Port 80) and decides where every "car" (visitor) should go based on their "license plate" (Domain Name).

## The Nginx Map
On Linux, Nginx lives in `/etc/nginx`.


**Path:** `/etc/nginx/nginx.conf`   
**Purpose:** The Global Settings. It controls high-level stuff like how many "workers" are active and where the logs are saved.


**Path:** `/etc/nginx/sites-available/`
**Purpose** The Warehouse. This is where you write the configuration files for your websites. Files here are not live.

**Path:** `/etc/nginx/sites-enabled/`
**Purpose:** The Showroom. Only files linked here are actually "active" and being used by Nginx.

**Path:** `/var/www/html/`
**Purpose:** The Storage Room. This is usually where the actual .html or .php files are kept.

## How it Works: The "Listen" Logic
When a request hits your server, Nginx looks at the Server Block. A server block is a set of instructions that tells Nginx: "If someone comes in on Port X looking for Domain Y, send them to Folder Z."

### Example of a basic Server Block:
```bash
server {
    listen 80;                 # Listen on Port 80 (Standard Web Port)
    server_name example.com;   # The "License Plate" (Domain Name)

    root /var/www/html;        # Where the files live
    index index.html;          # The first file to show
}
```

```bash
server {
    listen 443;                 # Listen on Port 80 (Standard Web Port)
    server_name antbyteslabs.com;   # The "License Plate" (Domain Name)

    root /var/www/antbyte;        # Where the files live
    index index.php;          # The first file to show
}
```

## How Domain Names Route Traffic
How does Nginx know the difference between `site-a.com` and `site-b.com` if they both point to the same IP?

**The Request Header:** When a browser asks for a website, it sends a hidden piece of data called the Host Header (e.g., Host: binaya.com).

**The Matching Game:** Nginx reads all the files in `sites-enabled`. It looks for the `server_name` that matches the Host Header.

**The Default Fallback:** If Nginx can't find a match, it sends the user to the file marked as default_server.

## How to Update & Apply Changes
In DevOps, we never just "restart" a server blindly. We follow a 3-step safety process:
1. Edit the file: `sudo nano /etc/nginx/sites-available/default`
2. Test for Syntax Errors: `sudo nginx -t`
*This is crucial! If you have a typo, Nginx will tell you exactly which line is broken before the server crashes.*
3. Reload the Service: `sudo systemctl reload nginx`
*reload is better than restart because it doesn't drop current visitors; it just swaps the configuration in the background.*

## Ensuring everything listens on Port 80
To make sure Nginx is catching all web traffic, every server block must have: `listen 80;` or `listen [::]:80;` (for IPv6).

If your site isn't loading, check these three things:

1. Is Nginx running? (`sudo systemctl status nginx`)
2. Is Port 80 open in the firewall? (`sudo ufw allow 'Nginx Full'`)
3. Is the file linked? (Check if the file exists in `/etc/nginx/sites-enabled/`)

## Setting up a new nginx config file for a site. 

Step 1: Create the Website Folder and Content
First, we need a place where the files for `example-site.com` will live.

1. Create a directory
`sudo mkdir -p /var/www/example-site.com`

2. Create a simple index file and update content. 
`sudo nano /var/www/example-site.com/index.html`

Step 2: Create the Nginx Server Block
Now we tell Nginx: "If you hear someone asking for `example-site.com`, look in the folder we just created."

1. Create a new config file:
`sudo nano /etc/nginx/sites-available/example-site.conf`

2. Paste this configuration:
```bash
server {
    listen 80;
    server_name example-site.com;

    root /var/www/example-site.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Step 3: Enable the Configuration
In Nginx, files in `sites-available` are just "blueprints." To make them live, we must link them to `sites-enabled`.

1. Create the Symbolic Link:
`sudo ln -s /etc/nginx/sites-available/example-site.com /etc/nginx/sites-enabled/`

2. Test and Reload Nginx:
```bash
sudo nginx -t
sudo systemctl reload nginx
```


Step 4: Map the Fake Domain name
**In VM**
**Run:** `sudo vim /etc/hosts`
Add this line at the bottom: `127.0.0.1 example-site.com`

**In Host machine**
**Run:** sudo vim /etc/hosts
Add the Vagrant Private IP: `192.168.33.10 example-site.com`


## Forwarding the request to other ports

```bash
server {
    listen 80;
    server_name example-site; 

    location / {
        # This is the magic line
        proxy_pass http://127.0.0.1:5000;

        # These headers pass the user's real info to the backend app
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

When Nginx acts as a Reverse Proxy, it acts like a "middleman." If we don't use these headers, our backend app (Node.js/Python) will think every single request is coming from Nginx itself (127.0.0.1) rather than the actual user in the outside world.