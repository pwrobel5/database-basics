create function PriceOfDayOn
(
@day date,
@dayID int
)
returns money
as
  begin
    return (select PriceThresholds.Price
    from PriceThresholds
    where PriceThresholds.DayID = @dayID and @day between StartDate and EndDate)
  end

create function StudentDiscountOfDay
(
@day date,
@dayID int
)
returns real
as
  begin
    return (select PriceThresholds.StudentDiscount
    from PriceThresholds
    where PriceThresholds.DayID = @dayID and @day between StartDate and EndDate)
  end

create function ConferenceDaysInfo
(
@confID int
)
returns table
as
  return (select Date, NumberOfPlaces, PlacesLeft
         from ConferenceDays
         where ConferenceID = @confID)

create function WorkshopsInfo
(
@confDayID int
)
returns table
as
  return (select WorkshopName, WorkshopStart, WorkshopEnd, NumberOfPlaces, PlacesLeft, Price
         from Workshops
         where DayID = @confDayID)

create function DayParticipantsList
(
@confDayID int
)
returns table
as
  return (select Participants.Title, Participants.FirstName, Participants.LastName
  from ConferenceDays
         inner join DayBookings DB
           on ConferenceDays.DayID = DB.DayID
         inner join ParticipantsOfDay POD
           on DB.DayBookingID = POD.DayBookingID
         inner join Participants
           on POD.ParticipantID = Participants.ParticipantID
  where DB.DayID = @confDayID and DB.isValid = 1)

create function WorkshopParticipantsList
(
@workshopID int
)
returns table
as
  return (select P.Title, P.FirstName, P.LastName
  from Workshops
         inner join WorkshopBookings WB
           on Workshops.WorkshopID = WB.WorkshopID
         inner join ParticipantsOfWorkshop POW
           on WB.WorkshopBookingID = POW.WorkshopBookingID
         inner join ParticipantsOfDay POD
           on POW.ParticipantOfDayID = POD.ParticipantOfDayID
         inner join Participants P
           on POD.ParticipantID = P.ParticipantID
  where Workshops.WorkshopID = @workshopID and WB.isValid = 1)

create function PricesOfConferenceDays
(
@confID int,
@dateOfCheck date
)
returns table
as
  return (select ConferenceDays.Date, ConferenceDays.PlacesLeft, dbo.PriceOfDayOn(@dateOfCheck, ConferenceDays.DayID) as Price
  from ConferenceDays
  where ConferenceID = @confID)

create function PriceThresholdsForConferenceDays
(
@confID int
)
returns table
as
  return (select ConferenceDays.Date, PT.StartDate, PT.EndDate, PT.Price, PT.StudentDiscount
  from ConferenceDays
         inner join PriceThresholds PT
           on ConferenceDays.DayID = PT.DayID
  where ConferenceDays.ConferenceID = @confID)

create function TotalPriceOfDayBooking
(
@bookingID int,
@day date
)
returns money
as
  begin
    return (select isnull(sum((DayBookings.NumberOfParticipants - 0.01 * dbo.StudentDiscountOfDay(@day, DayBookings.DayID) * DayBookings.NumberOfStudents) * dbo.PriceOfDayOn(@day, DayBookings.DayID)), 0)
    from DayBookings
    where BookingID = @bookingID and isValid = 1)
  end

create function TotalPriceOfWorkshopBooking
(
@bookingID int
)
returns money
as
  begin
    return (select isnull(sum(WorkshopBookings.NumberOfParticipants * W.Price), 0)
    from WorkshopBookings
           inner join Workshops W
             on WorkshopBookings.WorkshopID = W.WorkshopID
           inner join DayBookings DB
             on WorkshopBookings.DayBookingID = DB.DayBookingID
           inner join Bookings B
             on DB.BookingID = B.BookingID
    where B.BookingID = @bookingID and WorkshopBookings.isValid = 1)
  end

create function TotalPriceOfBooking
(
@bookingID int
)
returns money
as
  begin
    return (select dbo.TotalPriceOfDayBooking(@bookingID, Bookings.RegistrationDate) + dbo.TotalPriceOfWorkshopBooking(@bookingID)
    from Bookings
    where BookingID = @bookingID)
  end

create function AmountPaidForBooking
(
@bookingID int
)
returns money
as
  begin
    return (select isnull(sum(P.AmountPaid), 0)
    from Bookings
    left outer join Payments P on Bookings.BookingID = P.BookingID
    where Bookings.BookingID = @bookingID)
  end

create function AmountLeftToPayForBooking
(
@bookingID int
)
returns money
as
  begin
    return dbo.TotalPriceOfBooking(@bookingID) - dbo.AmountPaidForBooking(@bookingID)
  end

create function IsThereACollisionBetweenWorkshops
(
@Workshop1ID int,
@Workshop2ID int
)
returns bit
as
  begin
    declare @dayW1 int = (select DayID
      from Workshops
      where WorkshopID = @Workshop1ID)
    declare @dayW2 int = (select DayID
      from Workshops
      where WorkshopID = @Workshop2ID)

    if @dayW1 <> @dayW2
      return 0

    declare @startW1 time = (select WorkshopStart
      from Workshops
      where WorkshopID = @Workshop1ID)
    declare @endW1 time = (select WorkshopStart
      from Workshops
      where WorkshopID = @Workshop1ID)
    declare @startW2 time = (select WorkshopStart
      from Workshops
      where WorkshopID = @Workshop2ID)
    declare @endW2 time = (select WorkshopStart
      from Workshops
      where WorkshopID = @Workshop2ID)

    if @startW1 > @startW2 and @endW2 > @startW1
      return 1
    else if @startW2 > @startW1 and @endW1 > @startW2
      return 1
    return 0
  end

create function DaysLeftToConference
(
@conferenceID int,
@currentDay date
)
returns int
as
  begin
    return datediff(day, @currentDay,
      (select FirstDay from Conferences where ConferenceID = @conferenceID))
  end

create function DaysFromRegistration
(
@bookingID int,
@currentDay date
)
returns int
as
  begin
    return datediff(day, @currentDay,
                    (select RegistrationDate from Bookings where BookingID = @bookingID))
  end

create function PlacesOnDayBookingLeft
(
@dayBookingID int
)
returns int
as
  begin
    declare @BookedPlaces int = (select NumberOfParticipants from DayBookings where DayBookingID = @dayBookingID)
    declare @TakenPlaces int = (select count(ParticipantOfDayID) from ParticipantsOfDay where DayBookingID = @dayBookingID)
    return @BookedPlaces - @TakenPlaces
  end

create function PlacesOnWorkshopBookingLeft
(
@workshopBookingID int
)
returns int
as
  begin
    declare @BookedPlaces int = (select NumberOfParticipants from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    declare @TakenPlaces int = (select count(ParticipantOfDayID) from ParticipantsOfWorkshop where WorkshopBookingID = @workshopBookingID)
    return @BookedPlaces - @TakenPlaces
  end

create function RegisteredStudents
(
@dayBookingID int
)
returns int
as
  begin
    return (select count(ParticipantOfDayID) from ParticipantsOfDay
      where DayBookingID = @dayBookingID
      and StudentCardNumber is not null)
  end

create function NumberOfBookedConferences
(
@clientID int
)
returns int
as
  begin
    return (select count(*)
    from Bookings
    where ClientID = @clientID and isValid = 1)
  end

create function TotalPayments
(
@clientID int
)
returns money
as
  begin
    return (select sum(dbo.AmountPaidForBooking(BookingID))
      from Bookings
      where ClientID = @clientID
      and isValid = 1)
  end


