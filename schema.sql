drop table if exists Schedule, Terms, Lessons, Rooms, Departments, Subjects, Grades, Students, Terms, Teachers;
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
create table Terms (
	year integer primary key,
	CHECK ( year > 2021 )
);

/* entity set Lessons */
create table Lessons (
	day DAYS,
	time tsrange,
	primary key (day, time),
	is_lunch boolean,
	is_assembly boolean,
	exclude using gist (time with &&) /* have non-overlapping range only for lessons */
);

/* entity set Grades
with relationship sets Lunch and Assembly */
create table Grades (
	name char(32) primary key,
	lunch_day DAYS 
		not null	/* must have lunch */
		unique, /* only one lunch lesson per day */
	lunch_time tsrange
		not null,
	foreign key (lunch_day, lunch_time) references Lessons(day, time),
	assembly_day DAYS
		not null
		unique,
	assembly_time tsrange
		not null,
	foreign key (assembly_day, assembly_time) references Lessons(day, time)
);

/* entity set Students 
with relationship set attend */
create table Students (
	id integer primary key,
	attend char(32) references Grades(name) 
		not null	/* total participation */
);

/* entity set Departments */
create table Departments (
	name char(32) primary key
);

/* Teachers entity set
with relationship set Works_in */
create table Teachers (
	initials char(32) primary key,
	half_day DAYS not null,
	term int references Terms(year) not null,
	department char(32) references Departments(name) not null
);

/* entity set Rooms */
create table Rooms (
	name char(32) primary key
);

/* entity set Subjects */
create table Subjects (
	name char(32),
	double_lesson boolean default false,
	term int not null,
	grade char(32) not null,
	primary key (name, grade, term),
	foreign key (grade) references Grades(name) on delete cascade,
	foreign key (term) references Terms(year) on delete cascade
);

/* relationship set Schedule */
create table Schedule (
	grade char(32) references Grades(name) not null,
	room char(32) references Rooms(name) not null,
	teacher char(32) references Teachers(initials) not null,
	term int references Terms(year) not null,
	day DAYS not null,
	time tsrange not null,
	foreign key (day, time) references Lessons (day, time),
	UNIQUE(day, time, teacher, term), /* one teacher teaches only one lesson at a time */
	UNIQUE(day, time, room, term), /* one room hosts only one lesson at a time */
	UNIQUE(day, time, grade, term) /* one grade can attend only one lesson at a time */
);
