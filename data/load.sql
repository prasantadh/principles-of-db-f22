drop table if exists Teachers_know, Schedules, Terms, Lessons, Lunch, Rooms, Departments, Subjects, Grades, Students, Terms, Teachers;
drop type if exists DAYS;

create type DAYS as ENUM 
( 
	'SUNDAY',
	'MONDAY',
	'TUESDAY',
	'WEDNESDAY',
	'THURSDAY',
	'FRIDAY',
	'SATURDAY'
);

/* entity set Terms */
--populated
create table Terms (
	year integer primary key,
	CHECK ( year > 2021 )
);

/* entity set Lessons */
--populated
create table Lessons (
	day DAYS,
	time tsrange,
	primary key (day, time),
	is_lunch boolean,
	is_assembly boolean,
	exclude using gist (time with &&) /* have non-overlapping range only for lessons */
);


/* entity set Grades with relationship sets Lunch and Assembly */
--populated
create table Grades (
	name char(32) primary key,
	assembly_day DAYS
		not null,
	assembly_time tsrange,
	foreign key (assembly_day, assembly_time) references Lessons(day, time),
	/* there's only one assembly lesson for a grade */
	unique (name, assembly_day)
);


--populated
create table Lunch (
	lunch_day DAYS not null,
	lunch_time tsrange,
	foreign key (lunch_day, lunch_time) references Lessons(day, time),
	grade char(32) references Grades(name) not null,
	primary key(grade, lunch_day, lunch_time) 
	/* ^ is to ensure each grade gets at most one lunch
	lesson per day */
);


/* entity set Students 
with relationship set attend */
--populated
create table Students (
	id varchar(128) primary key, --changed from int to varchar
	name char(64),
	attend char(32) references Grades(name) 
		not null	/* total participation */
);

/* entity set Departments */
--populated
create table Departments (
	name char(32) primary key
);

/* Teachers entity set
with relationship set Works_in and Half_Day */
--populated
create table Teachers (
	initials char(32) primary key,
	half_day DAYS not null,
	term int references Terms(year) not null,
	department char(32) references Departments(name) not null
);

/* entity set Rooms */
--populated
create table Rooms (
	room_number integer primary key
);

/* entity set Subjects */
--populated
create table Subjects (
	name char(32),
	double_lesson boolean default false,
	term int,
	grade char(32),
	primary key (name, grade, term),
	foreign key (grade) references Grades(name) on delete cascade,
	foreign key (term) references Terms(year) on delete cascade
);

create table Teachers_know (
    teacher char(32),
    subject char(32),
    grade char(32),
    term int,
    foreign key (subject, grade, term) references Subjects(name, grade, term),
    primary key(subject, grade, term, teacher)
);

/* relationship set Schedule */
--populated
create table Schedules (
	grade char(32) references Grades(name) not null,
	room integer references Rooms(room_number) not null,
	teacher char(32) references Teachers(initials) not null,
	term int references Terms(year) not null,
	day DAYS not null,
	time tsrange not null,
	foreign key (day, time) references Lessons (day, time),
	UNIQUE(day, time, teacher, term), /* one teacher teaches only one lesson at a time */
	UNIQUE(day, time, room, term), /* one room hosts only one lesson at a time */
	UNIQUE(day, time, grade, term) /* one grade can attend only one lesson at a time */
);

insert into lessons values ('SUNDAY', '[2022-01-01 8:30, 2022-01-01 9:15)');
insert into lessons values ('SUNDAY', '[2022-01-01 9:15, 2022-01-01 10:00)');
insert into lessons values ('SUNDAY', '[2022-01-01 10:00, 2022-01-01 10:45)');
insert into lessons values ('SUNDAY', '[2022-01-01 10:45, 2022-01-01 11:30)');
insert into lessons values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)');
insert into lessons values ('SUNDAY', '[2022-01-01 12:15, 2022-01-01 13:00)');
insert into lessons values ('SUNDAY', '[2022-01-01 13:00, 2022-01-01 13:45)');
insert into lessons values ('SUNDAY', '[2022-01-01 13:45, 2022-01-01 14:30)');
insert into lessons values ('SUNDAY', '[2022-01-01 14:30, 2022-01-01 15:15)');
insert into lessons values ('SUNDAY', '[2022-01-01 15:15, 2022-01-01 16:00)');
insert into lessons values ('MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into lessons values ('MONDAY', '[2022-01-02 9:15, 2022-01-02 10:00)');
insert into lessons values ('MONDAY', '[2022-01-02 10:00, 2022-01-02 10:45)');
insert into lessons values ('MONDAY', '[2022-01-02 10:45, 2022-01-02 11:30)');
insert into lessons values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)');
insert into lessons values ('MONDAY', '[2022-01-02 12:15, 2022-01-02 13:00)');
insert into lessons values ('MONDAY', '[2022-01-02 13:00, 2022-01-02 13:45)');
insert into lessons values ('MONDAY', '[2022-01-02 13:45, 2022-01-02 14:30)');
insert into lessons values ('MONDAY', '[2022-01-02 14:30, 2022-01-02 15:15)');
insert into lessons values ('MONDAY', '[2022-01-02 15:15, 2022-01-02 16:00)');
insert into lessons values ('TUESDAY', '[2022-01-03 8:30, 2022-01-03 9:15)');
insert into lessons values ('TUESDAY', '[2022-01-03 9:15, 2022-01-03 10:00)');
insert into lessons values ('TUESDAY', '[2022-01-03 10:00, 2022-01-03 10:45)');
insert into lessons values ('TUESDAY', '[2022-01-03 10:45, 2022-01-03 11:30)');
insert into lessons values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)');
insert into lessons values ('TUESDAY', '[2022-01-03 12:15, 2022-01-03 13:00)');
insert into lessons values ('TUESDAY', '[2022-01-03 13:00, 2022-01-03 13:45)');
insert into lessons values ('TUESDAY', '[2022-01-03 13:45, 2022-01-03 14:30)');
insert into lessons values ('TUESDAY', '[2022-01-03 14:30, 2022-01-03 15:15)');
insert into lessons values ('TUESDAY', '[2022-01-03 15:15, 2022-01-03 16:00)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 8:30, 2022-01-04 9:15)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 9:15, 2022-01-04 10:00)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 10:00, 2022-01-04 10:45)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 10:45, 2022-01-04 11:30)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 12:15, 2022-01-04 13:00)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 13:00, 2022-01-04 13:45)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 13:45, 2022-01-04 14:30)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 14:30, 2022-01-04 15:15)');
insert into lessons values ('WEDNESDAY', '[2022-01-04 15:15, 2022-01-04 16:00)');
insert into lessons values ('THURSDAY', '[2022-01-05 8:30, 2022-01-05 9:15)');
insert into lessons values ('THURSDAY', '[2022-01-05 9:15, 2022-01-05 10:00)');
insert into lessons values ('THURSDAY', '[2022-01-05 10:00, 2022-01-05 10:45)');
insert into lessons values ('THURSDAY', '[2022-01-05 10:45, 2022-01-05 11:30)');
insert into lessons values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)');
insert into lessons values ('THURSDAY', '[2022-01-05 12:15, 2022-01-05 13:00)');
insert into lessons values ('THURSDAY', '[2022-01-05 13:00, 2022-01-05 13:45)');
insert into lessons values ('THURSDAY', '[2022-01-05 13:45, 2022-01-05 14:30)');
insert into lessons values ('THURSDAY', '[2022-01-05 14:30, 2022-01-05 15:15)');
insert into lessons values ('THURSDAY', '[2022-01-05 15:15, 2022-01-05 16:00)');
insert into lessons values ('FRIDAY', '[2022-01-06 8:30, 2022-01-06 9:15)');
insert into lessons values ('FRIDAY', '[2022-01-06 9:15, 2022-01-06 10:00)');
insert into lessons values ('FRIDAY', '[2022-01-06 10:00, 2022-01-06 10:45)');
insert into lessons values ('FRIDAY', '[2022-01-06 10:45, 2022-01-06 11:30)');
insert into lessons values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)');
insert into lessons values ('FRIDAY', '[2022-01-06 12:15, 2022-01-06 13:00)');
insert into lessons values ('FRIDAY', '[2022-01-06 13:00, 2022-01-06 13:45)');
insert into lessons values ('FRIDAY', '[2022-01-06 13:45, 2022-01-06 14:30)');
insert into lessons values ('FRIDAY', '[2022-01-06 14:30, 2022-01-06 15:15)');
insert into lessons values ('FRIDAY', '[2022-01-06 15:15, 2022-01-06 16:00)');
update lessons set is_assembly = true where day = 'MONDAY' and time = '[2022-01-01 8:30, 2022-01-01 9:15)';
update lessons set is_lunch = true where day = 'SUNDAY' and time = '[2022-01-01 11:30, 2022-01-01 12:15)';
update lessons set is_lunch = true where day = 'MONDAY' and time = '[2022-01-02 11:30, 2022-01-02 12:15)';
update lessons set is_lunch = true where day = 'TUESDAY' and time = '[2022-01-03 11:30, 2022-01-03 12:15)';
update lessons set is_lunch = true where day = 'WEDNESDAY' and time = '[2022-01-04 11:30, 2022-01-04 12:15)';
update lessons set is_lunch = true where day = 'THURSDAY' and time = '[2022-01-05 11:30, 2022-01-05 12:15)';
update lessons set is_lunch = true where day = 'FRIDAY' and time = '[2022-01-06 11:30, 2022-01-06 12:15)';
insert into grades values ('5A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('5B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('5C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('5D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('6A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('6B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('6C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('6D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('7A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('7B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('7C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('7D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('8A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('8B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('8C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('8D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('9A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('9B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('9C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('9D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('10A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('10B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('10C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('10D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('11A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('11B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('11C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('11D', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A1A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A1B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A2A', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A2B', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A1C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into grades values ('A2C', 'MONDAY', '[2022-01-02 8:30, 2022-01-02 9:15)');
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '5A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '5B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '5C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '5D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '6A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '6B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '6C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '6D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '7A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '7B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '7C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '7D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '8A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '8B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '8C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '8D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '9A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '9B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '9C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '9D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '10A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '10B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '10C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '10D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '11A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '11B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '11C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', '11D' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A1A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A1B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A2A' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A2B' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A1C' );
insert into Lunch values ('SUNDAY', '[2022-01-01 11:30, 2022-01-01 12:15)', 'A2C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '5A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '5B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '5C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '5D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '6A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '6B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '6C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '6D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '7A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '7B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '7C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '7D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '8A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '8B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '8C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '8D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '9A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '9B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '9C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '9D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '10A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '10B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '10C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '10D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '11A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '11B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '11C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', '11D' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A1A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A1B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A2A' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A2B' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A1C' );
insert into Lunch values ('MONDAY', '[2022-01-02 11:30, 2022-01-02 12:15)', 'A2C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '5A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '5B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '5C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '5D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '6A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '6B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '6C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '6D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '7A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '7B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '7C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '7D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '8A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '8B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '8C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '8D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '9A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '9B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '9C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '9D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '10A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '10B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '10C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '10D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '11A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '11B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '11C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', '11D' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A1A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A1B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A2A' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A2B' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A1C' );
insert into Lunch values ('TUESDAY', '[2022-01-03 11:30, 2022-01-03 12:15)', 'A2C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '5A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '5B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '5C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '5D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '6A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '6B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '6C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '6D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '7A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '7B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '7C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '7D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '8A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '8B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '8C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '8D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '9A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '9B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '9C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '9D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '10A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '10B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '10C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '10D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '11A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '11B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '11C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', '11D' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A1A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A1B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A2A' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A2B' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A1C' );
insert into Lunch values ('WEDNESDAY', '[2022-01-04 11:30, 2022-01-04 12:15)', 'A2C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '5A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '5B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '5C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '5D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '6A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '6B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '6C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '6D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '7A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '7B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '7C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '7D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '8A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '8B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '8C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '8D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '9A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '9B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '9C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '9D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '10A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '10B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '10C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '10D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '11A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '11B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '11C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', '11D' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A1A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A1B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A2A' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A2B' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A1C' );
insert into Lunch values ('THURSDAY', '[2022-01-05 11:30, 2022-01-05 12:15)', 'A2C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '5A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '5B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '5C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '5D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '6A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '6B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '6C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '6D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '7A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '7B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '7C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '7D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '8A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '8B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '8C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '8D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '9A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '9B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '9C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '9D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '10A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '10B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '10C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '10D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '11A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '11B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '11C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', '11D' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A1A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A1B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A2A' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A2B' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A1C' );
insert into Lunch values ('FRIDAY', '[2022-01-06 11:30, 2022-01-06 12:15)', 'A2C' );
insert into departments values ('English');
insert into departments values ('Mathematics');
insert into rooms values('0');
insert into rooms values('1');
insert into rooms values('2');
insert into rooms values('3');
insert into rooms values('4');
insert into rooms values('5');
insert into rooms values('6');
insert into rooms values('7');
insert into rooms values('8');
insert into rooms values('9');
insert into rooms values('10');
insert into rooms values('11');
insert into rooms values('12');
insert into rooms values('13');
insert into rooms values('14');
insert into rooms values('15');
insert into rooms values('16');
insert into rooms values('17');
insert into rooms values('18');
insert into rooms values('19');
insert into rooms values('20');
insert into rooms values('21');
insert into rooms values('22');
insert into rooms values('23');
insert into rooms values('24');
insert into rooms values('25');
insert into rooms values('26');
insert into rooms values('27');
insert into rooms values('28');
insert into rooms values('29');
insert into rooms values('30');
insert into rooms values('31');
insert into rooms values('32');
insert into rooms values('33');
insert into rooms values('34');
insert into rooms values('35');
insert into rooms values('36');
insert into rooms values('37');
insert into rooms values('38');
insert into rooms values('39');
insert into rooms values('40');
insert into rooms values('41');
insert into rooms values('42');
insert into rooms values('43');
insert into rooms values('44');
insert into rooms values('45');
insert into rooms values('46');
insert into rooms values('47');
insert into rooms values('48');
insert into rooms values('49');
insert into rooms values('50');
insert into rooms values('51');
insert into rooms values('52');
insert into rooms values('53');
insert into rooms values('54');
insert into rooms values('55');
insert into rooms values('56');
insert into rooms values('57');
insert into rooms values('58');
insert into rooms values('59');
insert into rooms values('60');
insert into rooms values('61');
insert into rooms values('62');
insert into rooms values('63');
insert into rooms values('64');
insert into rooms values('65');
insert into rooms values('66');
insert into rooms values('67');
insert into rooms values('68');
insert into rooms values('69');
insert into rooms values('70');
insert into rooms values('71');
insert into rooms values('72');
insert into rooms values('73');
insert into rooms values('74');
insert into rooms values('75');
insert into rooms values('76');
insert into rooms values('77');
insert into rooms values('78');
insert into rooms values('79');
insert into rooms values('80');
insert into rooms values('81');
insert into rooms values('82');
insert into rooms values('83');
insert into rooms values('84');
insert into rooms values('85');
insert into rooms values('86');
insert into rooms values('87');
insert into rooms values('88');
insert into rooms values('89');
insert into rooms values('90');
insert into rooms values('91');
insert into rooms values('92');
insert into rooms values('93');
insert into rooms values('94');
insert into rooms values('95');
insert into rooms values('96');
insert into rooms values('97');
insert into rooms values('98');
insert into rooms values('99');
insert into terms values('2022');
insert into Teachers values ('AKC','THURSDAY','2022','Mathematics');
insert into Teachers values ('DMS','WEDNESDAY','2022','Mathematics');
insert into Teachers values ('BL','SUNDAY','2022','English');
insert into Teachers values ('BS','TUESDAY','2022','English');
insert into schedules values ( 'A2B', '7', 'AKC', '2022', 'SUNDAY', '[2022-01-01 10:45:00, 2022-01-01 11:30:00)');
insert into schedules values ( 'A1B', '4', 'AKC', '2022', 'SUNDAY', '[2022-01-01 13:45:00, 2022-01-01 14:30:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'SUNDAY', '[2022-01-01 14:30:00, 2022-01-01 15:15:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'MONDAY', '[2022-01-02 10:00:00, 2022-01-02 10:45:00)');
insert into schedules values ( 'A1A', '35', 'AKC', '2022', 'MONDAY', '[2022-01-02 14:30:00, 2022-01-02 15:15:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'TUESDAY', '[2022-01-03 09:15:00, 2022-01-03 10:00:00)');
insert into schedules values ( 'A1A', '9', 'AKC', '2022', 'TUESDAY', '[2022-01-03 11:30:00, 2022-01-03 12:15:00)');
insert into schedules values ( 'A1B', '2', 'AKC', '2022', 'TUESDAY', '[2022-01-03 14:30:00, 2022-01-03 15:15:00)');
insert into schedules values ( 'A2A', '16', 'AKC', '2022', 'WEDNESDAY', '[2022-01-04 10:45:00, 2022-01-04 11:30:00)');
insert into schedules values ( 'A2A', '27', 'AKC', '2022', 'WEDNESDAY', '[2022-01-04 13:00:00, 2022-01-04 13:45:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'WEDNESDAY', '[2022-01-04 13:45:00, 2022-01-04 14:30:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'THURSDAY', '[2022-01-05 10:00:00, 2022-01-05 10:45:00)');
insert into schedules values ( 'A2B', '8', 'AKC', '2022', 'FRIDAY', '[2022-01-06 10:45:00, 2022-01-06 11:30:00)');
insert into schedules values ( '10A', '9', 'AKC', '2022', 'FRIDAY', '[2022-01-06 14:30:00, 2022-01-06 15:15:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'SUNDAY', '[2022-01-01 08:30:00, 2022-01-01 09:15:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'SUNDAY', '[2022-01-01 10:00:00, 2022-01-01 10:45:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'SUNDAY', '[2022-01-01 13:00:00, 2022-01-01 13:45:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'SUNDAY', '[2022-01-01 13:45:00, 2022-01-01 14:30:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'MONDAY', '[2022-01-02 09:15:00, 2022-01-02 10:00:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'MONDAY', '[2022-01-02 10:45:00, 2022-01-02 11:30:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'MONDAY', '[2022-01-02 12:15:00, 2022-01-02 13:00:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'MONDAY', '[2022-01-02 13:45:00, 2022-01-02 14:30:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'TUESDAY', '[2022-01-03 08:30:00, 2022-01-03 09:15:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'TUESDAY', '[2022-01-03 10:00:00, 2022-01-03 10:45:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'TUESDAY', '[2022-01-03 12:15:00, 2022-01-03 13:00:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'TUESDAY', '[2022-01-03 13:45:00, 2022-01-03 14:30:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'WEDNESDAY', '[2022-01-04 08:30:00, 2022-01-04 09:15:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'WEDNESDAY', '[2022-01-04 09:15:00, 2022-01-04 10:00:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'WEDNESDAY', '[2022-01-04 10:00:00, 2022-01-04 10:45:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'WEDNESDAY', '[2022-01-04 10:45:00, 2022-01-04 11:30:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'THURSDAY', '[2022-01-05 08:30:00, 2022-01-05 09:15:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'THURSDAY', '[2022-01-05 10:45:00, 2022-01-05 11:30:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'THURSDAY', '[2022-01-05 12:15:00, 2022-01-05 13:00:00)');
insert into schedules values ( '8D', '22', 'DMS', '2022', 'THURSDAY', '[2022-01-05 13:00:00, 2022-01-05 13:45:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'THURSDAY', '[2022-01-05 13:45:00, 2022-01-05 14:30:00)');
insert into schedules values ( '6C', '7', 'DMS', '2022', 'FRIDAY', '[2022-01-06 08:30:00, 2022-01-06 09:15:00)');
insert into schedules values ( '7C', '15', 'DMS', '2022', 'FRIDAY', '[2022-01-06 10:00:00, 2022-01-06 10:45:00)');
insert into schedules values ( '5B', '2', 'DMS', '2022', 'FRIDAY', '[2022-01-06 12:15:00, 2022-01-06 13:00:00)');
insert into schedules values ( '5C', '3', 'DMS', '2022', 'FRIDAY', '[2022-01-06 14:30:00, 2022-01-06 15:15:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'SUNDAY', '[2022-01-01 08:30:00, 2022-01-01 09:15:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'SUNDAY', '[2022-01-01 09:15:00, 2022-01-01 10:00:00)');
insert into schedules values ( '5A', '1', 'BL', '2022', 'SUNDAY', '[2022-01-01 10:00:00, 2022-01-01 10:45:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'SUNDAY', '[2022-01-01 10:45:00, 2022-01-01 11:30:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'MONDAY', '[2022-01-02 09:15:00, 2022-01-02 10:00:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'MONDAY', '[2022-01-02 10:45:00, 2022-01-02 11:30:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'MONDAY', '[2022-01-02 13:00:00, 2022-01-02 13:45:00)');
insert into schedules values ( '11A', '12', 'BL', '2022', 'MONDAY', '[2022-01-02 13:45:00, 2022-01-02 14:30:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'TUESDAY', '[2022-01-03 08:30:00, 2022-01-03 09:15:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'TUESDAY', '[2022-01-03 10:45:00, 2022-01-03 11:30:00)');
insert into schedules values ( '11A', '4', 'BL', '2022', 'TUESDAY', '[2022-01-03 11:30:00, 2022-01-03 12:15:00)');
insert into schedules values ( '5A', '1', 'BL', '2022', 'TUESDAY', '[2022-01-03 13:45:00, 2022-01-03 14:30:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'TUESDAY', '[2022-01-03 14:30:00, 2022-01-03 15:15:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'WEDNESDAY', '[2022-01-04 09:15:00, 2022-01-04 10:00:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'WEDNESDAY', '[2022-01-04 10:00:00, 2022-01-04 10:45:00)');
insert into schedules values ( '11A', '5', 'BL', '2022', 'WEDNESDAY', '[2022-01-04 13:45:00, 2022-01-04 14:30:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'WEDNESDAY', '[2022-01-04 14:30:00, 2022-01-04 15:15:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'THURSDAY', '[2022-01-05 08:30:00, 2022-01-05 09:15:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'THURSDAY', '[2022-01-05 10:00:00, 2022-01-05 10:45:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'THURSDAY', '[2022-01-05 12:15:00, 2022-01-05 13:00:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'THURSDAY', '[2022-01-05 13:00:00, 2022-01-05 13:45:00)');
insert into schedules values ( '5A', '1', 'BL', '2022', 'THURSDAY', '[2022-01-05 13:45:00, 2022-01-05 14:30:00)');
insert into schedules values ( '10D', '12', 'BL', '2022', 'FRIDAY', '[2022-01-06 08:30:00, 2022-01-06 09:15:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'FRIDAY', '[2022-01-06 10:00:00, 2022-01-06 10:45:00)');
insert into schedules values ( '8D', '22', 'BL', '2022', 'FRIDAY', '[2022-01-06 10:45:00, 2022-01-06 11:30:00)');
insert into schedules values ( '5B', '2', 'BL', '2022', 'FRIDAY', '[2022-01-06 13:45:00, 2022-01-06 14:30:00)');
insert into schedules values ( '5A', '1', 'BS', '2022', 'SUNDAY', '[2022-01-01 09:15:00, 2022-01-01 10:00:00)');
insert into schedules values ( 'A2C', '28', 'BS', '2022', 'SUNDAY', '[2022-01-01 10:00:00, 2022-01-01 10:45:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'SUNDAY', '[2022-01-01 10:45:00, 2022-01-01 11:30:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'SUNDAY', '[2022-01-01 13:45:00, 2022-01-01 14:30:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'SUNDAY', '[2022-01-01 14:30:00, 2022-01-01 15:15:00)');
insert into schedules values ( '5A', '1', 'BS', '2022', 'MONDAY', '[2022-01-02 09:15:00, 2022-01-02 10:00:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'MONDAY', '[2022-01-02 10:45:00, 2022-01-02 11:30:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'MONDAY', '[2022-01-02 13:45:00, 2022-01-02 14:30:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'MONDAY', '[2022-01-02 14:30:00, 2022-01-02 15:15:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'TUESDAY', '[2022-01-03 08:30:00, 2022-01-03 09:15:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'TUESDAY', '[2022-01-03 09:15:00, 2022-01-03 10:00:00)');
insert into schedules values ( 'A2C', '15', 'BS', '2022', 'TUESDAY', '[2022-01-03 10:00:00, 2022-01-03 10:45:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'TUESDAY', '[2022-01-03 10:45:00, 2022-01-03 11:30:00)');
insert into schedules values ( '5A', '1', 'BS', '2022', 'WEDNESDAY', '[2022-01-04 08:30:00, 2022-01-04 09:15:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'WEDNESDAY', '[2022-01-04 10:00:00, 2022-01-04 10:45:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'WEDNESDAY', '[2022-01-04 12:15:00, 2022-01-04 13:00:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'WEDNESDAY', '[2022-01-04 14:30:00, 2022-01-04 15:15:00)');
insert into schedules values ( '5A', '1', 'BS', '2022', 'THURSDAY', '[2022-01-05 08:30:00, 2022-01-05 09:15:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'THURSDAY', '[2022-01-05 10:00:00, 2022-01-05 10:45:00)');
insert into schedules values ( 'A2C', '21', 'BS', '2022', 'THURSDAY', '[2022-01-05 11:30:00, 2022-01-05 12:15:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'THURSDAY', '[2022-01-05 13:00:00, 2022-01-05 13:45:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'THURSDAY', '[2022-01-05 13:45:00, 2022-01-05 14:30:00)');
insert into schedules values ( '10C', '11', 'BS', '2022', 'FRIDAY', '[2022-01-06 08:30:00, 2022-01-06 09:15:00)');
insert into schedules values ( '5A', '1', 'BS', '2022', 'FRIDAY', '[2022-01-06 10:00:00, 2022-01-06 10:45:00)');
insert into schedules values ( '7C', '15', 'BS', '2022', 'FRIDAY', '[2022-01-06 12:15:00, 2022-01-06 13:00:00)');
insert into schedules values ( '6C', '7', 'BS', '2022', 'FRIDAY', '[2022-01-06 13:45:00, 2022-01-06 14:30:00)');
insert into Students values ('BDKB8','Tejaswani Samuel','A2B');
insert into Students values('BDK0E','Madhavi Garde','A1B');
insert into Students values('BDK81','Gulab Jaggi','10A');
insert into Students values('BDKBI','Nupoor Saraf','A1A');
insert into Students values('BDK66','Jamshed Tak','7C');
insert into Students values('BDKXO','Abhinav Garde','5C');
insert into Students values('BDK6M','Aayushi Subramaniam','6C');
insert into Students values('BDKV4','Darpan Chopra','5B');
insert into Students values('BDKS4','Jagat Chohan','8D');
insert into Students values('BDKUX','Satishwar Sagar','5A');
insert into Students values('BDKF6','Sid Roy','10D');
insert into Students values('BDK50','Saurabh Vora','11A');
insert into Students values('BDKDB','Trishana Barman','A2C');
insert into Students values('BDKR6','Baalkrishan Patil','10C');
insert into Students values('BDKNR','Neerendra Varghese','A2B');
insert into Students values('BDKOW','Ricky Kaur','A1B');
insert into Students values('BDKZ9','Kajal Gupta','10A');
insert into Students values('BDKOP','Malik Arya','A1A');
insert into Students values('BDKV2','Aisha Sarin','7C');
insert into Students values('BDKZJ','Neerendra Chhabra','5C');
insert into Students values('BDKU7','Emran Karnik','6C');
insert into Students values('BDKLY','Rehman Sabharwal ','5B');
insert into Students values('BDKUN','Mehul Gobin','8D');
insert into Students values('BDK9F','Preshita Nadkarni','5A');
insert into Students values('BDKFE','Pirzada Dhingra','10D');
insert into Students values('BDKI7','Sheetal Reddy','11A');
insert into Students values('BDK27','Aarif Purohit','A2C');
insert into Students values('BDKS1','Divya Boase','10C');
insert into Students values('BDK1C','Farah Munshi','A2B');
insert into Students values('BDKFG','Sirish Deshpande','A1B');
insert into Students values('BDKBS','Bhaagyasree Dave ','10A');
insert into Students values('BDK3X','Alka Kumer','A1A');
insert into Students values('BDKMA','Yasmin Maharaj','7C');
insert into Students values('BDKBQ','Hina Garde','5C');
insert into Students values('BDK9D','Samir Mahajan','6C');
insert into Students values('BDKMT','Jagat Dugal ','5B');
insert into Students values('BDK8H','Preshita Samra','8D');
insert into Students values('BDK8Z','Binita Ramakrishnan','5A');
insert into Students values('BDKIX','Rajendra Morar','10D');
insert into Students values('BDKWG','Venkat Khan','11A');
insert into Students values('BDK3F','Radhe Tiwari','A2C');
insert into Students values('BDK58','Sneha Chohan','10C');

insert into subjects values ('Compulsary Mathematics', false, '2022', '5A');
insert into subjects values ('Optional Mathematics', false, '2022', '5A');
insert into subjects values ('English', false, '2022', '5A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '5B');
insert into subjects values ('Optional Mathematics', false, '2022', '5B');
insert into subjects values ('English', false, '2022', '5B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '5C');
insert into subjects values ('Optional Mathematics', false, '2022', '5C');
insert into subjects values ('English', false, '2022', '5C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '5D');
insert into subjects values ('Optional Mathematics', false, '2022', '5D');
insert into subjects values ('English', false, '2022', '5D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '6A');
insert into subjects values ('Optional Mathematics', false, '2022', '6A');
insert into subjects values ('English', false, '2022', '6A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '6B');
insert into subjects values ('Optional Mathematics', false, '2022', '6B');
insert into subjects values ('English', false, '2022', '6B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '6C');
insert into subjects values ('Optional Mathematics', false, '2022', '6C');
insert into subjects values ('English', false, '2022', '6C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '6D');
insert into subjects values ('Optional Mathematics', false, '2022', '6D');
insert into subjects values ('English', false, '2022', '6D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '7A');
insert into subjects values ('Optional Mathematics', false, '2022', '7A');
insert into subjects values ('English', false, '2022', '7A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '7B');
insert into subjects values ('Optional Mathematics', false, '2022', '7B');
insert into subjects values ('English', false, '2022', '7B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '7C');
insert into subjects values ('Optional Mathematics', false, '2022', '7C');
insert into subjects values ('English', false, '2022', '7C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '7D');
insert into subjects values ('Optional Mathematics', false, '2022', '7D');
insert into subjects values ('English', false, '2022', '7D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '8A');
insert into subjects values ('Optional Mathematics', false, '2022', '8A');
insert into subjects values ('English', false, '2022', '8A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '8B');
insert into subjects values ('Optional Mathematics', false, '2022', '8B');
insert into subjects values ('English', false, '2022', '8B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '8C');
insert into subjects values ('Optional Mathematics', false, '2022', '8C');
insert into subjects values ('English', false, '2022', '8C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '8D');
insert into subjects values ('Optional Mathematics', false, '2022', '8D');
insert into subjects values ('English', false, '2022', '8D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '9A');
insert into subjects values ('Optional Mathematics', false, '2022', '9A');
insert into subjects values ('English', false, '2022', '9A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '9B');
insert into subjects values ('Optional Mathematics', false, '2022', '9B');
insert into subjects values ('English', false, '2022', '9B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '9C');
insert into subjects values ('Optional Mathematics', false, '2022', '9C');
insert into subjects values ('English', false, '2022', '9C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '9D');
insert into subjects values ('Optional Mathematics', false, '2022', '9D');
insert into subjects values ('English', false, '2022', '9D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '10A');
insert into subjects values ('Optional Mathematics', false, '2022', '10A');
insert into subjects values ('English', false, '2022', '10A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '10B');
insert into subjects values ('Optional Mathematics', false, '2022', '10B');
insert into subjects values ('English', false, '2022', '10B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '10C');
insert into subjects values ('Optional Mathematics', false, '2022', '10C');
insert into subjects values ('English', false, '2022', '10C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '10D');
insert into subjects values ('Optional Mathematics', false, '2022', '10D');
insert into subjects values ('English', false, '2022', '10D');
insert into subjects values ('Compulsary Mathematics', false, '2022', '11A');
insert into subjects values ('Optional Mathematics', false, '2022', '11A');
insert into subjects values ('English', false, '2022', '11A');
insert into subjects values ('Compulsary Mathematics', false, '2022', '11B');
insert into subjects values ('Optional Mathematics', false, '2022', '11B');
insert into subjects values ('English', false, '2022', '11B');
insert into subjects values ('Compulsary Mathematics', false, '2022', '11C');
insert into subjects values ('Optional Mathematics', false, '2022', '11C');
insert into subjects values ('English', false, '2022', '11C');
insert into subjects values ('Compulsary Mathematics', false, '2022', '11D');
insert into subjects values ('Optional Mathematics', false, '2022', '11D');
insert into subjects values ('English', false, '2022', '11D');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A1A');
insert into subjects values ('Optional Mathematics', false, '2022', 'A1A');
insert into subjects values ('English', false, '2022', 'A1A');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A1B');
insert into subjects values ('Optional Mathematics', false, '2022', 'A1B');
insert into subjects values ('English', false, '2022', 'A1B');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A2A');
insert into subjects values ('Optional Mathematics', false, '2022', 'A2A');
insert into subjects values ('English', false, '2022', 'A2A');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A2B');
insert into subjects values ('Optional Mathematics', false, '2022', 'A2B');
insert into subjects values ('English', false, '2022', 'A2B');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A1C');
insert into subjects values ('Optional Mathematics', false, '2022', 'A1C');
insert into subjects values ('English', false, '2022', 'A1C');
insert into subjects values ('Compulsary Mathematics', false, '2022', 'A2C');
insert into subjects values ('Optional Mathematics', false, '2022', 'A2C');
insert into subjects values ('English', false, '2022', 'A2C');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '5A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '5A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '5A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '5A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '5B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '5B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '5B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '5B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '5C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '5C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '5C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '5C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '5D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '5D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '5D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '5D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '6A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '6A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '6A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '6A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '6B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '6B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '6B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '6B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '6C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '6C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '6C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '6C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '6D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '6D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '6D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '6D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '7A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '7A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '7A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '7A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '7B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '7B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '7B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '7B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '7C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '7C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '7C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '7C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '7D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '7D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '7D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '7D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '8A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '8A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '8A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '8A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '8B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '8B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '8B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '8B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '8C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '8C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '8C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '8C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '8D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '8D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '8D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '8D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '9A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '9A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '9A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '9A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '9B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '9B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '9B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '9B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '9C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '9C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '9C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '9C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '9D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '9D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '9D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '9D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '10A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '10A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '10A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '10A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '10B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '10B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '10B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '10B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '10C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '10C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '10C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '10C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '10D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '10D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '10D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '10D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '11A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '11A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '11A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '11A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '11B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '11B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '11B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '11B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '11C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '11C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '11C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '11C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', '11D', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', '11D', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', '11D', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', '11D', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A1A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A1A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A1A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A1A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A1B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A1B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A1B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A1B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A2A', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A2A', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A2A', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A2A', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A2B', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A2B', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A2B', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A2B', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A1C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A1C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A1C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A1C', '2022');
insert into Teachers_know values ('AKC', 'Compulsary Mathematics', 'A2C', '2022');
insert into Teachers_know values ('DMS', 'Optional Mathematics', 'A2C', '2022');
insert into Teachers_know values ('BS', 'Optional Mathematics', 'A2C', '2022');
insert into Teachers_know values ('BL', 'Optional Mathematics', 'A2C', '2022');
