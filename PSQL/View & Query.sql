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
				WHEN pl.smoking_usage = 'Used to smoke' THEN 'QUIT'
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
		JOIN
			appointment a
		ON
			p.patient_id = a.patient_id
		JOIN
			appointment_result ar
		ON
			a.appointment_id = ar.appointment_id
		WHERE
			pil.illness_id = 2
		AND
			pi.date_confirmed BETWEEN (ar.confirmed_date - INTERVAL '365 days')
				AND
					(ar.confirmed_date + INTERVAL'365 days')
		ORDER BY
			pi.patient_id, pi.date_confirmed DESC;

CREATE VIEW
	patient_heart_disease_symptoms AS
		SELECT
			s.name AS "Coronary Heart Disease Symptoms",
			CONCAT(ROUND((COUNT(aps.symptom_id)::numeric / (SELECT COUNT(apr.appointment_id) FROM appointment_result apr WHERE apr.illness_id = 2) * 100), 2), '%') AS "Occurence Percentage"
		FROM
			symptom s
		JOIN
			appointment_symptom aps
		ON
			s.symptom_id = aps.symptom_id
		JOIN
			appointment_result apr
		ON
			aps.appointment_id = apr.appointment_id
		WHERE
			apr.illness_id = 2
		GROUP BY 
			s.symptom_id
		ORDER BY
			"Occurence Percentage" DESC;

WITH 
	staff_appointments 
AS
	(
		SELECT
			sp1.appointment_id
		FROM
			staff_appointment sp1
		JOIN
			appointment a1
		ON
			sp1.appointment_id = a1.appointment_id
		WHERE
			sp1.staff_id = 1
		AND
			a1.appointment_status = 'Scheduled'
	)

SELECT
	CONCAT(p.first_name, ' ', p.last_name) AS "Patient",
	d.name AS "Department",
	a.appointment_date AS "Date & Time",
	i.name AS "Medical Intervention",
	STRING_AGG(s.first_name || ' ' || s.last_name, ', ') AS "Assigned Staff"
FROM
	appointment a
JOIN
	staff_appointments sps
ON
	a.appointment_id = sps.appointment_id
JOIN
	staff_appointment sp
ON
	a.appointment_id = sp.appointment_id
		AND
			sp.staff_id != 1
JOIN
	staff s
ON
	sp.staff_id = s.staff_id
JOIN
	patient p 
ON
	a.patient_id = p.patient_id
JOIN
	department d
ON
	a.department_id = d.department_id
JOIN
	intervention i 
ON
	a.intervention_id = i.intervention_id
GROUP BY 
	"Patient",
	"Department",
	"Date & Time",
	"Medical Intervention"
ORDER BY
	"Date & Time"
ASC;