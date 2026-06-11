CREATE TRIGGER trig_update_hospital_stock_appointment

	AFTER INSERT ON

		appointment_stock

	FOR EACH ROW

EXECUTE PROCEDURE update_hospital_stock();


CREATE TRIGGER trig_update_hospital_stock_prescription

	AFTER INSERT ON

		prescription

	FOR EACH ROW

EXECUTE PROCEDURE update_hospital_stock();


CREATE TRIGGER trig_update_staff_performance_shift

	AFTER INSERT ON

		shift

	FOR EACH ROW

EXECUTE PROCEDURE update_staff_performance();


CREATE TRIGGER trig_update_staff_performance_feedback

	AFTER INSERT ON

		feedback

	FOR EACH ROW

EXECUTE PROCEDURE update_staff_performance();


CREATE TRIGGER trig_add_patient_illness

	AFTER INSERT ON

		appointment_result

	FOR EACH ROW

EXECUTE PROCEDURE add_patient_illness();