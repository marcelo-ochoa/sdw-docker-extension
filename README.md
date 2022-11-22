# SQLDeveloper Web Docker Extension

SQLDeveloper Web Extension for Docker Desktop

## Manual Installation

Until this extension is ready at Docker Extension Hub you can install just by executing:

```bash
$ docker extension install mochoa/sdw-docker-extension:22.3.3
Extensions can install binaries, invoke commands and access files on your machine. 
Are you sure you want to continue? [y/N] y
Installing new extension "mochoa/sdw-docker-extension:22.3.3"
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

Note that this extension is pre-configured to connect to an OracleXE running as Docker Extension.

It means OracleXE started using OracleXE Docker Desktop Extension means for a SQLDeveloper Web pool.xml:

- Hostname/address: host.docker.internal
- Port: 1521
- PDB: xepdb1
- Username: ORDS_PUBLIC_USER
- Password: Oracle_2022

## Creating ADMIN SQLDeveloper Web user

Once you got above image on Docker Desktop page you can create an ADMIN user to use SQLDeveloper Web just open SQLcl extension or log into OracleXE console and run:

```sql
create user admin identified by Oracle_2022
       default tablespace sysaux
       temporary tablespace temp;
grant connect,dba to ADMIN;
grant execute on dbms_soda_admin to admin;
BEGIN
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
GRANT SODA_APP,CREATE VIEW to scott;
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
/
```

### Sample upload using SODA interface

You can load this sample purchase-order data set into a collection purchaseorder on your Autonomous Database with SODA for REST, using these curl commands:

```bash
curl -X GET "https://raw.githubusercontent.com/oracle/db-sample-schemas/master/order_entry/POList.json" -o POList.json

curl -X PUT -u 'scott:tiger' \
"http://localhost:9891/ords/scott/soda/latest/purchaseorder"

curl -X POST -u 'scott:tiger' -H 'Content-type: application/json' -d @POList.json \
"http://localhost:9891/ords/scott/soda/latest/purchaseorder?action=insert"
```

You can then use this purchase-order data to try out examples in [Oracle Database JSON Developer’s Guide](https://docs.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/autonomous-database/adbsa&id=ADJSN).

For example, the following query selects both the id of a JSON document and values from the JSON purchase-order collection stored in column json_document of table purchaseorder. The values selected are from fields PONumber, Reference, and Requestor of JSON column json_document, which are projected from the document as virtual columns (see [SQL NESTED Clause Instead of JSON_TABLE](https://docs.oracle.com/pls/topic/lookup?ctx=en/cloud/paas/autonomous-database/adbsa&id=ADJSN-GUID-D870AAFF-58B0-4162-AC11-4DDC74B608A5) for more information).

```sql
SELECT id, t.*
  FROM purchaseorder
    NESTED json_document COLUMNS(PONumber, Reference, Requestor) t;
```

## Enable MongoDB support

If you want to enable MongDB compatible API suport for Oracle RDBMS you can execute this commands:

```bash
docker exec mochoa_sdw-docker-extension-desktop-extension-service /home/sdw/cleanup.sh
docker exec mochoa_sdw-docker-extension-desktop-extension-service mkdir -p /home/sdw/mongodb/
docker restart mochoa_sdw-docker-extension-desktop-extension-service
```

And thats all, just close your extension by switching to conatniers pane for example, and click again at SQLDeveloper Web Icon.

## Connect SQLDeveloper Web to Autonomos DB

Starting with 22.3.0 release there is a quick setup for using SQLDeveloper connected to your autonomos DB, here the instructions to connect using the extension.
Note: /home/sdw/adb.pwd includes at the first line your ADMIN Adb password, next two lines must have a new random strong password used for ORDS_PUBLIC_USER2 schema.

```bash
docker cp /home/mochoa/Downloads/Wallet_DBparquet.zip mochoa_sdw-docker-extension-desktop-extension-service:/home/sdw/Wallet.zip
docker exec -ti mochoa_sdw-docker-extension-desktop-extension-service bash
bash-5.1# vi /home/sdw/adb.pwd
bash-5.1# cat /home/sdw/adb.pwd
bash-5.1# /home/sdw/cleanup.sh
bash-5.1# mv /home/sdw/sdw.sh /home/sdw/sdw.sh.old
bash-5.1# cp /home/sdw/adb.sh /home/sdw/sdw.sh
bash-5.1# exit
docker restart mochoa_sdw-docker-extension-desktop-extension-service
```

## Uninstall

To uninstall the extension just execute:

```bash
$ docker extension uninstall mochoa/sdw-docker-extension:22.3.3
Extension "Oracle SQLDeveloper Web client tool" uninstalled successfully
```

## Source Code

As usual the code of this extension is at [GitHub](https://github.com/marcelo-ochoa/sdw-docker-extension), feel free to suggest changes and make contributions, note that I am a beginner developer of React and TypeScript so contributions to make this UI better are welcome.
