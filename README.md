# 🏥 Hospital Database & Analysis
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


## 🗄️ Database Architecture & Design

### Table Justification
#### 📋 Appointment Lifecycle
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


#### 👤 Patient Lifecycle
**1\) Why isn't `patient_illness` a junction table?**

Using a primary key instead of a composite key made up of `patient_id` & `illness_id` allows for a patient to have multiple entries of the same illness. At first glance this can seem like it increases the chance of redundancy through duplicate data, however in a medical environment it is necessary to design the schema this way. 

*If we look at a real-world example of someone who has been cleared of cancer, unfortunately in many cases it can return. If this happens, a new appointment will be booked and the outcome could be the same diagnosis as before, but with potentially different symptoms / findings and the illness being confirmed by another staff member. To have an accurate patient history, all repeating illnesses need to be logged.*

**2\) What are the `symptoms` & `findings` TEXT attributes in the `patient_illness` entity?**

The data stored in those attributes are automatically pushed through from `notes` found in the `appointment` and `appointment_result` tables. This is based on the assumption that when a GP or even a member of staff at a hospital wants to check over a patient's medical history, they want to read in detail what symptoms the patient presented with and what issues were found. Given that `notes` is a TEXT attribute, this allows them to do so. The alternative would be a list without a certified staff member's additions.

As mentioned in the previous section, if an research style analysis of specific illnesses is needed, that is when `notes` is avoided and instead a query will access `appointment_symptom` and `appointment_result_finding` for a cleaner, more structured view. This view could then be accessed with external tools like PowerBI.

**3\) Why not just use `patient_id` as a primary key for `patient_indicator` and `patient_lifestyle`?**

If `patient_id` was used for this purpose, both patient indicators and patient lifestyle records would certainly be overwritten. The types of information stored in these two tables are usually updated more than once. Storing the same `patient_id` more than once would not be possible, causing the overwrite.

For example, if a patient has high blood pressure / HDL / blood sugar, these readings would need to be checked on a regular basis as they can lead to different diseases overtime. The same applies to attributes such as smoking, alcohol consumption and recreational usage as those can also cause harm and need to be monitored.

If all of those attributes were to be overwritten everytime they were updated, there wouldn't be any way for medical staff to track a patient's history regarding those details.


### 🔗 Junction Tables
In this section, I will cover the remaining junctions tables that have not yet been mentioned, and briefly explain their purpose.

#### JT1) Patient Recreational Usage
Some patients may be using multiple types of recreational drugs. A junction table is needed to track the correct amounts of each type. 

**The three reasons for part of the composite key using `patient_lifestyle_id` instead of `patient_id` are:**

Recreational usage is a lifestyle choice and being linked to `patient_lifestyle` keeps all relevant information intact held together by `date_confirmed` and the `patient_lifestyle_id`.

Using `patient_id` would cause the primary key constraint to fail

`recreation_id` would only hold one value if placed in the `patient_lifestyle` entity
  
**If a patient has three entries into `patient_recreational_usage` but the composite key was instead made up of `patient_id` and `recreational_id`, then:**

✅ The first states they are using type 1 (`patient_id` = 1, `recreation_id` = 1)

✅ The second states they aren't using any (no `patient_recreationl_usage` entry)

❌ The third states they are using type 1 again (`patient_id` = 1, `recreation_id` = 1)

The third step is what will fail the constraint.

#### JT2) Illness Types
To begin with, the `illness_type_id` was included in the `illness` table, but some illnesses do fall under two categories which is why the junction was needed. For example, lung cancer would be classified as 'Respiratory' and 'Cancer'.

#### JT3) Hospitalization Cause
This table is a junction between `hospitalized` and `symptom`. Records will mainly be inserted in here and `hospitalized` depending on the outcome of A&E visits. Given that a person may present with many symptoms, if they are hospitalized because of them, each one needs to be linked to the `hospitalization_id`. 

#### JT4) Appointment Stock
A simple table that tracks exactly which stock and how much was used during each appointment.

#### JT5) Hospital Stock 
This table tracks the total amount of each item a hospital currently has in inventory. It is updated automatically depending on the `prescription` and `appointment_stock` tables. This will be broken down into more detail in a later section.

#### JT6) Hopsital Department
Most hospitals will not have the exact same amounts or types of departments. This table not only tracks this, but also specific department phone extensions numbers and emails per hospital.

#### JT7) Staff Profession
In rare cases, a member of staff can have more than 1 role / profession and in even rarer cases, the professions can take place at different hospitals. This table uses a composite primary key made up of the `staff_id`, `profession_id` and `hospital_id` to solve this. Also stored here are the main attributes of professions. These attributes cannot be stored in a table like `staff` as they directly relate to role and may differ between those roles.
