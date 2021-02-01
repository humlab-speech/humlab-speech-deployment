# Humlab Speech Cluster

This is a cluster of docker containers running the Humlab Speech services.

Included services:
* Edge router (Apache + Shibboleth) - Serves the main portal page and handles authentication as well as integration towards Gitlab

* Gitlab

* Keycloak - Acts as an identity provider for authentication.

* PostgreSQL - Dependency of Keycloak.

* RStudio router - Spawns and manages RStudio session containers on request by edge router.

* (non-functional) EMU-webApp + server


## INSTALLATION

### Prerequisites
A Linux environment with a somewhat recent version of Docker + Docker Compose. WSL2 on Windows should work.

### Steps

* Move .env-example to .env and fill it out with appropriate information.
* Run `install.sh`. This will grab the latest versions of The WebClient and WebApi and install these. It will also generate self-signed TLS-certificates.
* RStudio router setup
  * Go to the `rstudio-router directory.
  * Run `npm install`
  * Go back to root directory `cd ..`
* Run `docker-compose up -d`
* Gitlab setup
  * Go to gitlab.localtest.me, gitlab will take a couple of minutes to boot but then you should be greeted with a password dialog, enter a new root password here.
  * Sign-in to Gitlab with the root account. 
  * Go to `settings` in your avatar menu.
  * Go to `Access Tokens`.
  * Create an access token with `api` access. Name doesn't matter. Enter this access token into your .env 
* Keycloak setup
  * Go to idp.localtest.me
  * Sign-in with the keycloak admin credentials you specified in .env
  * Create a realm called `hird`
  * Go to `Clients`, create a client with Client ID `https://localtest.me` and Client Protocol `SAML`
  * Edit the newly created client, set `Client Signature Required: OFF`
  * Go to `Mappers` tab. Add built-in attribute mappers for X500 email, X500 surname, and X500 givenName. Then edit these to set "SAML Attribute NameFormat" as "URI Reference"
  * Restart the edge-router to let it read in the new metadata from Keycloak, with `docker-compose restart edge-router`

Everything should now be setup for using the system with Keycloak as the local identity provider. You may create a normal user account in Keycloak to then use for sign-in at http://localtest.me

## Keycloak extra
For setting up Keycloak as an IdP against Gitlab.

1. Add a new client in Keycloak with Client ID `https://gitlab.localtest.me`
1. Disable `Client Signature Required`
1. Set `Root URL` to `https://gitlab.localtest.me`
1. Add a post in `Valid Redirect URIs` and set it to `/*`
1. Set `Base URL` to `/`
1. Set `Master SAML Processing URL` to `https://gitlab.localtest.me/users/auth/saml/callback` (this step might not be required)
1. Go to `Mappers` tab. Add the 3 Builtin X500 attributes.
1. Go to `https://idp.localtest.me/auth/realms/hird/protocol/saml/descriptor` and copy the certificate. Generate a SHA-1 fingerprint from this certificate.
1. Update `mounts/gitlab/config/gitlab.rb` with fingerprint in SAML/Keycloak-section.

## CAVEATS ON REDHAT

* Not using latest version of Docker since DNF would not install the latest containerd.io because of how module-streams are configured.

* docker-compose is installed as a static/manually pulled binary, and thus won't auto-update, it was installed using this command:
  `sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`

* Needed to do this (on RH) to get container-to-container networking to work:
  `sudo firewall-cmd --zone=public --add-masquerade --permanent`

## OPTIONAL

Select an identity provider by uncommenting/commenting out the approrpriate sections in docker-compose.yml. Recommend using keycloak for running locally since local users can be created in keycloak. SAMLtest is also an alternative.
SWAMID will not work for running locally since you can't have your local address registered as a SP with SWAMID.


## TROUBLESHOOTING

* If you get a message about `Unknown or Unusable Identity Provider`, try restarting the edge-router. This is probably because Keycloak wasn't ready when the edge-router went up, preventing it from reading metadata from Keycloak.

* For errors about proxy timeouts when visiting gitlab, just wait a few minutes, gitlab takes a while to start.

* You might run into problems if running the project under /mnt/c/<etc> in WSL2, recommend running it somwhere under ~/
