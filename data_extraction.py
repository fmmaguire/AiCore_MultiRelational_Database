import os
import psycopg2
import yaml
from sqlalchemy import create_engine
import pandas as pd
import tabula
import requests
import boto3
from io import StringIO
from database_utils import DatabaseConnector

class DataExtractor:
    def __init__(self):
        self.connector = DatabaseConnector()

    def read_rds_table(self, table_name):
        engine = self.connector.init_db_engine()
        with engine.connect() as connection:
            query = f"SELECT * FROM {table_name}"
            df = pd.read_sql(query, connection)
            return df
        
    def retrieve_pdf_data(self, pdf_link):
        pdf_data = tabula.read_pdf(pdf_link, pages='all')
        df = pd.concat(pdf_data, ignore_index=True)
        return df
    
    def list_number_of_stores(self, endpoint, headers):
        response = requests.get(endpoint, headers=headers)
        if response.status_code == 200:
            return response.json()
        else:
            print(f"Failed to retrieve number of stores. Status code: {response.status_code}")
            return None

    def retrieve_stores_data(self, store_endpoint, headers, number_of_stores):
        stores_data = []
        for store_number in range(0, number_of_stores + 1):
            response = requests.get(store_endpoint + str(store_number), headers=headers)
            if response.status_code == 200:
                stores_data.append(response.json())
            else:
                print(f"Failed to retrieve store {store_number}. Status code: {response.status_code}")
        return pd.DataFrame(stores_data)
    
    def extract_from_s3(self, s3_address):
        bucket_name, key = self.parse_s3_address(s3_address)
        self.s3_client = boto3.client('s3', region_name = 'eu-west-1')

        # Download the file from S3
        response = self.s3_client.get_object(Bucket=bucket_name, Key=key)
        csv_content = response['Body'].read().decode('utf-8')
        
        # Read CSV content into a pandas DataFrame
        df = pd.read_csv(StringIO(csv_content))
        
        return df
    
    def parse_s3_address(self, s3_address):
        if not s3_address.startswith('s3://'):
            raise ValueError("Invalid S3 address. It should start with 's3://'")
        
        parts = s3_address[len('s3://'):].split('/')
        if len(parts) < 2:
            raise ValueError("Invalid S3 address. It should be in the format 's3://bucket_name/key'")
        
        bucket_name = parts[0]
        key = '/'.join(parts[1:])
        
        return bucket_name, key
