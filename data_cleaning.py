import pandas as pd
from datetime import datetime

class DataCleaning:
    def clean_user_data(self, user_data):
        # Drop rows with NULL values
        user_data = user_data.dropna()

        # Convert date columns to datetime format
        date_columns = ['date_of_birth', 'join_date']
        for column in date_columns:
            user_data[column] = pd.to_datetime(user_data[column], errors='coerce')

        # Drop rows with invalid date values
        user_data = user_data.dropna(subset=date_columns)

        # Convert columns to appropriate data types
        user_data['user_uuid'] = user_data['user_uuid'].astype(str)
        user_data['country'] = user_data['country'].astype(str)
        user_data['email'] = user_data['email'].astype(str)

        user_data = user_data.drop(columns=['index'])

        return user_data
    
    def clean_card_data(self, card_data):
        # Drop rows with NULL values
        card_data = card_data.dropna()

        # Remove non-numeric characters from card_number
        card_data['card_number'] = card_data['card_number'].str.replace(r'\D', '')

        # Convert card_number to integers
        card_data['card_number'] = pd.to_numeric(card_data['card_number'], errors='coerce')

        # Convert expiry_date from mm/yy to dd/mm/yyyy
        card_data['expiry_date'] = pd.to_datetime(card_data['expiry_date'], format='%m/%y', errors='coerce')
        card_data['expiry_date'] = card_data['expiry_date'].dt.strftime('%d/%m/%Y')

        # Convert card_provider to string
        card_data['card_provider'] = card_data['card_provider'].astype(str)

        return card_data
    
    def clean_store_data(self, stores_data):
        # Fill missing values in latitude column with values from lat column
        stores_data['latitude'] = stores_data['latitude'].fillna(stores_data['lat'])

        # Drop lat column
        stores_data = stores_data.drop(columns=['index','lat'], errors='ignore')

        # Convert opening date to yyyy-mm-dd format
        stores_data['opening_date'] = pd.to_datetime(stores_data['opening_date'], errors='coerce').dt.strftime('%Y-%m-%d')

        # Convert staff_numbers to integers
        stores_data['staff_numbers'] = pd.to_numeric(stores_data['staff_numbers'], errors='coerce', downcast='integer')

        # Remove 'ee' from continent column if it begins with 'ee'
        stores_data['continent'] = stores_data['continent'].str.replace('^ee', '', regex=True)

        return stores_data

    def convert_product_weights(self, df):
        df['weight'] = df['weight'].str.replace('[^\d.]', '', regex=True).astype(float)
        df.loc[df['weight_unit'].isin(['ml', 'g']), 'weight'] *= 0.001
        return df

    def clean_products_data(self, df):
        # Remove 'Unnamed' and 'weight_unit' columns
        df = df.drop(columns=['Unnamed: 0', 'weight_unit'], errors='ignore')
        
        # Remove '£' symbol from 'product_price' values
        df['product_price'] = df['product_price'].str.replace('£', '', regex=False)
        
        # Ensure 'date_added' column is in 'yyyy-mm-dd' format
        df['date_added'] = pd.to_datetime(df['date_added'], errors='coerce').dt.strftime('%Y-%m-%d')
        
        # Remove duplicate rows
        df = df.drop_duplicates()

    def clean_orders_data(self, df):
        # Remove 'first_name', 'last_name', and '1' columns
        columns_to_remove = ['first_name', 'last_name', '1', 'level_0', 'index']
        df = df.drop(columns=columns_to_remove, errors='ignore')
        
        # Convert 'product_quantity' to integer
        df['product_quantity'] = df['product_quantity'].astype(int)

        # Perform additional cleaning operations as needed
        
        return df
