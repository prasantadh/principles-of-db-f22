def insert_lessons():
    times = ['8:30', '9:15', '10:00', '10:45', '11:30', '12:15', '13:00', '13:45', '14:30', '15:15', '16:00']
    days  = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
    for day in range(len(days)):
        for end in range(1, len(times)):
            print("insert into lessons values ('{}', '[2022-01-0{} {}, 2022-01-0{} {})');".format(days[day], day + 1, times[end - 1], day + 1, times[end]))
    print("update lessons set is_assembly = true where day = 'MONDAY' and time = '[2022-01-01 8:30, 2022-01-01 9:15)';")
    for day in range(len(days)):
        print("update lessons set is_lunch = true where day = '{}' and time = '[2022-01-0{} 11:30, 2022-01-0{} 12:15)';".format(days[day], day+1, day+1))
            # update to include the lunch and assembly lessons

# insert into lessons values (SUNDAY, '[2010-01-01 14:30, 2010-01-01 15:30)');


def insert_grades():
    grades = []
    for i in range(5, 11):
        for j in range(ord('A'), ord('E')):
            grades.append(str(i) + chr(j))
    grades += ['A1A', 'A1B', 'A2A', 'A2B', 'A1C', 'A2C']
    for grade in grades:
        print("insert into grades values ('{}', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');".format(grade))

def insert_lunches():
    grades = []
    for i in range(5, 11):
        for j in range(ord('A'), ord('E')):
            grades.append(str(i) + chr(j))

    days  = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
    for day in range(len(days)):
        for grade in grades:
            print("insert into Lunch values ('{}', '[2022-01-0{} 11:30, 2022-01-0{} 12:15)', '{}' );".format(days[day], day+1, day+1, grade))

departments = ['English', 'Mathematics']
def insert_departments():
    for department in departments:
        print("insert into departments values ('{}');".format(department))

def insert_rooms():
    for room in range(100):
        print("insert into rooms values('{}');".format(room))

def insert_terms():
    print("insert into terms values('{}');".format(2022))

def insert_teachers():
    maths   = 'MATHEMATICS'
    eng     = 'ENGLISH'
    teachers = [
            ['AKC', 'THURSDAY',  maths],
            ['DMS', 'WEDNESDAY', maths],
            ['BL',  'SUNDAY',    eng],
            ['BS',  'TUESDAY', eng]
            ]
    for teacher in teachers:
        print("insert into Teachers values ('{}','{}','{}','{}');" .format(teacher[0], teacher[1], 2022, teacher[2]))

import pandas as pd
from math import isnan
from datetime import datetime
from datetime import timedelta
df = pd.read_csv('data.csv')

def extract_schedule(teacher):
    times = ['8:30', '9:15', '10:00', '10:45', '11:30', '12:15', '13:00', '13:45', '14:30', '15:15', '16:00']
    days  = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY']
    for i, day, time, value in df[['Days', 'Lesson_Times', teacher]].itertuples():
        if (str(value) == 'nan'): continue
        if i % 2 == 0:
            grade = value
        else:
            day = day.upper()
            startstr = '2022-01-0{} {}'.format(days.index(day) + 1, time)
            start = datetime.strptime(startstr, '%Y-%m-%d %I:%M %p')
            end = start + timedelta(minutes=45)
            print("insert into schedules values ( '{}', '{}', '{}', '{}', '{}', '[{}, {})');"
                .format( grade, value, teacher, 2022, day, start, end))

def insert_schedules():
    # this is not really scalable
    # at the moment, going with something that works
    # since we are only using a small subset of teachers
    extract_schedule('AKC')
    extract_schedule('DMS')
    extract_schedule('BL')
    extract_schedule('BS')

if __name__ == "__main__":
    # insert_lessons()
    # insert_grades()
    # insert_lunches()
    # insert_departments()
    # insert_rooms()
    # insert_terms()
    # insert_teachers()
    insert_schedules()
