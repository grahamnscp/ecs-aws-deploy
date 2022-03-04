create table default.prescribing_data_ext (
YEAR_MONTH string,
REGIONAL_OFFICE_NAME string,
REGIONAL_OFFICE_CODE string,
STP_NAME string,
STP_CODE string,
PCO_NAME string,
PCO_CODE string,
PRACTICE_NAME string,
PRACTICE_CODE string,
ADDRESS_1 string,
ADDRESS_2 string,
ADDRESS_3 string,
ADDRESS_4 string,
POSTCODE string,
BNF_CHEMICAL_SUBSTANCE string,
CHEMICAL_SUBSTANCE_BNF_DESCR string,
BNF_CODE string,
BNF_DESCRIPTION string,
BNF_CHAPTER_PLUS_CODE string,
QUANTITY string,
ITEMS string,
TOTAL_QUANTITY string,
ADQUSAGE string,
NIC string,
ACTUAL_COST string,
UNIDENTIFIED string)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
     "SEPARATORCHAR" = "|",
     "QUOTECHAR"     = "\"",
     "ESCAPECHAR"    = "\""
)
STORED AS TEXTFILE;
