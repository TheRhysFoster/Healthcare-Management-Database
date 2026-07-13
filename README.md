# 🏥 Hospital Database
A PostgreSQL database that handles core hospital operations and medical data by utilizing triggers and functions for necessary automation and indexes for real-world query performance.

**Includes but not limited to:**

- **Patient Health** - (demographics, health indicators such as lipids / blood pressure / weight and lifestyle choices such as smoking usage, alcohol consumption, diet and exercise)

- **Staff Management & Performance** - (demographics, automated staff performance tracking including patient feedback / staff punctuality and profession data such as salary / employment type / work location)

-  **Appointments & Diagnostics** - (medical interventions, illness outcomes, appointment findings and patient's original symptoms)

- **Stock Management** - (inventory tracking and automated deductions of stock per appointment or prescription for each hospital)


## 🗺️ Entity Relationship Diagram
An ERD with **35+ entities**, demonstrating links between the different domains within a hospital environment, through the use of **ONE -> ONE, ONE -> MANY,** and **MANY -> MANY** relationships.

![Hospital Entity Relationship Diagram](Docs/Hospital%20ERD.png)  

<div align="center">
  
${\color{#008A0E}\text{PK = Primary Key }}$
${\color{#E81313}\text{FK = Foreign Key }}$
${\color{#B11289}\text{AK = Alternate Key }}$
${\color{#1071E5}\text{PK/FK = Composite Key}}$


*Please right click the ERD preview above and select 'Open image in new tab' to view it in full detail*
</div>


## 📊 Table Justification
### 📋 Appointment Lifecycle
**1\) Why isn't there a `staff_id` foreign key in the `appointment` entity?**

It may be the case that more than one staff member needs to attend an appointment. This won't happen for all appointments and in fact could be considered a rare occurence depending on the type. However given it's a possibility, it needs to be accounted for in the schema. A simple junction table `staff_appointment` allows different staff members (`staff_id`) to be assigned to the same appointment (`appointment_id`). 

Ignoring this possibility would mean:
- **Tracking Failure** - Unable to identifying all staff present at an appointment
- **Schedule Conflict** - If other staff do attend, they can't be linked to the appointment and could be assigned to something else, causing conflict
  
  
*A real-world example to represent the above would be an MRI scan. During the scan, there are usually two members of staff: a radiographer who manages the imaging and a nurse focused on the patient*

**2\) Based on the previous answer, why is the `staff_id` foreign key in the `appointment_result` entity?**

The main purpose of the `appointment_result` entity is to record and confirm a diagnosis made from the medical data gathered during an appointment. From a clinical perspective, many staff members could review the data, but only one staff member specialized in analyzing such results would be authorized to make a decision on the patient's final outcome. Hence it makes sense to include `staff_id`.

*Adding to the previous example, the radiographer managing the imaging process would pass on the image to more qualified clinicians. Many specialists of the same profession may assess the results from the scan, but ultimately it comes down to one person to conclude the patient's diagnosis. This one person is the `staff_id` stored in the `appointment_result` entity*

**3\) Shouldn't the findings of an appointment be stored directly in the `appointment_result` entity?**

It is possible for only one medical issue to be found during many types of hospital appointments, but similar to the first answer, there is a chance that multiple issues could be found. This means a junction table is needed to be able to store ALL findings so that it can be linked to the specific appointment, an illness and patient history. The reason for the `appointment_result` table not originally being the junction for findings is to reduce redundant data. Attributes such as `staff_id`, `notes` and `illness_id` would need to be repeated for each composite key with a new `finding_id`. 

The same logic applies to the `appointment_symptom` entity. The majority of the time, the reason patients need an appointment is due to multiple symptoms. Not only are the junction tables important for keeping a correct medical history of the patient, but by normalizing symptoms and findings into entities makes querying in relation to illnesses easier and therefore useful for future data analysis by medical researchers. 

The `notes` attribute of `appointment` and `appointment_result` are written about but in any amount of detail a staff member deems necessary. However if that was the only record of what was found during appointments and the patient's original symptoms, it wouldn't be as straight forward to link what's stored in `notes` to specific illnesses. This would most likely require a function in the frontend to parse the TEXT in `notes` and tackle common human errors like spelling mistakes. 


### 👤 Patient Lifecycle
**1\) Why isn't `patient_illness` a junction table?**

Using a primary key instead of a composite key made up of `patient_id` & `illness_id` allows for a patient to have multiple entries of the same illness. At first glance this can seem like it increases the chance of redundancy through duplicate data, however in a medical environment it is necessary to design the schema this way. 

*If we look at a real-world example of someone who has been cleared of cancer, unfortunately in many cases it can return. If this happens, a new appointment will be booked and the outcome could be the same diagnosis as before, but with potentially different medical findings and different staff member making the diagnosis. To have an accurate patient history, all repeating illnesses need to be logged.*

**2\) What is the `findings` TEXT attribute in the `patient_illness` entity?**

The data stored in this attribute is automatically pushed through from `notes` found in the `appointment_result` table. This is based on the assumption that when a GP or even a member of staff at a hospital wants to check over a patient's medical history, they want to read in detail what issues were found leading to the diagnosis. Given that `notes` is a TEXT attribute, this allows the staff members who found issues during appointments to write in detail about what was found. 

As mentioned in the previous section, if an research style analysis of specific illnesses is needed, that is when `notes` is avoided and instead a query will access `appointment_symptom` and `appointment_result_finding` for a cleaner, more structured view. This view could then be accessed with external tools like PowerBI.

**3\) Why not just use `patient_id` as a primary key for `patient_indicator` and `patient_lifestyle`?**

If `patient_id` was used for this purpose, both patient indicators and patient lifestyle records would certainly be overwritten. The types of information stored in these two tables are usually updated more than once. Storing the same `patient_id` more than once would not be possible, causing the overwrite.

For example, if a patient has high blood pressure / HDL / blood sugar, these readings would need to be checked on a regular basis as they can lead to different diseases overtime. The same applies to attributes such as smoking, alcohol consumption and recreational usage as those can also cause harm and need to be monitored.

If all of those attributes were to be overwritten everytime they were updated, there wouldn't be any way for medical staff to track a patient's history regarding those details.


## 🔗 Junction Tables
In this section, I will cover the remaining junctions tables that have not yet been mentioned, and briefly explain their purpose.

### JT1) Patient Recreational Usage
Some patients may be using multiple types of recreational drugs. A junction table is needed to track the correct amounts of each type. 

**The three reasons for part of the composite key using `patient_lifestyle_id` instead of `patient_id` are:**

*Recreational usage is a lifestyle choice and being linked to `patient_lifestyle` keeps all relevant information intact held together by `date_confirmed` and the `patient_lifestyle_id`.*

*Using `patient_id` would cause the primary key constraint to fail*

*`recreation_id` would only hold one value if placed in the `patient_lifestyle` entity*
  
**If a patient has three entries into `patient_recreational_usage` but the composite key was instead made up of `patient_id` and `recreational_id`, then:**

*✅ The first states they are using type 1 (`patient_id` = 1, `recreation_id` = 1)*

*✅ The second states they aren't using any (no `patient_recreationl_usage` entry)*

*❌ The third states they are using type 1 again (`patient_id` = 1, `recreation_id` = 1)*

The third step is what will fail the constraint.

### JT2) Illness Types
To begin with, the `illness_type_id` was included in the `illness` table, but some illnesses do fall under two categories which is why the junction was needed. For example, lung cancer would be classified as 'Respiratory' and 'Cancer'.

### JT3) Hospitalization Cause
This table is a junction between `hospitalized` and `symptom`. Records will mainly be inserted in here and `hospitalized` depending on the outcome of A&E visits. Given that a person may present with many symptoms, if they are hospitalized because of them, each one needs to be linked to the `hospitalization_id`. 

### JT4) Appointment Stock
A simple table that tracks exactly which stock and how much was used during each appointment.

### JT5) Hospital Stock 
This table tracks the total amount of each item a hospital currently has in inventory. It is updated automatically depending on the `prescription` and `appointment_stock` tables. This will be broken down into more detail in a later section.

### JT6) Hopsital Department
Most hospitals will not have the exact same amounts or types of departments. This table not only tracks this, but also specific department phone extensions numbers and emails per hospital.

### JT7) Staff Profession
In rare cases, a member of staff can have more than 1 role / profession and in even rarer cases, the professions can take place at different hospitals. This table uses a composite primary key made up of the `staff_id`, `profession_id` and `hospital_id` to solve this. Also stored here are the main attributes of professions. These attributes cannot be stored in a table like `staff` as they directly relate to role and may differ between those roles.


## ⚡ Triggers & Functions

### 📦 Stock Tracking
<details>
  <summary>🔍 Click To View Function: (Update Hospital Stock)</summary>

```sql
CREATE OR REPLACE FUNCTION update_hospital_stock()

	RETURNS TRIGGER AS
	$$

	BEGIN

		IF TG_TABLE_NAME = 'appointment_stock' THEN

			UPDATE
				hospital_stock hs
			SET
				total_amount = hs.total_amount - new.amount_used
			FROM
				appointment_stock ast
			JOIN
				appointment a
			ON
				new.appointment_id = a.appointment_id
			JOIN
				hospital h
			ON
				a.hospital_id = h.hospital_id
			WHERE
				new.stock_id = hs.stock_id
			AND
				hs.hospital_id = h.hospital_id;

		ELSEIF TG_TABLE_NAME = 'prescription' THEN

			UPDATE
				hospital_stock hs
			SET
				total_amount = hs.total_amount - new.amount_used
			FROM
				prescription p
			JOIN
				hospital h
			ON
				p.hospital_id = h.hospital_id
			WHERE
				new.stock_id = hs.stock_id
			AND
				hs.hospital_id = h.hospital_id;

		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;
```
</details>

Each hospital will have different amounts and types of stock and this is currently stored in the `hospital_stock` entity. In a large scale hospital system, it would be unrealistic to expect manual updates of inventory per hospital. To tackle this, I implemented a function that automatically alters the values in `hospital_stock` which rely on insertions into `appointment_stock` and `prescription` through triggers.

The JOINs are different depending on whether a prescription was filled out OR items were used during an appointment, so to determine what logic to use a conditional IF statement is present in the function which checks which table caused the function to execute.

When an insertion is made in `appointment_stock` or `prescription`, the function needs to match the `hospital_id` where the prescription or appointment took place to that same ID in `hospital_stock`

For `prescription`, the `hospital_id` is already recorded, leading to a shorter join. However with `appointment_stock`, it first needs to join to the `appointment` table which is where `hospital_id` is stored.

*Staff member on front-end interface records that 4 sterile gauze swabs were used during a surgery. The surgery was the 18th appointment of Greenfield Hospital*

```text
[appointment_stock]: (appointment_id = 18, stock_id = 12, amount_used = 4)
   └───> JOIN to appointment table using appointment_id
[appointment]:       (appointment_id = 18, hospital_id = 1)
   └───> JOIN to hospital_stock table using hospital_id and stock_id
[hospital_stock]:    (hospital_id = 1, stock_id = 12, total_amount - 4)
```

### 📈 Staff Performance
<details>
  <summary>🔍 Click To View Function: (Update Staff Performance)</summary>

```sql
CREATE OR REPLACE FUNCTION update_staff_performance()

	RETURNS TRIGGER AS
	$$

	BEGIN

		IF TG_TABLE_NAME = 'shift' THEN

			IF
				(new.clocked_in > new.shift_start)
			THEN
				INSERT INTO
					staff_performance
						(staff_id, shift_id, performance_type, performance_desc) VALUES
							(new.staff_id, new.shift_id, 'Negative', CONCAT('Late to work by', ' ', EXTRACT(HOUR FROM(new.clocked_in - new.shift_start)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.clocked_in - new.shift_start)), ' ', 'minutes'));

			ELSEIF
				(new.clocked_in < new.shift_start)
			THEN
				INSERT INTO
					staff_performance
						(staff_id, shift_id, performance_type, performance_desc) VALUES
							(new.staff_id, new.shift_id, 'Positive', CONCAT('Early to work by', ' ', EXTRACT(HOUR FROM(new.shift_start - new.clocked_in)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.shift_start - new.clocked_in)), ' ', 'minutes'));

			END IF;				
			
			IF
				(new.clocked_out > new.shift_end)
			THEN
				INSERT INTO
					staff_performance
						(staff_id, shift_id, performance_type, performance_desc) VALUES
							(new.staff_id, new.shift_id, 'Positive', CONCAT('Stayed an extra', ' ', EXTRACT(HOUR FROM(new.clocked_out - new.shift_end)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.clocked_out - new.shift_end)), ' ', 'minutes', ' ', 'after shift ended'));
			END IF;
			

		ELSEIF TG_TABLE_NAME = 'feedback' THEN

			IF 
				(new.verified = TRUE)
			THEN
				IF
					(new.feedback_type = 'Positive')
				THEN
					INSERT INTO
						staff_performance
							(staff_id, feedback_id, performance_type, performance_desc) VALUES
								(new.staff_id, new.feedback_id, 'Positive', 'Patient left positive feedback about staff member');

				ELSEIF
					(new.feedback_type = 'Negative')
				THEN
					INSERT INTO
							staff_performance
								(staff_id, feedback_id, performance_type, performance_desc) VALUES
									(new.staff_id, new.feedback_id, 'Negative', 'Patient left negative feedback about staff member');
				END IF;
			END IF;
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;
```
</details>

This function causes specific types of information to be inserted into the `staff_performance` entity depending on which table it is triggered by. The two tables that are able to trigger it are `shift` and `feedback`.

Similar to the previous function, a conditional IF statement is used to determine which table caused the trigger. From here, more IF statements are used on the table data so that either "Positive" or "Negative" records are inserted relating to staff punctuality or patient feedback.

In terms of the `shift` table, attributes such as `shift_start`, `shift_end`, `clocked_in` and `clocked_out` are used to calculate whether a staff member was late, early or stayed for extra time after their shift. The specific amount of time a staff member was late, early or overstayed by is also calculated for the record.

The `feedback` table stores any positive or negative reviews by patients about staff members. Before inserting all reviews into `staff_performance`, the BOOLEAN attribute `verified` needs to be TRUE. This means that hypothetically another member of staff has reviewed the case, and using the front-end system sets the review of the patient to verified.

This type of performance data will be useful to managers who need to monitor employees work ethic, behaviour and any progression being made OR larger queries to monitor the overall standard of entire hospitals.

### 👤 Patient Illness Function
<details>
  <summary>🔍 Click To View Function: (Add / Update Patient Illness)</summary>

```sql
CREATE OR REPLACE FUNCTION add_patient_illness()

	RETURNS TRIGGER AS
	$$

	BEGIN

		IF 
			new.illness_id != 19
		THEN
			UPDATE
				patient_illness
			SET
				findings = CONCAT(findings, ' -> ', new.notes)
			WHERE
				illness_id = new.illness_id
			AND
				condition != 'Cured'
			AND
				patient_id = (SELECT a.patient_id FROM appointment a WHERE a.appointment_id = new.appointment_id);

			IF NOT FOUND THEN
				INSERT INTO 
					patient_illness(patient_id, illness_id, condition, findings)
				SELECT
					a.patient_id, new.illness_id, 'Stable', new.notes
				FROM
					appointment a
				WHERE 
					a.appointment_id = new.appointment_id;
			END IF;
		END IF;

		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;
```
</details>

When records are inserted into `appointment_result`, the `add_patient_illness()` function is triggered to populate the `patient_illness` entity. After a diagnosis has been made, it is important to have a table that tracks the illnesses of each patient and it's current condition. As mentioned earlier, this table does not use a composite primary key so records including the same patient and illness can be inserted more than once under certain circumstances.

The function above makes sure that the only time a record including the same patient and illness can be created, is when `condition` attribute of the previous record is set to `Cured`. 

```text
Patient Illness ID: 39
Patient ID: 1
Illness ID: 7
Condition: 'Cured'
Findings: '4cm Tumour on right lobe, Right lobe tumour successfully removed`
```

If a patient was diagnosed with Stage 3 Lung Cancer and later went into remission, the `condition` would be set to `Cured`. It is only after this if they are unfortunately diagnosed with the same illness again, a new record will be added as it would be the start of a new illness cycle.

**What happens if the existing record `condition` value isn't `Cured`, but a new `appointment_result` entry has the same `illness_id` recorded in `patient_illness`?**

Instead of creating a new record for the same illness, the current record and it's `findings` attribute are concantenated with new medical data gathered during the appointment.

*Imagine the original appointment revealed that the patient has a 5cm tumour on their left lobe.*

```text
Patient Illness ID: 40
Patient ID: 1
Illness ID: 7
Condition: 'Stable'
Findings: '5cm Tumour on left lobe`
```

*3 months later the patient has another appointment and a scan reveals the tumour has shrunk to 3cm.* 

It would be redundant to create a new `patient_illness` record as this would include already existing `patient_id`, `illness_id` and a new `condition` attribute for the same ongoing illness that's not yet been cured.

Instead, we keep the same record but update `findings` and allow a member of staff to update the condition of the illness:
```text
Patient Illness ID: 40
Patient ID: 1
Illness ID: 7
Condition: 'Improving'
Findings: '5cm Tumour on left lobe -> Tumour shrunk to 3cm in 3 months`
```


## 🗂️ Indexing
The amount of records in the database sits at around 12300+ which is miniscule compared to the live medical industry. At this point in time, the United Kingdom has a population of around 70 million and the NHS just over 2 million employees. These two primary variables (patients and staff) in conjunction with entities (such as appointments, patient data and stock) that have high frequency transactions will amount to hundreds of millions of records per year once the database is live.

Given the small amount of records that currently exist, sequential scans are planning and executing faster than indexed scans. This is to be expected with such a small dataset. In a real world scenario including millions of records per table, the opposite would take place and the need for indexes would be more evident. 

Imagine hundreds of staff members have clocked in for their shifts at the hospital and throughout the day check what appointments they need to attend. The staff will be logged into the hospitals website / software and access the appointments section. Each time this section is refreshed or loaded, a query written in the front-end is sent to the back-end to be executed. Given that these appointments are for the current day, then all completed, cancelled or rescheduled appointments should not be displayed.

```sql
WHERE
	staff_appointment.staff_id = $1
AND
	appointment.appointment_status = 'Scheduled'
AND
	appointment.appointment_date >= $2
AND
	appointment.appointment_date < $3 
```

*$ = Placeholder, 1 = First Argument (Staff ID), 2 = Second Argument (Current Date + Midnight), 3 = Third Argument (Tomorrows Date + Midnight)*

*Date comparison has to be used because `appointment_date` is a TIMESTAMP and using ::date to remove the time would slow down the query*

A sequential scan of `staff_appointment` and `appointment` to find the matching `appointment_status`, `appointment_date` and `staff_id` would read every single row of both tables causing major slowdowns in a database with millions of records. 

```sql
CREATE INDEX appointment_status_and_date_idx ON appointment(appointment_status, appointment_date);
CREATE INDEX ON staff_appointment(staff_id);
```
The above indexes allow the database to first view a "Map" which shows which page or chunk the matching rows are in and then head directly there ignoring all irrelevant rows. This usually takes execution time down from seconds to milliseconds for extremely large datasets.

Attributes that are in `JOINs` OR `WHERE` clauses when querying have been indexed manually. PSQL automatically indexes any attribute that uses a `UNIQUE` constraint. Since the database is not live / in use, the `CONCURRENTLY` option was not used as there is not a risk of blocking WRITEs.


## 🔍 Querying / Views

### 🩺 Heart Disease Indicator
<details>
  <summary>🔍 Click To View Query: (Patient Heart Disease Indicators)</summary>

```sql
CREATE VIEW
	patient_heart_disease_indicators AS
		SELECT DISTINCT ON(pi.patient_id)
			EXTRACT(YEAR FROM age(current_date, date_of_birth)) AS "Patient Age",
			pi.hdl AS "HDL Count",
			pi.ldl AS "LDL Count",
			pi.triglycerides AS "Triglycerides Count",
			pi.total_cholesterol AS "Total Cholesterol",
			pi.systolic AS "Systolic Pressure",
			pi.diastolic AS "Diastolic Pressure",
			pi.blood_sugar AS "Blood Sugar Level",
			CASE
				WHEN pl.smoking_usage = 'Trying to quit' THEN 'YES'
				WHEN pl.smoking_usage = 'Used to smoke' THEN 'NO'
				WHEN pl.smoking_usage = 'None' THEN 'NO'
			END AS "Smoker"
		FROM
			patient p
		JOIN
			patient_indicator pi
		ON
			p.patient_id = pi.patient_id
		JOIN
			patient_lifestyle pl
		ON
			pi.patient_id = pl.patient_id
		JOIN
			patient_illness pil
		ON
			pi.patient_id = pil.patient_id
		WHERE
			pil.illness_id = 2
		ORDER BY
			pi.patient_id, pi.date_confirmed DESC;

```
</details>
**Result Example:**

![Heart Disease Indicator](Docs/Patient%20Heart%20Disease%20Indicators.png)  

This query collects relevant indicators in regards to heart health from the `patient_indicator` and `patient_lifestyle` entities, then limits the results to patients who have been diagnosed with Coronary Heart Disease. The set of `patient_indicator` data used per patient is the latest. This is based on the assumption that when a patient visits their GP with specific symptoms, the GP will be able to relate this symptoms to heart health and blood work will be ordered. The results from this blood work will mean a new entry into `patient_indicator`.

The purpose of this query is to find any correlation between these indicators (e.g LDL Count) and a specific disease (any illness can be plugged into the query). The results will best serve a medical analyst in external tools such as PowerBI. In PowerBI, analysts can create filters on specific attributes (e.g slide bars) and when changing the desired value of an attribute the results will increase or decrease. 



