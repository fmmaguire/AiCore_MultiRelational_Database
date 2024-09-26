import os
import psycopg2
import yaml
from sqlalchemy import create_engine
import pandas as pd
# import db_creds.yaml

class DatabaseConnector:
    def __init__(self):
        self.engine = self.init_db_engine()
        self.upload_engine = self.init_upload_engine()

    def read_db_creds(self, filename='db_creds.yaml'):
        with open(filename, 'r') as file:
            db_creds = yaml.safe_load(file)
        return db_creds

    def init_db_engine(self):
        creds = self.read_db_creds()
        db_uri = f"postgresql://{creds['RDS_USER']}:{creds['RDS_PASSWORD']}@{creds['RDS_HOST']}:{creds['RDS_PORT']}/{creds['RDS_DATABASE']}"
        engine = create_engine(db_uri)
        return engine

    def list_db_tables(self):
        with self.engine.connect() as conn:
            tables = conn.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';")
            table_names = [table[0] for table in tables]
        return table_names
    
    def init_upload_engine(self):
        creds = self.read_db_creds()
        db_uri = f"postgresql://{creds['USER']}:{creds['PASSWORD']}@{creds['HOST']}:{creds['PORT']}/{creds['DATABASE']}"
        engine = create_engine(db_uri)
        return engine

    def upload_to_db(self, df, table_name):
        df.to_sql(table_name, self.upload_engine, if_exists='replace', index=False)