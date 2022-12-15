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
    sql = "SELECT * FROM Teachers;"
    try:
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
        FROM students
        JOIN
        schedules
        ON students.attend=schedules.grade
        WHERE schedules.teacher='{}'
        ORDER BY students.attend, students.name""".format(teacher)
        st.dataframe(query_db(sql))
    except Exception as e:
        st.write(e)
    #possible to choose teacher then show their half days, schedules

    #option = st.selectbox('Pick a Teacher',(data))
    #st.markdown("{}".format(option))

#Optional Pages with overall structure
#Students Page
if select == 'Students':
    st.title('Student Details')
    sql = "SELECT * FROM Students;"
    try:
        st.dataframe(query_db(sql))
    except:
        st.write("Something went wrong!")

    try:
        data = query_db("SELECT name FROM Students;")
        student = st.selectbox('Pick a Student: ', data)
        st.write("Schedule: ")
        st.dataframe(query_db("SELECT day, cast(time as varchar(64)), grade, room, teacher from schedules where grade=(select attend from students where name = '{}') order by day, time;".format(student)))

        st.write("Lunch Time: ")
        sql = """
        SELECT s.id, s.name, l.lunch_day, cast(l.lunch_time as varchar(128))
        FROM students s
        JOIN
        lunch l
        ON s.attend=l.grade
        WHERE s.name='{}';""".format(student)
        st.dataframe(query_db(sql))
        
        st.write("Subjects: ")
        sql = """
        SELECT s.id, s.name, sub.name as subject, sub.double_lesson, sub.term
        FROM students s
        JOIN
        subjects sub
        ON s.attend=sub.grade
        WHERE s.name='{}';""".format(student)
        st.dataframe(query_db(sql))
      
    except Exception as e:
        st.write(e)

#Lessons Page
if select == 'Lessons':
    st.title('Lesson Details')
    sql = "SELECT * FROM Lessons;"
    try:
        st.dataframe(query_db(sql))
    except:
        st.write("Something went wrong!")

    try:
        data = query_db("SELECT DISTINCT day FROM Lessons;")
        lesson = st.selectbox('Pick a Lesson Time: ', data)
        st.write("Schedule: ")
        st.dataframe(query_db('''SELECT s.day, cast(s.time as varchar(64)), s.grade, s.room, s.teacher
                                 FROM schedules s
                                 WHERE day='{}' order by day, time;'''.format(lesson)))
        st.write("Students Taught: ")
        '''sql = """
        SELECT distinct students.name, students.attend
        FROM students
        JOIN
        schedules
        ON students.attend=schedules.grade
        WHERE schedules.teacher='{}'
        ORDER BY students.attend, students.name""".format(lesson)
        st.dataframe(query_db(sql))'''
    except Exception as e:
        st.write(e)

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
