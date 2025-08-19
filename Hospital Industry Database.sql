
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
	AS ENUM('Trying to quit', 'Used to smoke', 'Doesn''t Smoke');

CREATE TYPE alcohol_usage
	AS ENUM('Doesn''t Drink', 'Monthly', 'Weekly', 'Daily')

CREATE TYPE exercise_amount
	AS ENUM('Sedentary', 'Daily', 'Weekly', 'Monthly');

CREATE TYPE dietary_type
	AS ENUM('Standard Western Diet', 'Vegan', 'Vegetarian', 'Pescatarian', 'Carnivore');

CREATE TYPE recreational_usage
	AS ENUM('Opioids', 'Cannabis', 'Stimulants', 'Depressants', 'Hallucinogens', 'Dissociatives', 'Inhalants');

CREATE TYPE country
	AS ENUM('England', 'Wales', 'Northern Ireland', 'Scotland');

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

CREATE TABLE illness_type(

	illness_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	desc TEXT NOT NULl
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
	telephone VARCHAR(11) NOT NULL,
	email VARCHAR(255) NOT NULL
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
	

)

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	address_id INT NOT NULL REFERENCES address(address_id),
	nhs_staff_id VARCHAR(20) NOT NULL UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	middle_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	telephone VARCHAR(11) NOT NULL,
	email VARCHAR(255) NOT NULL,
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

