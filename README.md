# AiCore_MultiRelational_Database
A project focusing on creating data pipelines to extract data from different sources for a multinational retailer, cleaning these, then constructing and querying the final dataset.

<!-- TABLE OF CONTENTS -->
<details> 
  <summary>Table of Contents</summary> 
  <ol> 
    <li> 
      <a href="#Multinational-Retail-Data-Centralisation">Multinational Retail Data Centralisation</a>
        <ul> 
          <li><a href="#installation">Installation</a></li> 
          <li><a href="#usage">Usage</a></li> 
          <li><a href="#customization">Customization</a></li> 
      </ul> 
    </li> 

  </ol> 
</details> 

## Multinational Retail Data Centralisation
A project focusing on creating data pipelines to extract data from different sources for a multinational retailer, cleaning these, then constructing and querying the final dataset.

#### Installation
Import os package: `import os`  
Import create engine from sqlalchemy package: `from sqlalchemy import create_engine`  
Import StringIO from io package: `from sqlalchemy import StringIO`  
Import psycopg2 package: `import psycopg2`  
Import tabula package: `import tabula`  
Import requests package: `import requests`
Import boto3 package: `import boto3`  


#### Usage
First set up a new database to store the data.
Create a yaml file with the details of your database and further details if needed for your data sources.
- Use DatabaseConnector class within database_utils.py to create an engine for investigating and downloading RDS data sources
- Use DatabaseExtractor class methods within in data_extarction.py to extract data from pdf tables, APIs, S3 and RDS data sources
- Use DataCleaning class within data_cleaning.py to clean data sources as necessary
- database_scehma.sql shows how data in SQL can be altered to create a star-based schema, ensuring that columns are of the correct datat types
- data_queries.sql shows how data in SQL can be queried to produced outputs for analysis
  
#### Customization
The data extraction and cleaning scripts should be altered depending on the data sources you are investigating.
The SQL scripts should be used as examples of how to structure and query your data but will need to be customized to match the data.
