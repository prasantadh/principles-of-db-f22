import streamlit as st
import pandas as pd
import psycopg2
from configparser import ConfigParser

@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}

@st.cache
def query_db(sql: str):
    db_info = get_config()
    conn = psycopg2.connect(**db_info)
    curr = conn.cursor()
    curr.execute(sql)

    data = curr.fetchall()
    column_names = [desc[0] for desc in curr.description]
    conn.commit()

    curr.close()
    conn.close()

    df = pd.DataFrame(data=data, columns=column_names)
    return df

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
    try:
        sql = "SELECT * FROM Teachers;"
        st.dataframe(query_db(sql))
    except:
        st.write("Something went wrong!")

    try:
        data = query_db("SELECT initials FROM Teachers;")
        teacher = st.selectbox('Pick a teacher: ', data)
        st.write("Schedule: ")
        st.dataframe(query_db("SELECT day, cast(time as varchar(64)), grade, room from schedules where teacher='{}' order by day, time;".format(teacher)))
        st.write("Students Taught: ")
        sql = """
        SELECT distinct students.name, students.attend
        from students
        join
        schedules
        on students.attend=schedules.grade
        where schedules.teacher='{}'
        order by students.attend, students.name""".format(teacher)
        st.dataframe(query_db(sql))
    except Exception as e:
        st.write(e)
    #possible to choose teacher then show their half days, schedules

    #option = st.selectbox('Pick a Teacher',(data))
    #st.markdown("{}".format(option))

#Optional Pages with overall structure
#Students Page
if select == 'Students':

    st.title('Students')

    try:
        data = query_db("SELECT name FROM Students;")
        student = st.selectbox('Pick a student: ', data)
        st.write("Schedule: ")
        st.dataframe(query_db("SELECT day, cast(time as varchar(64)), grade, room, teacher from schedules where grade=(select attend from students where name = '{}') order by day, time;".format(student)))
        st.write("Students Taught: ")
    except Exception as e:
        st.write(e)

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
