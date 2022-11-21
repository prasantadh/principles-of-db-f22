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

def insert_departments():
    departments = ['English', 'Mathematics']
    for department in departments:
        print("insert into departments values ('{}');".format(department))

def insert_rooms():
    for room in range(100):
        print("insert into rooms values('{}');".format(room))

def insert_terms():
    print("insert into terms values('{}');".format(2022))

if __name__ == "__main__":
    # insert_lessons()
    # insert_grades()
    # insert_lunches()
    # insert_departments()
    # insert_rooms()
    insert_terms()



