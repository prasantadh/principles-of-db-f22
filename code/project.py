import streamlit as st
import pandas as pd
import psycopg2
from configparser import ConfigParser
from datetime import datetime

@st.cache
def get_config(filename="database.ini", section="postgresql"):
    parser = ConfigParser()
    parser.read(filename)
    return {k: v for k, v in parser.items(section)}

# @st.cache
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
select = st.sidebar.radio("GO TO:",('Home','Teachers','Students', 'Lessons','Grades','Rooms',
                                    'Find Substitutes'))
def parse_time(data):
    df = pd.DataFrame(data)
    df['starttime'] = df['time'].apply(lambda time: datetime.strptime(time.split(',')[0], '["%Y-%m-%d %H:%M:%S"').strftime('%H:%M %p'))
    df['endtime'] = df['time'].apply(lambda time: datetime.strptime(time.split(',')[1], '"%Y-%m-%d %H:%M:%S")').strftime('%H:%M %p'))
    df.drop('time', axis=1, inplace=True)
    return df

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
    st.write('This page provides details of individual teachers')
    sql = "SELECT * FROM Teachers;"
    try:
        st.dataframe(query_db(sql))
    except:
        st.write("Something went wrong!")

    try:
        data = query_db("SELECT initials FROM Teachers;")
        st.header('Pick a teacher: ')
        teacher = st.selectbox('', data)
        st.subheader("Schedule for {}".format(teacher))
        st.write("Schedule: ")
        data = query_db("SELECT day, cast(time as varchar(64)), grade, room from schedules where teacher='{}' order by day, time;".format(teacher))
        data = parse_time(data)
        st.dataframe(data)

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

        st.write("Number of classes:")
        sql = """
        select s.teacher, s.day, count(*)
        from schedules s
        where s.teacher='{}'
        group by s.teacher, s.day
        order by s.day;""".format(teacher)
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
    st.write('This page provides details of individual students')
    sql = "SELECT * FROM Students;"
    try:
        st.dataframe(query_db(sql))
    except:
        st.write("Something went wrong!")

    try:
        data = query_db("SELECT name FROM Students;")
        st.header('Pick a Student:')
        student = st.selectbox('', data)
        st.subheader("Schedule for {} ".format(student))
        data = query_db("SELECT day, cast(time as varchar(64)), grade, room, teacher from schedules where grade=(select attend from students where name = '{}') order by day, time;".format(student))
        data = parse_time(data)
        st.dataframe(data)

        st.write("Subjects: ")
        sql = """
        SELECT s.id, s.name, sub.name as subject, sub.double_lesson, sub.term
        FROM students s
        JOIN
        subjects sub
        ON s.attend=sub.grade
        WHERE s.name='{}';""".format(student)
        st.dataframe(query_db(sql))

        st.write("Number of classes: ")
        sql = """
        select s.id, s.name, sh.grade, sh.day, count(*)
        from students s, schedules sh
        where s.attend=sh.grade
        and s.name='{}'
        group by s.id, s.name, sh.grade, sh.day
        order by 4;""".format(student)
        st.dataframe(query_db(sql))

        st.write("Lunch Time: ")
        sql = """
        SELECT s.id, s.name, l.lunch_day, cast(l.lunch_time as varchar(128)) as time
        FROM students s
        JOIN
        lunch l
        ON s.attend=l.grade
        WHERE s.name='{}';""".format(student)
        data = query_db(sql)
        data = parse_time(data)
        st.dataframe(data)

        st.write("Assembly Time: ")
        sql = """
        SELECT s.id, s.name, g.assembly_day as day, cast(g.assembly_time as varchar(128)) as time
        FROM students s
        JOIN
        grades g
        ON s.attend=g.name
        WHERE s.name='{}';""".format(student)
        data = query_db(sql)
        data = parse_time(data)
        st.dataframe(data)
    except Exception as e:
        st.write(e)

#Lessons Page
if select == 'Lessons':
    st.title('Lesson Details')
    try:
        data = query_db("SELECT DISTINCT day FROM Lessons order by 1;")
        lesson = st.selectbox('Pick a Lesson Time: ', data)
        st.write("Schedule: ")
        lessons = query_db('''SELECT distinct s.day, cast(s.time as varchar(128)), s.grade, s.room, s.teacher
                                 FROM schedules s
                                 JOIN lessons l
                                 ON s.day = l.day
                                 WHERE l.day='{}' order by day, time;'''.format(lesson))
        lessons = parse_time(lessons)
        st.dataframe(lessons)
    except Exception as e:
        st.write(e)

#Grades Page
if select == 'Grades':
    st.title('Grade Details')
    try:
        grades = query_db("SELECT DISTINCT name FROM Grades, Schedules where grades.name = schedules.grade;")
        grade = st.selectbox('Pick a Grade: ', grades)
        st.write("Schedule: ")
        data = query_db('''SELECT s.day, cast(s.time as varchar(64)), s.grade, s.room, s.teacher
                                 FROM schedules s
                                 WHERE grade='{}' order by day, time;'''.format(grade))
        data = parse_time(data)
        st.dataframe(data)
        st.write("Total Student in this grade: {}".format(grade))
        sql = "select attend, count(name) from students group by attend order by attend;"
        students_count = query_db(sql)
        st.dataframe(students_count)
    except Exception as e:
        st.write(e)

#Rooms Page
if select =='Rooms':
    st.title("Room details")
    try:
             data = query_db("SELECT DISTINCT room from Schedules order by room")
             room = st.selectbox('Pick a room:', data)
             st.write("Room Schedule: ")
             data = query_db('''SELECT s.day, cast(s.time as varchar(64)) as time, s.grade, s.room, s.teacher
                                 FROM schedules s
                                 WHERE room='{}' order by day, time;'''.format(room))
             data =  parse_time(data)
             st.dataframe(data)
             st.write("Number of lessons per room:")
             sql = """SELECT room, count(*)
                     FROM schedules
                     GROUP BY room
                     ORDER BY room;"""
             st.dataframe(query_db(sql))
    except Exception as e:
            st.write(e)

#not sure if we need this since we have schedules in most pages
#Schedules Page
def get_teachers():
    sql = "select initials from teachers;"
    data = query_db(sql);
    return data

if select == 'Find Substitutes':
    st.title('Schedule Details')
    st.write('This page provides all information regarding possible substitute teachers')

    teachers = get_teachers()
    absentees = st.multiselect("Who are absent today?", teachers)
    today = datetime.today().strftime('%A').upper()
    for absentee in absentees:
        st.header("Absent Teacher: {}".format(absentee))

        try:
            st.write("Non-Absent Teachers from the same department: ")
            sql = "select initials from teachers where department = (select department from teachers where initials = '{}') and initials not in {};".format(absentee, tuple(absentees + ['NONEXISTENT']));
            st.write(query_db(sql))

            sql = "Select day, cast(time as varchar(64)), grade, room from schedules where teacher='{}' and day='{}';".format(absentee, today)
            lessons = pd.DataFrame(query_db(sql))
            for _, day, time, grade, room in lessons.itertuples():
                starttime = datetime.strptime(time.split(',')[0], '["%Y-%m-%d %H:%M:%S"')
                st.subheader("Lesson To Substitute: grade {} in room {} at {}".format(grade, room, starttime.strftime('%H:%M %p')))

                # this query can be arbitrarily large depending on the business rule
                # like  exclude the ones with half lessons after lunch
                #       exclude ones who have contiguous lessons
                #       exclude ones who have already been used for other substitutions
                # etc. etc.
                # however for the sake of simplicity, we decided to only exclude the ones
                # who are absent on that particular day
                # also for simplicity, we decided that we are going to look into
                # "the present day" by default
                sql = "select A.initials from (select day, time, initials from lessons, teachers) A left join (select day, time, teacher from schedules) B on A.day = B.day and A.time=B.time and A.initials=B.teacher where B.teacher is NULL and A.day='{}' and A.time='{}' and A.initials not in {};".format(today, time, tuple(absentees + ['NON-EXISTENT']))
                st.dataframe(query_db(sql))
            # Teachers who teach this grade
        except Exception as e:
            st.write(e)

