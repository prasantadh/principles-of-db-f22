import streamlit as st
import pandas as pd
import psycopg2
from configparser import ConfigParser

@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}

db_info = get_config()
conn = psycopg2.connect(**db_info)
curr = conn.cursor()
curr.execute("SELECT * from schedule;") # just dummy table I created
data = curr.fetchall()
conn.close()
df = pd.DataFrame(data=data)
st.dataframe(data)
