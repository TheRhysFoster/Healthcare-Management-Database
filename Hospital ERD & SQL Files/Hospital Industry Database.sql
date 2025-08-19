-- ******************************** ENUM CREATION STARTS HERE ******************************** --

CREATE TYPE time_type
	AS ENUM('Full-Time', 'Part-Time', 'On-Call');

CREATE TYPE employment_type
	AS ENUM('Permanent', 'Temporary', 'Contractor');

CREATE TYPE direction
	AS ENUM('South East', 'North East', 'South West', 'North West');

CREATE TYPE patient_status
	AS ENUM('Under Treatment', 'End of Life Care', 'Deceased', 'Discharged');

CREATE TYPE severity
	AS ENUM('Low Mortality', 'Medium Mortality', 'High Mortality');

CREATE TYPE illness_status
	AS ENUM('Improved', 'Worsened', 'Cured');

CREATE TYPE smoking_usage
	AS ENUM('Trying to quit', 'Used to smoke', 'None');

CREATE TYPE alcohol_usage
	AS ENUM('None', 'Monthly', 'Weekly', 'Daily')

CREATE TYPE exercise_amount
	AS ENUM('Sedentary', 'Daily', 'Weekly', 'Monthly');

CREATE TYPE dietary_type
	AS ENUM('Standard Western Diet', 'Vegan', 'Vegetarian', 'Pescatarian', 'Carnivore');

CREATE TYPE recreational_usage
	AS ENUM('None', 'Opioids', 'Cannabis', 'Stimulants', 'Depressants', 'Hallucinogens', 'Dissociatives', 'Inhalants');

CREATE TYPE country
	AS ENUM('England', 'Wales', 'Northern Ireland', 'Scotland');

CREATE TYPE appointment_status
	AS ENUM('Cancelled', 'Did not attend', 'Attended', 'Rescheduled');

-- ******************************** ENUM CREATION ENDS HERE ******************************** --



-- ******************************** TABLE CREATION STARTS HERE ******************************** --

CREATE TABLE city(
	city_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE department(
	department_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	desc TEXT NOT NULL
);

CREATE TABLE intervention_type(
	intervention_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	desc TEXT NOT NULL
);

CREATE TABLE intervention(
	intervention_id SERIAL PRIMARY KEY,
	intervention_type_id INT NOT NULL REFERENCES intervention_type(intervention_type_id),
	name VARCHAR(50) NOT NULL,
	desc TEXT NOT NULL
);

CREATE TABLE illness_type(
	illness_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	desc TEXT NOT NULl
);

CREATE TABLE illness(
	illness_id SERIAL PRIMARY KEY,
	illness_type_id INT NOT NULL REFERENCES illness_type(illness_type_id),
	severity severity NOT NULL,
	desc TEXT NOT NULL
);

CREATE TABLE profession(
	profession_id SERIAL PRIMARY KEY,
	department_id INT NOT NULL REFERENCES department(department_id),
	name VARCHAR(50) NOT NULL,
	desc TEXT
);

CREATE TABLE hospital(
	hospital_id SERIAL PRIMARY KEY,
	address_id INT NOT NULL REFERENCES address(address_id),
	nhs_hosp_id VARCHAR(20) NOT NULL UNIQUE,
	name VARCHAR(100) NOT NULL,
	telephone VARCHAR(11) NOT NULL UNIQUE,
	email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE hospital_department(
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	department_id INT NOT NULL REFERENCES department(department_id),
	extension VARCHAR(5) NOT NULL,
	email VARCHAR(255) NOT NULL,
	PRIMARY KEY(hospital_id, department_id)
);

CREATE TABLE staff_profession(
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	profession_id INT NOT NULL REFERENCES profession(profession_id),
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	yearly_salary NUMERIC(8,2) NOT NULL,
	time_type time_type NOT NULL,
	employment_type employment_type NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE,
	PRIMARY KEY(staff_id, profession_id, hospital_id)
);

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	address_id INT NOT NULL REFERENCES address(address_id),
	nhs_staff_id VARCHAR(20) NOT NULL UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	middle_name VARCHAR(50),
	last_name VARCHAR(50) NOT NULL,
	telephone VARCHAR(11) NOT NULL UNIQUE,
	email VARCHAR(255) NOT NULL UNIQUE,
	date_of_birth DATE NOT NULL
);

CREATE TABLE address(
	address_id SERIAL PRIMARY KEY,
	city_id INT NOT NULL REFERENCES city(city_id),
	country country NOT NULL,
	address_line_1 VARCHAR(150) NOT NULL,
	address_line_2 VARCHAR(150),
	postcode VARCHAR(8) NOT NULL,
	direction direction NOT NULL
);

CREATE TABLE patient(
	patient_id SERIAL PRIMARY KEY,
	address_id INT NOT NULL REFERENCES address(address_id),
	nhs_number VARCHAR(10) NOT NULL UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	middle_name VARCHAR(50),
	last_name VARCHAR(50) NOT NULL,
	telephone VARCHAR(11),
	email VARCHAR(255) NOT NULL UNIQUE,
	date_of_birth DATE NOT NULL
);

CREATE TABLE patient_lifestyle(
	patient_lifestyle_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	smoking_usage smoking_usage NOT NULL,
	smoking_amount SMALLINT,
	alcohol_usage alcohol_usage NOT NULL,
	alcohol_amount NUMERIC(4,1),
	recreational_usage recreational_usage NOT NULL,
	exercise_amount exercise_amount NOT NULL,
	dietary_type dietary_type NOT NULL,
	notes TEXT
);

CREATE TABLE patient_medical(
	patient_medical_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	illness_status illness_status NOT NULL,
	notes TEXT
);

CREATE TABLE hospitalized(
	hospitalization_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	patient_status patient_status NOT NULL,
	checked_in TIMESTAMP NOT NULL,
	checked_out TIMESTAMP
);

CREATE TABLE hospitalization_cause(
	hospitalization_id INT NOT NULL REFERENCES hospitalized(hospitalization_id),
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	PRIMARY KEY(hospitalization_id, illness_id)
);

CREATE TABLE appointment(
	appointment_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	department_id INT NOT NULL REFERENCES department(department_id),
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	intervention_id INT NOT NULL REFERENCES intervention(intervention_id),
	notes TEXT,
	appointment_date TIMESTAMP NOT NULL,
	appointment_status appointment_status
);

CREATE TABLE staff_appointment(
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
	PRIMARY KEY(staff_id, appointment_id)
);

CREATE TABLE appointment_result(
	appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	notes TEXT,
	confirmed_date TIMESTAMP,
	PRIMARY KEY(appointment_id, illness_id)
);

-- ******************************** TABLE CREATION ENDS HERE ******************************** --