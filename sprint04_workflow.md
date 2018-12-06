# Workflow in Sprint 4 (Import Royal Mail Data in Every Quarter)
### This instructions assume that you will execute the commands in Ubuntu/Mint. 

## Setup a PostgresDB (if needed)
### We will store our imported royal mail data on this server
   1. Login to the remote server 
   2. Run commands below sequentially. Need adminstrative privilege to run commands.
      This commands are tested for Ubuntu 16.04. See corresponding commands if your (OS)distribution is a different one.
      * sudo apt-get update && sudo apt-get upgrade
      * sudo apt-get install postgresql postgresql-contrib (iinstall postgres)
   3. A linux user _postgres_ is created. This user is default postgres system user.
   4. Change linux password for this user(Linux user) by running command **sudo passwd postgres**
   5. Switch over to the postgres account on your server by typing:  **su - postgres**
   6. Change password for database user **postgres** by command **psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'your_new_password';** 
   7. Log into database by **psql** command if already not logged into postgres.
   8. Create a new database named **postcode_ng** by command **CREATE DATABASE postcode_ng;**
   9. Create a new database named **postcode_user** by command **CREATE USER postcode_user WITH ENCRYPTED PASSWORD 'replace_your_password_here';**
  10. Granting privileges for new user **postcode_user**on **postcode_ng** database by command **GRANT ALL PRIVILEGES ON DATABASE postcode\_ng TO postcode\_user;**
  11. Exit from postgres by issuing command **\q**
  12. Now You can Logout from server
### References:
* https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04
* http://linode.com/docs/databases/postgresql/how-to-install-postgresql-on-ubuntu-16-04/
* https://medium.com/coding-blocks/creating-user-database-and-adding-access-on-postgresql-8bfcd2f4a91e

## Download Royal Mail Data
1. Royal Mail Provides a FTP Server link of Postcode data and a user id and password for  downloading exe file contained postcode data.
2. user id and password will be provided by responsible person of the company.
3. There may exist multiple exe file based on quarter under a archive path. 
	![FTP server](/screenshots/Sprint_4_ftp_archive.png)
4. Download the latest exe file.
5. Install **wine** in your machine if not installed to extract the csv file from .exe file. Wine let you run windows executables on Linux
   #### Commands to install wine in Ubuntu
   * wget -nc https://dl.winehq.org/wine-builds/Release.key
   * sudo apt-key add Release.key
   * sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
   * sudo apt-get update
   * sudo apt-get install --install-recommends winehq-stable
6. A key will be needed to extract the CSV files. It will be provided by responsible person of the company
7. You will need to provide a location of your machine to extract the File
8. Download _CSV PAF_ File. This file contains our raw data.
### References:
* https://wiki.winehq.org/Ubuntu

## Update Remote Database from CSV File
To update remote database the importData.sh file is needed
1. Download the **importData.sh** file from specified location or resquest the responsible person for the file.
2. You may need permission for ruuning the file.Change the file permission if needed by issuing coomand from terminal **chmod 755 absolute_path_of_your_file**
3. Run the file from terminal by command **sh your_sh_file's_absolute_path**
4. You will be asked for database connection informations and csv file location. If everythig is correct data will be updated correctly.
5. In case of failure  re run the .sh file with correct information.
