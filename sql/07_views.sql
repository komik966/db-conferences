CREATE VIEW conference_day_max_attendees AS
  SELECT
    cd.id conference_day_id,
    c.max_attendees
  FROM conference_days cd INNER JOIN conferences c on cd.conference_id = c.id;

CREATE VIEW filled_conference_attendees_count AS
  SELECT
    crd.id                     AS conference_reservation_detail_id,
    COUNT(ca.id)               AS student_and_non_student_count,
    COUNT(cas.student_card_id) AS student_count
  FROM conference_reservation_details crd
    LEFT JOIN conference_attendees ca ON crd.id = ca.conference_reservation_detail_id
    LEFT JOIN conference_attendees_students cas on ca.id = cas.conference_attendee_id
  GROUP BY crd.id;


CREATE VIEW declared_conference_attendees_count AS
  SELECT
    crd.id               AS conference_reservation_detail_id,
    crd.attendees_amount AS student_and_non_student_count,
    COUNT(sc.id)         AS student_count
  FROM conference_reservation_details crd LEFT JOIN student_cards sc on crd.id = sc.conference_reservation_detail_id
  GROUP BY crd.id, crd.attendees_amount;

CREATE VIEW not_filled_conference_attendees_count AS
  SELECT
    dcac.conference_reservation_detail_id,
    (dcac.student_and_non_student_count - fcac.student_and_non_student_count) AS student_and_non_student_count,
    (dcac.student_count -
     fcac.student_count)                                                      AS student_count,
    (dcac.student_and_non_student_count - fcac.student_and_non_student_count - dcac.student_count +
     fcac.student_count)                                                      AS non_student_count
  FROM declared_conference_attendees_count dcac
    INNER JOIN filled_conference_attendees_count fcac
      ON dcac.conference_reservation_detail_id = fcac.conference_reservation_detail_id;

CREATE VIEW should_phone_for_conference_attendees_data AS
  SELECT
    c.phone_number,
    c2.start_date AS conference_start_date,
    nfcac.conference_reservation_detail_id,
    nfcac.student_and_non_student_count,
    nfcac.student_count,
    nfcac.non_student_count
  FROM not_filled_conference_attendees_count nfcac
    INNER JOIN conference_reservation_details crd
      ON crd.id = nfcac.conference_reservation_detail_id
    INNER JOIN conference_reservations cr
      on crd.conference_reservation_id = cr.id
    INNER JOIN customers c on cr.customer_id = c.id
    INNER JOIN conference_days cd ON crd.conference_day_id = cd.id
    INNER JOIN conferences c2 on cd.conference_id = c2.id
  WHERE c2.start_date > CURRENT_TIMESTAMP AND
        c2.start_date < DATEADD(WEEK, 2, CURRENT_TIMESTAMP)
        AND student_and_non_student_count > 0;

CREATE VIEW filled_workshop_attendees_count AS
  SELECT
    wr.id                             AS workshop_reservation_id,
    COUNT(wa.workshop_reservation_id) AS attendees_count
  FROM workshop_reservations wr
    LEFT JOIN workshop_attendees wa on wr.id = wa.workshop_reservation_id
  GROUP BY wr.id;

CREATE VIEW not_filled_workshop_attendees_count AS
  SELECT
    wr.id                                        AS workshop_reservation_id,
    (wr.attendees_amount - fwac.attendees_count) AS attendees_count
  FROM workshop_reservations wr INNER JOIN filled_workshop_attendees_count fwac ON wr.id = fwac.workshop_reservation_id;

CREATE VIEW conference_reservations_too_late_for_payment AS
  SELECT *
  FROM conference_reservations
  WHERE DATEADD(WEEK, 1, reservation_date) < CURRENT_TIMESTAMP AND payment_date IS NULL