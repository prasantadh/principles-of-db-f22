drop table if exists Schedule, Terms, Lessons, Lunch, Rooms, Departments, Subjects, Grades, Students, Terms, Teachers;
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

/* relationship set Schedule */
--populated
create table Schedule (
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
