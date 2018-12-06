#!/bin/sh
########################################################
echo "Enter hostname:"
read host_name
export host_name
echo "Enter Database name:"
read database
export database
echo "Enter Dabase user name:"
read db_user
export db_user
echo "Enter password for database user:"
#read db_passwo
db_password=$(systemd-ask-password password:)
export db_password
echo "Enter Port number:"
read port
if [ "$port" ] ; then
   	export port
else
	export port=5432
fi 
export port
echo "Enter Absolute path of your 'CSV PAF.csv' file:"
read csv_location
export csv_location
echo "*******Starting Execution of sql commands*********"
PGPASSWORD=$db_password psql -h $host_name -U $db_user -d $database -p $port<< EOF
/*Before populating table with data from csv file we need to ensure compatibility of cilent and sever character encoding, Change client encoding*/
set client_encoding = latin1;

/* Droping temp_address related data if exists from previous failure*/
DROP INDEX IF EXISTS temp_postcode_index;
DROP TABLE IF EXISTS temp_address;
DROP SEQUENCE IF EXISTS temp_address_id;

/*At first create sequence for table temp address*/
CREATE SEQUENCE "temp_address_id" INCREMENT 1 MINVALUE 1 START 1 CACHE 1;

/*Then create table with sequence*/
CREATE TABLE temp_address (ID BIGINT PRIMARY KEY NOT NULL DEFAULT nextval('"temp_address_id"'),
	 Postcode VARCHAR(8) NOT NULL,
	 Post_Town VARCHAR(30) NOT NULL,
	 Dependent_Locality VARCHAR(35) NULL,
	 Double_Dependent_Locality VARCHAR(35) NULL,
	 Thoroughfare_and_Descriptor VARCHAR(80) NULL,
	 Dependent_Thoroughfare_and_Descriptor VARCHAR(80) NULL,
	 Building_Number VARCHAR(4) NULL,
	 Building_Name VARCHAR(50) NULL,
	 Sub_Building_Name VARCHAR(30) NULL,
	 PO_Box VARCHAR(6) NULL,
	 Department_Name VARCHAR(60) NULL,
	 Organisation_Name VARCHAR(60) NULL,
	 UDPRN INTEGER  NOT NULL,
	 Postcode_Type VARCHAR(1) NULL,
	 SU_Organisation_Indicator VARCHAR(1) NULL,
	 Delivery_Point_Suffix VARCHAR(2) NULL
);
/*Now it's time to populate table "temp_address" with data from client machine*/
\copy temp_address(Postcode, Post_Town, Dependent_Locality, Double_Dependent_Locality, Thoroughfare_and_Descriptor, Dependent_Thoroughfare_and_Descriptor, Building_Number, Building_Name, Sub_Building_Name, PO_Box, Department_Name, Organisation_Name, UDPRN, Postcode_Type, SU_Organisation_Indicator, Delivery_Point_Suffix) from '$csv_location' DELIMITERS ',';

/*After populating data create necessary Indexes on table "temp_address"*/
CREATE INDEX temp_postcode_index ON temp_address (Postcode);

/*DROPING OLD indexes of address table if exist*/
DROP INDEX IF EXISTS postcode_index;

/*DROPING OLD ADDRESS TABLE it will also drop old indexes on table */
DROP TABLE IF EXISTS address;

/*DROPING SEQUENCE FOR OLD address TABLE*/
DROP SEQUENCE IF EXISTS address_id;

/**********Changing Sequnce name, Index name to old address table's sequnce and index name before renaming Table name**********/
ALTER SEQUENCE IF EXISTS temp_address_id RENAME TO address_id;
ALTER TABLE IF EXISTS temp_address ALTER COLUMN id SET DEFAULT nextval('address_id');
ALTER INDEX temp_postcode_index RENAME TO postcode_index;
ALTER INDEX IF EXISTS temp_address_pkey RENAME TO address_pkey;

/*FINALLY RENAMING TABLE NAME to address from temp_address*/
ALTER TABLE IF EXISTS temp_address RENAME TO address;

/* \q meta command is used to quit the current database*/
\q
EOF
echo "*************End execution**********"
unset db_password
exit 0
