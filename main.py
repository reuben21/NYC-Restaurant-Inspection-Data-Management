import pandas as pd
from sqlalchemy import create_engine

# Define the file path and database connection string
csv_file_path = 'DOHMH_New_York_City_Restaurant_Inspection_Results_20231020.csv'
database_uri = 'postgresql://postgres:password@localhost:5432/NYC_Restaurant_Inspection'

# Read the CSV file into a DataFrame
df = pd.read_csv(csv_file_path)

# Create a database connection
engine = create_engine(database_uri)

# Insert the DataFrame into the PostgreSQL database
df.to_sql('restaurant_inspection_dataset', engine, if_exists='replace', index=False)

# Close the database connection
engine.dispose()
