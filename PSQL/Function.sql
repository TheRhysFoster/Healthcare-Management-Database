CREATE OR REPLACE FUNCTION add_patient_illness()

	RETURNS TRIGGER AS
	$$

	BEGIN

		IF 
			new.illness_id != 19
		THEN

			INSERT INTO 
				patient_illness(patient_id, illness_id, staff_id, symptoms, findings, diagnosis_date)
			SELECT 
				a.patient_id, new.illness_id, new.staff_id, a.notes, new.notes, new.confirmed_date
			FROM
				appointment_result ar
			JOIN
				appointment a
			ON
				new.appointment_id = a.appointment_id
			LIMIT 1;

		END IF;

		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;


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
				staff s
			ON
				p.staff_id = s.staff_id
			JOIN
				staff_profession sp
			ON
				s.staff_id = sp.staff_id
			WHERE
				new.stock_id = hs.stock_id
			AND
				hs.hospital_id = sp.hospital_id;

		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;


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
						(staff_id, performance_type, performance_desc) VALUES
							(new.staff_id, 'Negative', CONCAT('Late to work by', ' ', EXTRACT(HOUR FROM(new.clocked_in - new.shift_start)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.clocked_in - new.shift_start)), ' ', 'minutes'));

			ELSEIF
				(new.clocked_in < new.shift_start)
			THEN
				INSERT INTO
					staff_performance
						(staff_id, performance_type, performance_desc) VALUES
							(new.staff_id, 'Positive', CONCAT('Early to work by', ' ', EXTRACT(HOUR FROM(new.shift_start - new.clocked_in)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.shift_start - new.clocked_in)), ' ', 'minutes'));

			ELSEIF
				(new.clocked_out > new.shift_end)
			THEN
				INSERT INTO
					staff_performance
						(staff_id, performance_type, performance_desc) VALUES
							(new.staff_id, 'Positive', CONCAT('Stayed an extra', ' ', EXTRACT(HOUR FROM(new.clocked_out - new.shift_end)), ' ', 'hours and', ' ', EXTRACT(MINUTE FROM(new.clocked_out - new.shift_end)), ' ', 'minutes', ' ', 'after shift ended'));

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
							(staff_id, performance_type, performance_desc) VALUES
								(new.staff_id, 'Positive', 'Patient left positive feedback about staff member');

				ELSEIF
					(new.feedback_type = 'Negative')
				THEN
					INSERT INTO
							staff_performance
								(staff_id, performance_type, performance_desc) VALUES
									(new.staff_id, 'Negative', 'Patient left negative feedback about staff member');
				END IF;
			END IF;
		END IF;
		
		RETURN NEW;
	END;
$$
LANGUAGE PLPGSQL;