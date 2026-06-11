CREATE TYPE time_type
	AS ENUM('Full-Time', 'Part-Time', 'On-Call');

CREATE TYPE employment_type
	AS ENUM('Permanent', 'Temporary', 'Contractor');

CREATE TYPE direction
	AS ENUM('South East', 'North East', 'South West', 'North West');

CREATE TYPE patient_status
	AS ENUM('Under Treatment', 'End of Life Care', 'Deceased', 'Discharged');

CREATE TYPE severity
	AS ENUM('N/A', 'Low Mortality', 'Medium Mortality', 'High Mortality');

CREATE TYPE smoking_usage
	AS ENUM('Trying to quit', 'Used to smoke', 'None');

CREATE TYPE alcohol_usage
	AS ENUM('None', 'Monthly', 'Weekly', 'Daily');

CREATE TYPE exercise_amount
	AS ENUM('Sedentary', 'Daily', 'Weekly', 'Monthly');

CREATE TYPE dietary_type
	AS ENUM('Standard Western Diet', 'Vegan', 'Vegetarian', 'Pescatarian', 'Carnivore');

CREATE TYPE country
	AS ENUM('England', 'Wales', 'Northern Ireland', 'Scotland');

CREATE TYPE appointment_status
	AS ENUM('Cancelled', 'Did not attend', 'Attended', 'Rescheduled');

CREATE TYPE positive_negative
	AS ENUM('Positive', 'Negative');

CREATE TYPE sex
	AS ENUM('Male', 'Female');

CREATE TYPE address_type
	AS ENUM('Staff', 'Patient', 'Hospital');

CREATE TYPE feedback_status
	AS ENUM('Open', 'Closed');