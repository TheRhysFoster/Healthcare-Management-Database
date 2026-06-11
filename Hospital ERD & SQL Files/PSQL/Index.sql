CREATE INDEX ON feedback(staff_id);
CREATE INDEX ON feedback(feedback_type);
CREATE INDEX ON feedback(feedback_status);
CREATE INDEX ON feedback(verified);

CREATE INDEX ON shift(staff_id);
CREATE INDEX ON shift(hospital_id);

CREATE INDEX ON prescription(stock_id);
CREATE INDEX ON prescription(patient_id);
CREATE INDEX ON prescription(staff_id);

CREATE INDEX ON address(city_id);

CREATE INDEX ON hospitalized(ward_id);

CREATE INDEX ON hospitalization_cause(hospitalization_id);
CREATE INDEX ON hospitalization_cause(symptom_id);

CREATE INDEX ON appointment_result(appointment_id);
CREATE INDEX ON appointment_result(illness_id);
CREATE INDEX ON appointment_result(staff_id);

CREATE INDEX ON appointment(patient_id);
CREATE INDEX ON appointment(department_id);
CREATE INDEX ON appointment(hospital_id);
CREATE INDEX ON appointment(intervention_id);

CREATE INDEX ON appointment_stock(appointment_id);
CREATE INDEX ON appointment_stock(stock_id);

CREATE INDEX ON appointment_result_finding(appointment_result_id);
CREATE INDEX ON appointment_result_finding(finding_id);

CREATE INDEX ON appointment_symptom(appointment_id);
CREATE INDEX ON appointment_symptom(symptom_id);

CREATE INDEX ON illness_types(illness_id);
CREATE INDEX ON illness_types(illness_type_id);

CREATE INDEX ON patient_indicator(patient_id);

CREATE INDEX ON patient_illness(patient_id);
CREATE INDEX ON patient_illness(illness_id);
CREATE INDEX ON patient_illness(staff_id);

CREATE INDEX ON patient_lifestyle(patient_id);
CREATE INDEX ON patient_recreational_usage(patient_lifestyle_id)
CREATE INDEX ON patient_recreational_usage(recreation_id);