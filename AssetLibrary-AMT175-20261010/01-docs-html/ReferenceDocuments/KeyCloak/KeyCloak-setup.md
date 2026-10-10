# KeyCloak installation and configuration

Keycloak is an open-source identity and access management solution.  It provides features for authentication, authorization, and user management in web applications and services. This document contains the steps to install and configure Keycloak for authentication instead of Azure.

## Installation

Download the latest version of Keycloak from [KeyCloak's official website](https://www.keycloak.org/downloads) and extract the contents to a directory on your machine ( e.g. C:/Tools/).

## Configuration

#### When using SSL
To run Keycloak using SSL you need to specify the certificate and private key in the keycloak config file,
which can be found here in ..\keyclaokversion\conf\keycloak.conf.

Set the following properties in the `keycloak.conf` file:

```
https-certificate-file=C:/amt/java/certs/server1.pem
https-certificate-key-file=C:/amt/java/certs/server1.key
```

### Starting Keycloak
Navigate to the Keycloak `bin` directory and start KeyCloak with the following command:
> kc.bat start-dev

#### 1. Create an account
Open a web browser, and navigate to `localhost:8080`. Create an administrator account.

#### 2. Create Realm

og in to Administration Console. Create a new realm by clicking on “Create realm” from the drop-down menu (containing master) at the top left.
Provide a Realm name (e.g., "AMTRealm") and press the `Create` button.

#### 3. Create Client
Select `Clients` from the sidebar menu and click the `Create client` button.  
Enter the following information at the 'General settings' tab:
* Client type: openID connect
* Client ID: AMT
* Name: AMT
* Description: AMT

Press `Next`. 

#### 3a. Normal setup (username password)
Leave the 'Capability config' settings as is, and just press `Next`.

#### 3b. Confidential setup (service accounts)
Client authentication: On
Service accounts roles: On

Lastly, enter the following 'Login settings':
* Root URL: http://localhost:4200
* Home URL: http://localhost:4200
* Valid redirect URIs:
  * http://localhost:4200/*
  * http://localhost:4300/*
* Web origins: + (the + sign adds all the Valid Redirect URIs defined above)

Press the `Save` button.

#### 4. Create Client scope
Select `Client scopes` from the sidebar menu and click on the `Create client scope` button.  
Enter the following settings:

* Name: audience_scope
* Description: Scope created to append correct audience to access tokens
* Type: None

Press the `Save` button.

Define a Protocol Mapper  
Go to the `Mappers` tab, press the `Configure a new mapper` button. Select `Audience` and configure the following settings:

* Name: audience mapper
* Included Client Audience: AMT
* Add to access token: On

Press the `Save` button.

Assign the Client Scope to the Client  
Select `Clients` from the sidebar menu. Select your client (AMT) and go to the `Client Scopes` tab. Click on `Add client scope` and add the scope you have created (audience_scope). Set assigned type as default.

#### 5. Confidential (service accounts)
When using confidential service accounts, e.g., for AMT Python scripts, you need to create a second client with following steps 1..4 again, but with the confidential settings on.

#### 6. Create User
Select `Users` from the sidebar menu and click on the `Add user` button.

It might be a good idea to use your Avanade e-mail address so that you could use the same roles as the domain controller (which might have been set when you have run Control Center with the domain controller settings.):

When the user is created go to the `Credentials` tab to add a password to the user.

### Update the OIDC config file in the project

Update the OIDC config file for Control Center (and smoketest if needed).

##### Control Center

Locate the OIDC config files for Control Center in the project at:
* _parent-frontend/controlcenter/angular/src/assets/oidcconfig.json_.
* _parent-frontend/controlcenter/angular/src/assets/oidcconfigkeycloak.json_.

By default, it will read the `oidcconfig.json` which is the Azure configuration. You need to rename the `oidcconfigkeycloak` to `oidcconfig` to use the KeyCloak config.

##### smoketest

Locate the OIDC config files for smoketest in the project at:
* _parent-frontend/smoketest/angular/src/assets/oidcconfig.json_.
* _parent-frontend/smoketest/angular/src/assets/oidcconfigkeycloak.json_.

Apply the same changes as for Control Center.

### Update the yaml config files

Control Center
```yaml
authentication:
  type: OIDC
  clients:
    rest:
      settings:
        issuerURL: http://localhost:8080/realms/AMTRealm
        clientID: AMT
        returnUrl: http://localhost:4200/control-center
```

smoketest
```yaml
authentication:
  type: OIDC
  clients:
    rest:
      settings:
        issuerURL: http://localhost:8080/realms/AMTRealm
        clientID: AMT
        returnUrl: http://localhost:4300/smoketest
```

When role mapping is required, please check the default config files, found here
[Default config files](https://dev.azure.com/avanade-lt-coe/AMT_Products/_git/amt-go-java?path=/wiki/AMT-Java-Wiki/AMT-Runtime-Platform-Java/Default-Config-Files.md)

## Running the Application

* Ensure Keycloak is running and you are signed in.
* Start the application and verify that the login redirects to the Keycloak login page, where Keycloak user credentials are required for authentication.

_You can find the pdf version of the documentation here:
[Keycloak_installation_and_configuration.pdf](https://avanade.sharepoint.com/sites/rdteam4/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2Frdteam4%2FShared%20Documents%2FGeneral%2FDocumentation%2FConfiguration%20Guides%2FKeycloak%5Finstallation%5Fand%5Fconfiguration%2Epdf&parent=%2Fsites%2Frdteam4%2FShared%20Documents%2FGeneral%2FDocumentation%2FConfiguration%20Guides)_

# Install Rolemapping in KeyCloak

Here are the steps to add roles to keycloak.

Log in to the admin page of keycloack

http://localhost:8080/admin/

Go to the AMTRealm

Go to clients and open your AMT client

Go to roles

Add a role, for example “test”

Open the role by clicking on it, and go to users in role

Select your user and go to the rolemapping tab

Then assign role, change the filter to assign to clients, and select the role for example “test”
