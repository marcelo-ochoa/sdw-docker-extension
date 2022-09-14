# Docker Extension

SQLDeveloper Web Extension for Docker Desktop

## Manual Installation

Until this extension is ready at Docker Extension Hub you can install just by executing:

```bash
$ docker extension install mochoa/sdw-docker-extension:22.2.1
Extensions can install binaries, invoke commands and access files on your machine. 
Are you sure you want to continue? [y/N] y
Installing new extension "mochoa/sdw-docker-extension:22.2.1"
Installing service in Desktop VM...
Setting additional compose attributes
VM service started
Installing Desktop extension UI for tab "SQLDeveloper Web"...
Extension UI tab "SQLDeveloper Web" added.
Extension "Oracle SQLDeveloper Web client tool" installed successfully
```

**Note**: Docker Extension CLI is required to execute above command, follow the instructions at [Extension SDK (Beta) -> Prerequisites](https://docs.docker.com/desktop/extensions-sdk/#prerequisites) page for instructions on how to add it.

## Using SQLDeveloper Web Docker Extension

Once the extension is installed a new extension is listed at the pane Extension (Beta) of Docker Desktop.

By clicking at SQLDeveloper Web icon the extension main window will display a progress bar for a few second and finally SQLDeveloper Web is launched.

![Progress bar indicator](docs/images/screenshot0.png?raw=true)

SQLDeveloper Web is not logged into the Oracle RDBMS you should log using this page, put ADMIN/Oracle_2022 for OracleXE local installation.

![Connect sample](docs/images/screenshot1.png?raw=true)

Note that this exatension is pre-configured to connect to an OracleXE running as Docker Extension.

It means OracleXE started using OracleXE Docker Desktop Extension means for a SQLDeveloper Web pool.xml:

- Hostname/address: host.docker.internal
- Port: 1521
- PDB: xepdb1
- Username: ORDS_PUBLIC_USER
- Password: Oracle_2022

## Creating ADMIN SQLDeveloper Web user

Once you got above image on Docker Desktop page you can create an ADMIN user to use SQLDeveloper Web just open SQLcl extension or log into OracleXE console and run:

```sql
SQL> create user admin identified by Oracle_2022
     default tablespace sysaux
     temporary tablespace temp;
SQL> grant connect,dba to ADMIN;
SQL> grant execute on dbms_soda_admin to admin;
SQL> BEGIN
        ords_admin.enable_schema(
        p_enabled => TRUE,
        p_schema => 'ADMIN',
        p_url_mapping_type => 'BASE_PATH',
        p_url_mapping_pattern => 'admin',
        p_auto_rest_auth => TRUE
      );
      commit;
    END;
/
```

## Enable scott user to use SQLDeveloper Web

If you want to enable scott user or any other database user to use SQLDeveloper Web tool just connect as ADMIN/Oracle_2022 and execute:

```sql
BEGIN
  ords_admin.enable_schema(
   p_enabled => TRUE,
   p_schema => 'SCOTT',
   p_url_mapping_type => 'BASE_PATH',
   p_url_mapping_pattern => 'scott',
   p_auto_rest_auth => TRUE
  );
  commit;
END;
```

## Uninstall

To uninstall the extension just execute:

```bash
$ docker extension uninstall mochoa/sdw-docker-extension:22.2.1
Extension "Oracle SQLDeveloper Web client tool" uninstalled successfully
```

## Source Code

As usual the code of this extension is at [GitHub](https://github.com/marcelo-ochoa/sdw-docker-extension), feel free to suggest changes and make contributions, note that I am a beginner developer of React and TypeScript so contributions to make this UI better are welcome.
