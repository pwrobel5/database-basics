create view FutureConferences
as
  select ConferenceID, ConferenceName, FirstDay, LastDay, PlaceCity, PlaceCountry
  from Conferences
  where FirstDay > getdate() or getdate() between FirstDay and LastDay

create view DaysWithFreePlaces
as
  select Conferences.ConferenceID, Conferences.ConferenceName, CD.DayID, CD.Date, CD.PlacesLeft, dbo.PriceOfDayOn(getdate(), CD.DayID) as Price
from Conferences
inner join ConferenceDays CD on Conferences.ConferenceID = CD.ConferenceID
where CD.PlacesLeft > 0 and CD.Date >= getdate()

create view WorkshopsWithFreePlaces
as
  select Conferences.ConferenceID, Conferences.ConferenceName, CD.DayID, CD.Date, W.WorkshopID, W.WorkshopName, W.WorkshopStart, W.WorkshopEnd, W.PlacesLeft, W.Price
  from Conferences
  inner join ConferenceDays CD on Conferences.ConferenceID = CD.ConferenceID
  inner join Workshops W on CD.DayID = W.DayID
  where W.PlacesLeft > 0 and CD.Date >= getdate()

create view ParticipantsOfConference
as
  select distinct Conferences.ConferenceID, Conferences.ConferenceName, P.ParticipantID, P.Title, P.LastName, P.FirstName
  from Conferences
  inner join Bookings B on Conferences.ConferenceID = B.ConferenceID
  inner join DayBookings DB on B.BookingID = DB.BookingID
  inner join ParticipantsOfDay POD on DB.DayBookingID = POD.DayBookingID
  inner join Participants P on POD.ParticipantID = P.ParticipantID
  where B.isValid = 1
  and DB.isValid = 1

create view ClientsOfConference
as
  select Conferences.ConferenceID, Conferences.ConferenceName, C.ClientID, C.ClientName,
         isnull(C.ContactName, C.ClientName) as ContactName, C.ContactEMail, C.Address, C.PostalCode,
         isnull(C.Region, '-') as Region, C.Country, B.ParticipantsNumber
  from Conferences
  inner join Bookings B on Conferences.ConferenceID = B.ConferenceID
  inner join Clients C on B.ClientID = C.ClientID
  where B.isValid = 1

create view CancelledBookings
as
  select BookingID, ClientID, ConferenceID, ParticipantsNumber
  from Bookings
  where isValid = 0

create view ClientStatistics
as
  select ClientID, ClientName, dbo.NumberOfBookedConferences(ClientID) as BookedConferencesNumber, dbo.TotalPayments(ClientID) as TotalPayments
  from Clients

create view NotFullyPaidBookings
as
  select BookingID, ClientID, ConferenceID, ParticipantsNumber, RegistrationDate,
         dbo.AmountLeftToPayForBooking(BookingID) as LeftToPay, (7 - dbo.DaysFromRegistration(BookingID, getdate())) as LeftTimeToPay
  from Bookings
  where isValid = 1

create view FullyPaidBookings
as
  select BookingID, ClientID, ConferenceID, ParticipantsNumber, RegistrationDate,
         dbo.AmountPaidForBooking(BookingID) as MoneyPaid
  from Bookings
  where dbo.AmountLeftToPayForBooking(BookingID) = 0
  and isValid = 1

create view DayBookingsWithoutCompleteParticipants
as
  select DayBookings.DayID, B.BookingID, B.ClientID, B.ConferenceID, dbo.PlacesOnDayBookingLeft(DayBookings.DayBookingID) as UntakenPlaces
  from DayBookings
  inner join Bookings B on DayBookings.BookingID = B.BookingID
  where dbo.PlacesOnDayBookingLeft(DayBookings.DayBookingID) > 0 and DayBookings.isValid = 1

create view WorkshopBookingsWithoutCompleteParticipants
as
  select WorkshopBookings.WorkshopID, B.BookingID, B.ClientID, B.ConferenceID, dbo.PlacesOnWorkshopBookingLeft(WorkshopBookings.WorkshopBookingID) as UntakenPlaces
  from WorkshopBookings
  inner join DayBookings D on WorkshopBookings.DayBookingID = D.DayBookingID
  inner join Bookings B on D.BookingID = B.BookingID
  where dbo.PlacesOnWorkshopBookingLeft(WorkshopBookings.WorkshopBookingID) > 0 and WorkshopBookings.isValid = 1

