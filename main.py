import psycopg2
import time
import pandas as pd
from sqlalchemy import create_engine

# Get user input for database connection details
database_name = input("Enter database name that you created in PostgresSQL: ")
user = input("Enter database username: ")
password = input("Enter database password: ")
host = input("Enter database host (default is 'localhost'): ") or "localhost"
port = input("Enter database port (default is '5432'): ") or "5432"

# Define the file path and database connection string
csv_file_path = 'DOHMH_New_York_City_Restaurant_Inspection_Results_20231020.csv'
database_uri = f"postgresql://{user}:{password}@{host}:{port}/{database_name}"

try:

    print("Loading data...")  # Loading message

    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)

    # Create a database connection
    engine = create_engine(database_uri)

    # Insert the DataFrame into the PostgreSQL database
    df.to_sql('restaurant_inspection_dataset', engine, if_exists='replace', index=False)

    # Close the database connection
    engine.dispose()

    print(f"Data loaded successfully!")  # Loaded message

except Exception as e:
    print(f"An error occurred: {e}")
