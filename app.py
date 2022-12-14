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
#OUTPUT
st.sidebar.title("Navigation")
select = st.sidebar.radio("GO TO:",('Home','Teachers','Students', 'Lessons','Grades',
                                    'Schedule'))
#Home Page
if select == 'Home':
    st.markdown("""
    <br>
    <br>
    <br>
    <br>
    <h1 style="color:#26608e;">School Schedule System</h1>
    <h3 style="color:#f68b28;">Sonali Singh, Prasant Adhikari</h3>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>
    <h5>sks9370, pa1038</h5>
    <h5>For Principles of Databases by Prof. Julia Stoyanovich</h5>
    <h5>New York University</h5>
    """, unsafe_allow_html=True)

#Teachers page
if select == 'Teachers':
    st.title('Teachers')
    option = st.selectbox('Pick a Teacher',('AKC','DMS','BL','BS'))
    curr.execute("SELECT * from Teachers;") # sql queries
    #possible to choose teacher then show their half days, schedules
    data = curr.fetchall()
    conn.close()
    df = pd.DataFrame(data=data)
    st.dataframe(data)

#Optional Pages with overall structure
#Students Page
if select == 'Students':
    st.title('Student Details')
    curr.execute("SELECT * from Students;") # sql queries
    data = curr.fetchall()
    conn.close()
    df = pd.DataFrame(data=data)
    st.dataframe(data)

#Lessons Page
if select == 'Lessons':
    st.title('Lessons')
    curr.execute("SELECT * from Lessons;") # sql queries
    data = curr.fetchall()
    conn.close()
    df = pd.DataFrame(data=data)
    st.dataframe(data)
    #could include subjects

#Grades Page
if select == 'Grades':
    st.title('Grade Details')
    curr.execute("SELECT * from Grades;") # sql queries
    data = curr.fetchall()
    conn.close()
    df = pd.DataFrame(data=data)
    st.dataframe(data)

    
#Schedules Page
if select == 'Schedule':
    st.title('Schedule Details')
    curr.execute("SELECT * from Schedules;") # sql queries
    data = curr.fetchall()
    conn.close()
    df = pd.DataFrame(data=data)
    st.dataframe(data)
