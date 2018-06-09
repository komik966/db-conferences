CREATE TRIGGER conference_discounts_due_date_earlier_than_conference_start_date
  ON conference_discounts
  AFTER INSERT, UPDATE AS IF (SELECT due_date
                              FROM inserted) > (SELECT c.start_date
                                                FROM inserted
                                                  JOIN conferences c ON inserted.conference_id = c.id)
  BEGIN
    RAISERROR ('Discount due date must be earlier than conference start date.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
  END;

CREATE TRIGGER conference_start_date_later_than_conference_discounts_due_date
  ON conferences
  AFTER UPDATE AS IF EXISTS(SELECT *
                                    FROM inserted
                                      INNER JOIN conference_discounts cd
                                        ON inserted.id = cd.conference_id AND inserted.start_date < cd.due_date)
  BEGIN
    RAISERROR ('Conference start date must be later than its discounts due date.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
  END;

CREATE TRIGGER conference_day_date_between_conference_start_end_dates
  ON conference_days
  AFTER INSERT, UPDATE AS IF NOT EXISTS(SELECT *
                                        FROM inserted
                                          JOIN conferences c
                                            ON inserted.conference_id = c.id AND
                                               DATEADD(DAY, 1, inserted.date) > c.start_date AND
                                               inserted.date < c.end_date)
  BEGIN
    RAISERROR ('Conference day date must be between conference start date and conference end date.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
  END;

CREATE TRIGGER conference_start_end_dates_no_orphan_conference_day
  ON conferences
  AFTER UPDATE AS IF EXISTS(SELECT *
                            FROM inserted
                              INNER JOIN conference_days cd
                                ON inserted.id = cd.conference_id AND
                                   DATEADD(DAY, 1, cd.date) <= inserted.start_date OR
                                   cd.date >= inserted.end_date)
  BEGIN
    RAISERROR ('Change to conference dates will leave orphaned conference days. Remove them first.', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
  END;

CREATE TRIGGER conference_reservation_details_attendees_amount
  ON conference_reservation_details
  AFTER INSERT, UPDATE AS
  IF ((SELECT c.max_attendees
       FROM inserted
         INNER JOIN conference_days cd
           ON inserted.conference_day_id = cd.id
         INNER JOIN conferences c ON cd.conference_id = c.id) < (SELECT SUM(crd.attendees_amount)
                                                                 FROM inserted
                                                                   INNER JOIN conference_reservation_details crd
                                                                     ON crd.conference_day_id =
                                                                        inserted.conference_day_id
                                                                 GROUP BY crd.conference_day_id))
    BEGIN
      RAISERROR ('Attendees amount for this conference day was exceeded.', 16, 1);
      ROLLBACK TRANSACTION;
      RETURN
    END;

-- TODO gdy reservation.payment_date not null - nie można dorezerwowywać do tej rezerwacji
-- TODO sprawdzać czy conference_attendees_students.conference_attendee_id.conference_reservation_detail_id = student_cards.conference_reservation_detail_id
-- TODO student_cards.count by conference_reservation_detail_id <= conference_reservation_detais.attendeesAmount
-- TODO: workshop_day.(start/stop date) = conference_reservation_details.conference_day.date
-- TODO: suma attendees_amount nie może być większa od workshop_days.max_attendees
-- ?TODO? sprawdzenie czy conference_attendee.conference pokrywa się workshop.conference
