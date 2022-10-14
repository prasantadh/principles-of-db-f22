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

/* entity set Term -- done */
drop table if exists Terms;
create table Terms (
	year integer primary key,
	CHECK ( year > 2021 )
);

create table Lessons (
	day DAYS,
	time tsrange,
	primary key (day, time),
	is_lunch boolean,
	is_assembly boolean,
	exclude using gist (time with &&) /* have non-overlapping range only for lessons */
);

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

/* Students entity set -- done */
create table Students (
	id integer primary key,
	attend char(32) references Grades(name) 
		not null	/* total participation */
);

/* Departments entity set -- DONE */
create table Departments (
	name char(32) primary key
);

/* Teachers entity set -- done */
create table Teachers (
	initials char(32) primary key,
	half_day DAYS not null,
	term int references Terms(year) not null,
	department char(32) references Departments(name) not null
);

/* Rooms entity set -- done */
create table Rooms (
	name char(32) primary key
);

/* Subjects entity set -- done */
create table Subjects (
	name char(32),
	double_lesson boolean default false,
	grade char(32) references Grades(name) not null,
	primary key (name, grade),
	foreign key (grade) references Grades(name) on delete cascade
);

create table Schedule (
	grade char(32) references Grades(name) not null,
	room char(32) references Rooms(name) not null,
	teacher char(32) references Teachers(initials) not null,
	day DAYS not null,
	time tsrange not null,
	foreign key (day, time) references Lessons (day, time),
	UNIQUE(day, time, teacher), /* one teacher teaches only one lesson at a time */
	UNIQUE(day, time, room), /* one room hosts only one lesson at a time */
	UNIQUE(day, time, grade) /* one grade can attend only one lesson at a time */
);
