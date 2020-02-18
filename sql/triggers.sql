create trigger MoreDayParticipantsThanReservations
  on DayBookings
  after update
as
begin
  if exists(select * from DayBookings where dbo.PlacesOnDayBookingLeft(DayBookingID) < 0)
    throw 50001, 'New number of booked places for day is too small for all participants!', 1
end

create trigger MoreWorkshopParticipantsThanReservationsAfterChangingPlaces
  on WorkshopBookings
  after update
as
begin
  if exists(select  * from WorkshopBookings where dbo.PlacesOnWorkshopBookingLeft(WorkshopBookingID) < 0)
    throw 50001, 'New number of booked places for workshop is too small for all participants!', 1
end

create trigger CheckWorkshopPlaceLimitsAfterChangingLimitForDay
  on ConferenceDays
  after update
as
begin
  if exists(select * from Workshops
  inner join ConferenceDays CD on Workshops.DayID = CD.DayID
  where Workshops.NumberOfPlaces > CD.NumberOfPlaces)
    throw 50001, 'There exists at least one workshop with bigger number of places than changed value!', 1
end

create trigger CheckDayPlaceLimitsFitWorkshopLimits
  on Workshops
  after insert, update
as
begin
  if exists(select * from Workshops
  inner join ConferenceDays CD on Workshops.DayID = CD.DayID
  where Workshops.NumberOfPlaces > CD.NumberOfPlaces)
    throw 50001, 'The set number of places is bigger than limit for conference day!', 1
end

create trigger CheckValidDateOfConferenceForBooking
  on Bookings
  after insert
as
  begin
    if exists(select * from Conferences
      inner join Bookings B on Conferences.ConferenceID = B.ConferenceID
      where B.RegistrationDate > Conferences.LastDay)
      throw 50001, 'Booking made for past Conference!', 1
  end

create trigger CheckValidConferenceDaysToBook
  on DayBookings
  after insert, update
as
  begin
    if exists(select * from DayBookings
      inner join Bookings B on DayBookings.BookingID = B.BookingID
      inner join ConferenceDays CD on DayBookings.DayID = CD.DayID
      where CD.ConferenceID <> B.ConferenceID)
    throw 50001, 'Day booking made for incorrect conference!', 1
  end

create trigger CheckValidDateOfConferenceDayForBooking
  on DayBookings
  after insert
as
  begin
    if exists(select * from DayBookings
      inner join Bookings B on DayBookings.BookingID = B.BookingID
      inner join ConferenceDays CD on DayBookings.DayID = CD.DayID
      where B.RegistrationDate > CD.Date)
      throw 50001, 'Booking made for past day of conference!', 1
  end

create trigger CancelDayBookingsAfterCancelledBooking
  on Bookings
  after update
as
  begin
    update DayBookings
    set isValid = 0
    where BookingID in
          (select inserted.BookingID from inserted
           inner join deleted
           on deleted.BookingID = inserted.BookingID
           where deleted.isValid = 1 and inserted.isValid = 0)
  end

create trigger CancelWorkshopBookingsAfterCancelledDayBooking
  on DayBookings
  after update
as
  begin
    update WorkshopBookings
    set isValid = 0
    where DayBookingID in
          (select inserted.DayBookingID from inserted
           inner join deleted
           on deleted.DayBookingID = inserted.DayBookingID
           where deleted.isValid = 1 and inserted.isValid = 0)
  end

create trigger DeleteParticipantsOfDayAfterCancelledDayBooking
  on DayBookings
  after update
as
  begin
    delete from ParticipantsOfDay
    where DayBookingID in
          (select inserted.DayBookingID from inserted
            inner join deleted
            on deleted.DayBookingID = inserted.DayBookingID
            where deleted.isValid = 1 and inserted.isValid = 0)
  end

create trigger DeleteParticipantsOfWSAfterCancelledWorkshopBooking
  on WorkshopBookings
  after update
as
  begin
    delete from ParticipantsOfWorkshop
    where WorkshopBookingID in
          (select inserted.WorkshopBookingID from inserted
            inner join deleted
            on deleted.WorkshopBookingID = inserted.WorkshopBookingID
            where deleted.isValid = 1 and inserted.isValid = 0)
  end

create trigger DeleteWSParticipantsAfterDeletingDayParticipants
  on ParticipantsOfDay
  after delete
as
  begin
    delete from ParticipantsOfWorkshop
    where ParticipantOfDayID in
          (select ParticipantOfDayID from deleted)
  end

create trigger CheckNumberOfStudents
  on ParticipantsOfDay
  after insert, update
as
  begin
    if exists(select * from DayBookings
      where dbo.PlacesOnDayBookingLeft(DayBookings.DayBookingID) = 0
      and NumberOfStudents <> dbo.RegisteredStudents(DayBookings.DayBookingID))
      throw 50001, 'Declared number of students does not match number of students on the list!', 1
  end

create trigger CheckWorkshopOverlap
  on ParticipantsOfWorkshop
  after insert
as
  begin
    if exists(select * from inserted
      inner join ParticipantsOfWorkshop as POW
      on POW.ParticipantOfDayID = inserted.ParticipantOfDayID
      inner join WorkshopBookings WB on POW.WorkshopBookingID = WB.WorkshopBookingID
      inner join WorkshopBookings WB2 on inserted.WorkshopBookingID = WB2.WorkshopBookingID
      where dbo.IsThereACollisionBetweenWorkshops(WB.WorkshopID, WB2.WorkshopID) = 1
      and WB.WorkshopID <> WB2.WorkshopID)
      throw 50001, 'There is a collision between workshops!', 1
  end

create trigger CheckIfEndOfThresholdIsNotLaterThanConfDay
  on PriceThresholds
  after insert, update
as
  begin
    declare @day date = (select ConferenceDays.Date
    from ConferenceDays
    inner join inserted
    on ConferenceDays.DayID = inserted.DayID)
    declare @endDate date = (select inserted.EndDate
      from inserted)

    if @endDate > @day
      throw 50001, 'End of threshold is later than the day of conference connected with it!', 1
  end

create trigger CheckIfAddedDayIsCorrect
  on ConferenceDays
  after insert, update
as
  begin
    if exists(select * from inserted
      inner join Conferences
      on Conferences.ConferenceID = inserted.ConferenceID
      where inserted.Date not between Conferences.FirstDay and Conferences.LastDay)
    throw 50001, 'Inserted day is not in declared time period for conference!', 1
  end
