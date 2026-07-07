CREATE TABLE city(
	city_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);

CREATE TABLE address(
	address_id SERIAL PRIMARY KEY,
	city_id INT NOT NULL REFERENCES city(city_id),
	country country NOT NULL,
	address_line_1 VARCHAR(150) NOT NULL,
	address_line_2 VARCHAR(150),
	postcode VARCHAR(8) NOT NULL,
	direction direction NOT NULL,
	address_type address_type NOT NULL
);

CREATE TABLE department(
	department_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT NOT NULL
);

CREATE TABLE intervention_type(
	intervention_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT NOT NULL
);

CREATE TABLE intervention(
	intervention_id SERIAL PRIMARY KEY,
	intervention_type_id INT NOT NULL REFERENCES intervention_type(intervention_type_id),
	name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT NOT NULL
);

CREATE TABLE illness_type(
	illness_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT NOT NULl
);

CREATE TABLE illness(
	illness_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE,
	severity severity NOT NULL,
	description TEXT NOT NULL
);

CREATE TABLE illness_types(
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	illness_type_id INT NOT NULL REFERENCES illness_type(illness_type_id),
	PRIMARY KEY(illness_id, illness_type_id)
);

CREATE TABLE profession(
	profession_id SERIAL PRIMARY KEY,
	department_id INT NOT NULL REFERENCES department(department_id),
	name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT
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
	email VARCHAR(255) NOT NULL UNIQUE,
	PRIMARY KEY(hospital_id, department_id)
);

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	address_id INT NOT NULL REFERENCES address(address_id),
	nhs_staff_id VARCHAR(20) NOT NULL UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	middle_name VARCHAR(50),
	last_name VARCHAR(50) NOT NULL,
	telephone VARCHAR(11) NOT NULL UNIQUE,
	personal_email VARCHAR(255) NOT NULL UNIQUE,
	work_email VARCHAR(255) NOT NULL UNIQUE,
	sex sex NOT NULL,
	date_of_birth DATE NOT NULL
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

CREATE TABLE shift(
	shift_id SERIAL PRIMARY KEY,
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	shift_date DATE NOT NULL,
	shift_start TIME NOT NULL,
	shift_end TIME NOT NULL,
	clocked_in TIME,
	clocked_out TIME
);

CREATE TABLE recreation(
	recreation_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
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
	sex sex NOT NULL,
	date_of_birth DATE NOT NULL
);

CREATE TABLE patient_lifestyle(
	patient_lifestyle_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	smoking_usage smoking_usage NOT NULL,
	smoking_amount SMALLINT,
	alcohol_usage alcohol_usage NOT NULL,
	alcohol_amount NUMERIC(4,1),
	exercise_amount exercise_amount NOT NULL,
	dietary_type dietary_type NOT NULL,
	notes TEXT,
	date_confirmed DATE NOT NULL
);

CREATE TABLE patient_recreational_usage(
	patient_lifestyle_id INT NOT NULL REFERENCES patient_lifestyle(patient_lifestyle_id),
	recreation_id INT NOT NULL REFERENCES recreation(recreation_id),
	recreation_amount alcohol_usage NOT NULL,
	PRIMARY KEY(patient_lifestyle_id, recreation_id)
);

CREATE TABLE patient_indicator(
	patient_indicator_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	hdl NUMERIC(5,2),
	ldl NUMERIC(5,2),
	triglycerides NUMERIC(5,2),
	total_cholesterol NUMERIC(5,2),
	systolic SMALLINT,
	diastolic SMALLINT,
	blood_sugar NUMERIC(5,2),
	weight_kg NUMERIC(5,2),
	height_cm NUMERIC(5,2),
	date_confirmed DATE NOT NULL
);

CREATE TABLE patient_illness(
	patient_illness_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	condition condition NOT NULL,
	findings TEXT
);

CREATE TABLE ward(
	ward_id SERIAL PRIMARY KEY,
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	department_id INT NOT NULL REFERENCES department(department_id),
	name VARCHAR(5) NOT NULL 
);

CREATE TABLE hospitalized(
	hospitalization_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	ward_id INT NOT NULL REFERENCES ward(ward_id),
	patient_status patient_status NOT NULL,
	checked_in TIMESTAMP NOT NULL,
	checked_out TIMESTAMP
);

CREATE TABLE hospitalization_cause(
	hospitalization_id INT NOT NULL REFERENCES hospitalized(hospitalization_id),
	symptom_id INT NOT NULL REFERENCES illness(illness_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	PRIMARY KEY(hospitalization_id, symptom_id)
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
	appointment_result_id SERIAL PRIMARY KEY,
	appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
	illness_id INT NOT NULL REFERENCES illness(illness_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	notes TEXT,
	confirmed_date DATE
);

CREATE TABLE finding(
	finding_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE appointment_result_finding(
	appointment_result_id INT NOT NULL REFERENCES appointment_result(appointment_result_id),
	finding_id INT NOT NULL REFERENCES finding(finding_id),
	PRIMARY KEY(appointment_result_id, finding_id)
);

CREATE TABLE symptom(
	symptom_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE appointment_symptom(
	appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
	symptom_id INT NOT NULL REFERENCES symptom(symptom_id),
	PRIMARY KEY(appointment_id, symptom_id)
);

CREATE TABLE feedback(
	feedback_id SERIAL PRIMARY KEY,
	reviewer_id INT REFERENCES staff(staff_id),
	staff_id INT REFERENCES staff(staff_id),
	patient_id INT REFERENCES patient(patient_id),
	feedback_type positive_negative NOT NULL,
	feedback_status feedback_status NOT NULL,
	notes TEXT NOT NULL,
	verified BOOL DEFAULT FALSE
);

CREATE TABLE staff_performance(
	performance_id SERIAL PRIMARY KEY,
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	feedback_id INT REFERENCES feedback(feedback_id),
	shift_id INT REFERENCES shift(shift_id),
	performance_type positive_negative NOT NULL,
	performance_desc TEXT NOT NULL
);

CREATE TABLE stock_type(
	stock_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE stock(
	stock_id SERIAL PRIMARY KEY,
	stock_type_id INT NOT NULL REFERENCES stock_type(stock_type_id),
	name VARCHAR(100) NOT NULL UNIQUE,
	description TEXT NOT NULL
);

CREATE TABLE hospital_stock(
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	stock_id INT NOT NULL REFERENCES stock(stock_id),
	total_amount INT NOT NULL,
	PRIMARY KEY(hospital_id, stock_id)
);

CREATE TABLE appointment_stock(
	appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
	stock_id INT NOT NULL REFERENCES stock(stock_id),
	amount_used SMALLINT NOT NULL,
	PRIMARY KEY(appointment_id, stock_id)
);

CREATE TABLE prescription(
	prescription_id SERIAL PRIMARY KEY,
	stock_id INT NOT NULL REFERENCES stock(stock_id),
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	hospital_id INT NOT NULL REFERENCES hospital(hospital_id),
	amount_used SMALLINT NOT NULL
);