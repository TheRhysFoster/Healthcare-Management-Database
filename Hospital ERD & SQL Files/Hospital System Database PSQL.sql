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

CREATE TYPE positive_negative
	AS ENUM('Positive', 'Negative');


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
	shift_start TIMESTAMP NOT NULL,
	shift_end TIMESTAMP NOT NULL,
	clocked_in TIMESTAMP,
	clocked_out TIMESTAMP
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

CREATE TABLE patient_indicator(
	patient_indicator_id SERIAL PRIMARY KEY,
	patient_id INT NOT NULL REFERENCES patient(patient_id),
	hdl NUMERIC(5,2) NOT NULL,
	ldl NUMERIC(5,2) NOT NULL,
	triglycerides NUMERIC(5,2) NOT NULL,
	total_cholesterol NUMERIC(5,2) NOT NULL,
	systolic SMALLINT NOT NULL,
	diastolic SMALLINT NOT NULL,
	blood_sugar NUMERIC(5,2),
	weight_kg NUMERIC(5,2),
	height NUMERIC(5,2),
	date_taken DATE
);

CREATE TABLE patient_illness(
	patient_illness_id SERIAL PRIMARY KEY,
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

CREATE TABLE feedback(
	feedback_id SERIAL PRIMARY KEY,
	respondent_id INT NOT NULL REFERENCES staff(staff_id),
	staff_id INT REFERENCES staff(staff_id),
	patient_id INT REFERENCES patient(patient_id),
	feedback_type positive_negative NOT NULL,
	notes TEXT NOT NULL,
	verified BOOL DEFAULT FALSE
);

CREATE TABLE staff_performance(
	performance_id SERIAL PRIMARY KEY,
	staff_id INT NOT NULL REFERENCES staff(staff_id),
	performance_type postive_negative NOT NULL,
	performance_desc TEXT NOT NULL
);

-- ******************************** TABLE CREATION ENDS HERE ******************************** --



-- ******************************** DATA INSERTION STARTS HERE ******************************** --

INSERT INTO 
	city(name)
		VALUES
			('Bath'),
			('Birmingham'),
			('Bradford'),
			('Brighton & Hove'),
			('Bristol'),
			('Cambridge'),
			('Canterbury'),
			('Carlisle'),
			('Chelmsford'),
			('Chester'),
			('Chichester'),
			('Colchester'),
			('Coventry'),
			('Derby'),
			('Doncaster'),
			('Durham'),
			('Ely'),
			('Exeter'),
			('Gloucester'),
			('Hereford'),
			('Kingston upon Hull'),
			('Lancaster'),
			('Leeds'),
			('Leicester'),
			('Lichfield'),
			('Lincoln'),
			('Liverpool'),
			('City of London'),
			('Manchester'),
			('Milton Keynes'),
			('Newcastle upon Tyne'),
			('Norwich'),
			('Nottingham'),
			('Oxford'),
			('Peterborough'),
			('Plymouth'),
			('Portsmouth'),
			('Preston'),
			('Ripon'),
			('Salford'),
			('Salisbury'),
			('Sheffield'),
			('Southampton'),
			('Southend-on-Sea'),
			('St Albans'),
			('Stoke-on-Trent'),
			('Sunderland'),
			('Truro'),
			('Wakefield'),
			('Wells'),
			('Westminster'),
			('Winchester'),
			('Wolverhampton'),
			('Worcester'),
			('York'),
			('Bangor'),
			('Cardiff'),
			('Newport'),
			('St Asaph'),
			('St Davids'),
			('Swansea'),
			('Wrexham'),
			('Aberdeen'),
			('Dundee'),
			('Dunfermline'),
			('Edinburgh'),
			('Glasgow'),
			('Inverness'),
			('Perth'),
			('Stirling'),
			('Belfast'),
			('Londonderry'),
			('Lisburn'),
			('Newry'),
			('Armagh'),
			('Bangor');

INSERT INTO
	department(name, desc)
		VALUES
			('Accident & Emergency', 'Department handling accidents and emergency illnesses'),
			('Cardiology', 'Department focusing on heart health'),
			('Oncology', 'Department focusing on cancer treatment'),
			('Neurology', 'Department focusing on brain health'),
			('Radiology', 'Department focusing on CT, MRI, Ultrasound & X-Ray for diagnostic purposes'),
			('Gastroenterology', 'Department focusing on digestive health');

INSERT INTO
	intervention_type(name, desc)
		VALUES
			('Surgery', 'Covers any surgical operation of the body'),
			('Ultrasound', 'Creates internal images of body using high frequency sound waves'),
			('Magnetic Resonance Imaging (MRI)', 'Creates internal images of body using magnets and radio waves'),
			('Computed Tomography (CT)', 'Creates internal images of the body using multiple x-ray shots'),
			('X-Ray', 'Creates internal image of organs'),
			('Blood / Lipid', 'Any procedure that involves blood analysis'),
			('Injection / Drips', 'Any type of injection (IM, SC, IV, ID)');

INSERT INTO
	intervention(invervention_id, intervention_type_id, name, desc)
		VALUES
			(1, 1, 'Heart Transplant', 'Replacing a failing heart with a healthier organ'), #Heart Surgery
			(2, 1, 'Coronary Artery Stent', 'Placing a stent in the one or more heart arteries due to blockage / plaque build up'), #Heart Surgery
			(3, 1, 'Valve Repair', 'Repairing one or more heart valves'), #Heart Surgery
			(4, 1, 'Lung Transplant', 'Replacing one or more lungs with a healthier organ'), #Lung Surgery
			(5, 1, 'Lobectomy', 'Removing a lobe of the lung'), #Lung Surgery
			(6, 1, 'Pneumonectomy', 'Removal of one lung'), #Lung Surgery
			(7, 1, 'Craniotomy', 'Skull opening for access to the brain'), #Brain Surgery
			(8, 1, 'Aneurysm Clipping', 'Isolating a brain aneurysm'), #Brain Surgery
			(9, 1, 'Brain Tumor Removal', 'Removal of a tumour in the brain'), #Brain Surgery
			(10, 2, 'Aortic Ultrasound', 'Scan of the aorta for abnormalities'), #Aorta Ultrasound
			(11, 2, 'Penile Ultrasound', 'Scan of the penis for abnormalities'), #Penile Ultrasound
			(12, 2, 'Neck Ultrasound', 'Scan of the neck for neck and throat abnormalities'), #Neck Ultrasound
			(13, 3, 'Head MRI', 'Scan of the head for brain and neck abnormalities'), #Head MRI
			(14, 4, 'Head CT', 'Scan of the head for brain and neck abnormalities'), #Head MRI
			(15, 4, 'Chest CT', 'Scan of the chest to look for lung and heart abnormalities'), #Chest CT
			(16, 5, 'Chest X-Ray', 'Scan of the chest to look for lung and heart abnormalities'), #Chest X-Ray
			(17, 6, 'Blood Draw', 'Withdrawal of blood for analysis to look for abnormal values'), #Blood Draw
			(18, 7, 'Chemotherapy Drip', 'Insertion of chemotherapy solution as a treatment for cancer'), #Chemotherapy Drip
			(19, 7, 'Nutrient Drip', 'Insertion of nutrients to nourish patients unable to digest food and drink'); #Nutrient Drip

INSERT INTO
	illness_type(name, desc)
		VALUES
			('Cardiovascular', 'Issues involving the heart'),
			('Neurological', 'Issues involving the brain'),
			('Respiratory', 'Issues involving lungs and airways'),
			('Gastrointestinal', 'Issues involving the stomach and intestines'),
			('Metabolic', 'Issues involving hormonal glands'),
			('Haematological', 'Issues involving the blood');

INSERT INTO
	illness(intervention_id, intervention_type_id, name, desc)
		VALUES
			(1, 1, '')



-- ******************************** DATA INSERTION ENDS HERE ******************************** --
