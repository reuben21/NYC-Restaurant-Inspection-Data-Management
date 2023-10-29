import psycopg2
import time
import pandas as pd
from sqlalchemy import create_engine

# Define the file path and database connection string
csv_file_path = 'DOHMH_New_York_City_Restaurant_Inspection_Results_20231020.csv'
database_uri = 'postgresql://postgres:password@localhost:5432/nyc_restaurant_inspection'
database_name = 'nyc_restaurant_inspection'

try:
    # Establish a connection to the default database (e.g., 'postgres')
    conn = psycopg2.connect(user="postgres", password="password", host="localhost", port="5432")
    conn.autocommit = True

    # Create a cursor object
    cur = conn.cursor()

    # Create the database if it doesn't exist
    cur.execute("CREATE DATABASE NYC_Restaurant_Inspection")
    print("CREATED DATABASE")

    # Close the cursor and connection to the default database
    cur.close()
    conn.close()
    time.sleep(5)

    # Read the CSV file into a DataFrame
    df = pd.read_csv(csv_file_path)

    # Create a database connection
    engine = create_engine(database_uri)

    # Insert the DataFrame into the PostgreSQL database
    df.to_sql('restaurant_inspection_dataset', engine, if_exists='replace', index=False)

    # Close the database connection
    engine.dispose()

    print(f"Database '{database_name}' created and data inserted successfully!")

except Exception as e:
    print(f"An error occurred: {e}")
