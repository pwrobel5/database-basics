create procedure AddOrganizer
  @orgName nvarchar(50),
  @contactName nvarchar(50),
  @address nvarchar(128),
  @postalCode nvarchar(10),
  @city nvarchar(25),
  @region nvarchar(25),
  @country nvarchar(25)
as
  begin try
    insert into Organizers
    (OrganizerName, ContactName, Address, PostalCode, City, Region, Country)
    values
    (@orgName, @contactName, @address, @postalCode, @city, @region, @country)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Organizer. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddConference
  @organizerID int,
  @conferenceName nvarchar(100),
  @firstDay date,
  @lastDay date,
  @placeAddress nvarchar(128),
  @placeCity nvarchar(25),
  @placeRegion nvarchar(25),
  @placeCountry nvarchar(25)
as
  begin try
    if not exists(select * from Organizers where OrganizerID = @organizerID)
      throw 50001, 'Organizer does not exist!', 1
    insert into Conferences
    (OrganizerID, ConferenceName, FirstDay, LastDay, PlaceAddress, PlaceCity, PlaceRegion, PlaceCountry)
    values
    (@organizerID, @conferenceName, @firstDay, @lastDay, @placeAddress, @placeCity, @placeRegion, @placeCountry)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Conference. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddConferenceDay
  @confID int,
  @date date,
  @numOfPlaces int
as
  begin try
    if not exists(select * from Conferences where ConferenceID = @confID)
      throw 50001, 'Conference does not exist!', 1
    if exists(select * from ConferenceDays where ConferenceID = @confID and Date = @date)
      throw 50001, 'This day is already declared!', 1
    insert into ConferenceDays
    (ConferenceID, Date, NumberOfPlaces, PlacesLeft)
    values
    (@confID, @date, @numOfPlaces, @numOfPlaces)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding ConferenceDay. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddWorkshop
  @dayID int,
  @workshopName nvarchar(50),
  @workshopStart time,
  @workshopEnd time,
  @numOfPlaces int,
  @price money
as
  begin try
    if not exists(select * from ConferenceDays where DayID = @dayID)
      throw 50001, 'Day of Conference does not exist!', 1
    insert into Workshops
    (DayID, WorkshopName, WorkshopStart, WorkshopEnd, NumberOfPlaces, PlacesLeft, Price)
    values
    (@dayID, @workshopName, @workshopStart, @workshopEnd, @numOfPlaces, @numOfPlaces, @price)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Workshop. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddPriceThreshold
  @dayID int,
  @price money,
  @studentDiscount real,
  @startDate date,
  @endDate date
as
  begin try
    if not exists(select * from ConferenceDays where DayID = @dayID)
      throw 50001, 'Day of Conference does not exist!', 1
    if exists(select * from PriceThresholds where (StartDate between @startDate and @endDate) or (EndDate between @startDate and @endDate))
      throw 50001, 'Collision with existing threshold!', 1
    insert into PriceThresholds
    (DayID, Price, StudentDiscount, StartDate, EndDate)
    values
    (@dayID, @price, @studentDiscount, @startDate, @endDate)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Price Threshold. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangeConferenceDetails
  @confID int,
  @newName nvarchar(100),
  @newStart date,
  @newEnd date,
  @newAddress nvarchar(128),
  @newCity nvarchar(25),
  @newRegion nvarchar(25),
  @newCountry nvarchar(25)
as
  begin try
    if not exists(select * from Conferences where ConferenceID = @confID)
      throw 50001, 'Conference does not exist!', 1
    if @newName is not null
    begin
      update Conferences
      set ConferenceName = @newName
      where ConferenceID = @confID
    end
    if @newStart is not null
    begin
      update Conferences
      set FirstDay = @newStart
      where ConferenceID = @confID
    end
    if @newEnd is not null
    begin
      update Conferences
      set LastDay = @newEnd
      where ConferenceID = @confID
    end
    if @newAddress is not null
    begin
      update Conferences
      set PlaceAddress = @newAddress
      where ConferenceID = @confID
    end
    if @newCity is not null
    begin
      update Conferences
      set PlaceCity = @newCity
      where ConferenceID = @confID
    end
    if @newRegion is not null
    begin
      update Conferences
      set PlaceRegion = @newRegion
      where ConferenceID = @confID
    end
    if @newCountry is not null
    begin
      update Conferences
      set PlaceCountry = @newCountry
      where ConferenceID = @confID
    end
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Conference details. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangeDayPlaces
  @dayID int,
  @newNumberOfPlaces int
as
  begin try
    if not exists(select * from ConferenceDays where DayID = @dayID)
      throw 50001, 'Conference Day does not exist!', 1

    declare @diff int = (select NumberOfPlaces from ConferenceDays where DayID = @dayID) - @newNumberOfPlaces
    declare @placesLeft int = (select PlacesLeft from ConferenceDays where DayID = @dayID)
    if @diff > @placesLeft
      throw 50001, 'There are too many participants of that day to set this number of places!', 1

    update ConferenceDays
    set NumberOfPlaces = @newNumberOfPlaces
    where DayID = @dayID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Conference Day places. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangeWorkshopPlaces
  @workshopID int,
  @newNumberOfPlaces int
as
  begin try
    if not exists(select * from Workshops where WorkshopID = @workshopID)
      throw 50001, 'Workshop does not exist!', 1

    declare @diff int = (select NumberOfPlaces from Workshops where WorkshopID = @workshopID) - @newNumberOfPlaces
    declare @placesLeft int = (select PlacesLeft from Workshops where WorkshopID = @workshopID)
    if @diff > @placesLeft
      throw 50001, 'There are too many participants of that workshop to set this number of places!', 1

    update Workshops
    set NumberOfPlaces = @newNumberOfPlaces
    where WorkshopID = @workshopID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Workshop places. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangeWorkshopPrice
  @workshopID int,
  @newPrice money
as
  begin try
    if not exists(select * from Workshops where WorkshopID = @workshopID)
      throw 50001, 'Workshop does not exist!', 1

    update Workshops
    set Price = @newPrice
    where WorkshopID = @workshopID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Workshop price. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangePriceThreshold
  @thresholdID int,
  @newPrice money,
  @newStart date,
  @newEnd date,
  @newStudentDiscount real
as
  begin try
    if not exists(select * from PriceThresholds where ThresholdID = @thresholdID)
      throw 50001, 'Price Threshold does not exist!', 1

    if @newPrice is not null
    begin
      update PriceThresholds
      set Price = @newPrice
      where ThresholdID = @thresholdID
    end

    if @newStudentDiscount is not null
    begin
      update PriceThresholds
      set StudentDiscount = @newStudentDiscount
      where ThresholdID = @thresholdID
    end

    declare @oldEnd date = (select EndDate from PriceThresholds where ThresholdID = @thresholdID)
    declare @oldStart date = (select StartDate from PriceThresholds where ThresholdID = @thresholdID)

    if @newStart is not null
    begin
      if exists(select * from PriceThresholds where (StartDate between @newStart and @oldEnd) or (EndDate between @newStart and @oldEnd))
        throw 50001, 'Collision with existing threshold!', 1
      update PriceThresholds
      set StartDate = @newStart
      where ThresholdID = @thresholdID

      set @oldStart = @newStart
    end

    if @newEnd is not null
    begin
      if exists(select * from PriceThresholds where (StartDate between @oldStart and @newEnd) or (EndDate between @oldStart and @newEnd))
        throw 50001, 'Collision with existing threshold!', 1
      update PriceThresholds
      set EndDate = @newEnd
      where ThresholdID = @thresholdID
    end
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Price Threshold. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddClient
  @clientName nvarchar(50),
  @contactName nvarchar(50),
  @contactEmail nvarchar(50),
  @address nvarchar(128),
  @city nvarchar(25),
  @postalcode nvarchar(10),
  @region nvarchar(25),
  @country nvarchar(25),
  @phone varchar(20),
  @fax varchar(20)
as
  begin try
    insert into Clients
    (ClientName, ContactName, ContactEMail, Address, City, PostalCode, Region, Country, Phone, Fax)
    values
    (@clientName, @contactName, @contactEmail, @address, @city, @postalcode, @region, @country, @phone, @fax)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Client. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddBooking
  @clientID int,
  @conferenceID int,
  @participantsNumber int
as
  begin try
    if not exists(select * from Clients where ClientID = @clientID)
      throw 50001, 'Client does not exist!', 1
    if not exists(select * from Conferences where ConferenceID = @conferenceID)
      throw 50001, 'Conference does not exist!', 1

    insert into Bookings
    (ClientID, ConferenceID, ParticipantsNumber, RegistrationDate, isValid)
    values
    (@clientID, @conferenceID, @participantsNumber, getdate(), 1)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddDayBooking
  @dayID int,
  @bookingID int,
  @numberOfParticipants int,
  @numberOfStudents int
as
  begin try
    if not exists(select * from ConferenceDays where DayID = @dayID)
      throw 50001, 'Conference Day does not exist!', 1
    if not exists(select * from Bookings where BookingID = @bookingID)
      throw 50001, 'Booking does not exist!', 1

    declare @placesLeft int = (select PlacesLeft from ConferenceDays where DayID = @dayID)
    if @numberOfParticipants > @placesLeft
      throw 50001, 'Number of participants bigger than free places!', 1
    if @numberOfParticipants < @numberOfStudents
      throw 50001, 'Incorrect number of students!', 1

    declare @bookedPlaces int = (select ParticipantsNumber from Bookings where BookingID = @bookingID)
    if @bookedPlaces < @numberOfParticipants
      throw 50001, 'Declared number of participants is bigger than number of booked places!', 1

    insert into DayBookings
    (DayID, BookingID, NumberOfParticipants, NumberOfStudents, isValid)
    values
    (@dayID, @bookingID, @numberOfParticipants, @numberOfStudents, 1)

    update ConferenceDays
    set PlacesLeft = @placesLeft - @numberOfParticipants
    where DayID = @dayID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Day Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddWorkshopBooking
  @dayBookingID int,
  @workshopID int,
  @numberOfParticipants int
as
  begin try
    if not exists(select * from DayBookings where DayBookingID = @dayBookingID)
      throw 50001, 'Day Booking does not exist!', 1
    if not exists(select * from Workshops where WorkshopID = @workshopID)
      throw 50001, 'Workshop does not exist!', 1

    declare @bookedPlacesForDay int = (select NumberOfParticipants from DayBookings where DayBookingID = @dayBookingID)
    if @numberOfParticipants > @bookedPlacesForDay
      throw 50001, 'Number of participants bigger than number of booked places for that dat!', 1

    declare @bookedDayID int = (select DayID from DayBookings where DayBookingID = @dayBookingID)
    declare @workshopDayID int = (select WorkshopID from Workshops where WorkshopID = @workshopID)
    if @bookedDayID <> @workshopDayID
      throw 50001, 'Day connected with Day Booking and day of Workshop do not match!', 1

    declare @placesLeft int = (select PlacesLeft from Workshops where WorkshopID = @workshopID)
    if @numberOfParticipants > @placesLeft
      throw 50001, 'Number of participants bigger than free places!', 1

    insert into WorkshopBookings
    (DayBookingID, WorkshopID, NumberOfParticipants, isValid)
    values
    (@dayBookingID, @workshopID, @numberOfParticipants, 1)

    update Workshops
    set PlacesLeft = @placesLeft - @numberOfParticipants
    where WorkshopID = @workshopID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Workshop Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddPayment
  @bookingID int,
  @amountPaid money
as
  begin try
    if not exists(select * from Bookings where BookingID = @bookingID)
      throw 50001, 'Booking does not exist!', 1

    if dbo.AmountLeftToPayForBooking(@bookingID) <= 0
      throw 50001, 'Booking is already fully paid', 1

    insert into Payments
    (BookingID, PaymentDate, AmountPaid)
    values
    (@bookingID, getdate(), @amountPaid)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Payment. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure CancelUnpaidBookings
  @dayThreshold int
as
  begin
    update Bookings
    set isValid = 0
    where dbo.DaysFromRegistration(BookingID, getdate()) > @dayThreshold
    and dbo.AmountLeftToPayForBooking(BookingID) <> 0
  end

create procedure ChangeNumberOfBookingParticipants
  @bookingID int,
  @newNumberOfParticipants int
as
  begin try
    if not exists (select * from Bookings where BookingID = @bookingID)
      throw 50001, 'Booking does not exist!', 1

    update Bookings
    set ParticipantsNumber = @newNumberOfParticipants
    where BookingID = @bookingID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Booking number of participants. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch


create procedure ChangeNumberOfDayParticipants
  @dayBookingID int,
  @newNumberOfParticipants int,
  @newNumberOfStudents int
as
  begin try
    if not exists (select * from DayBookings where DayBookingID = @dayBookingID)
      throw 50001, 'This Day Booking does not exist!', 1

    declare @bookingID int = (select BookingID from DayBookings where DayBookingID = @dayBookingID)
    declare @bookedPlaces int = (select ParticipantsNumber from Bookings where BookingID = @bookingID)
    if @newNumberOfParticipants > @bookedPlaces
      throw 50001, 'Given number of participants bigger than value in booking', 1

    declare @dayid int = (select DayID from DayBookings where DayBookingID = @dayBookingID)
    declare @placesLeft int = (select PlacesLeft from ConferenceDays where DayID = @dayid)
    declare @currentPlaces int = (select NumberOfParticipants from DayBookings where DayBookingID = @dayBookingID)

    if @newNumberOfParticipants is not null
    begin
      if (@newNumberOfParticipants - @currentPlaces) > @placesLeft
        throw 50001, 'Too few free places left to set this number!', 1

      update DayBookings
      set NumberOfParticipants = @newNumberOfParticipants
      where DayBookingID = @dayBookingID

      update ConferenceDays
      set PlacesLeft = @placesLeft - (@newNumberOfParticipants - @currentPlaces)
      where DayID = @dayid

      set @currentPlaces = @newNumberOfParticipants

      update WorkshopBookings
      set NumberOfParticipants = @newNumberOfParticipants
      where DayBookingID = @dayBookingID
      and NumberOfParticipants > @newNumberOfParticipants
    end
    if @newNumberOfStudents is not null
    begin
      if (@newNumberOfStudents > @currentPlaces)
        throw 50001, 'New number of students bigger than declared number of participants!', 1

      update DayBookings
      set NumberOfStudents = @newNumberOfStudents
      where DayBookingID = @dayBookingID
    end

  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Booking number of participants for this day. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure ChangeNumberOfWorkshopParticipants
  @workshopBookingID int,
  @newNumberOfParticipants int
as
  begin try
    if not exists(select * from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
      throw 50001, 'Booking for workshop does not exist!', 1

    declare @dayBookingID int = (select DayBookingID from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    declare @placesBookedForDay int = (select NumberOfParticipants from DayBookings where DayBookingID = @dayBookingID)
    if @newNumberOfParticipants > @placesBookedForDay
      throw 50001, 'Given number of participants bigger than value booked for this day!', 1

    declare @workshopID int = (select WorkshopID from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    declare @placesLeft int = (select PlacesLeft from Workshops where WorkshopID = @workshopID)
    declare @currentPlaces int = (select NumberOfParticipants from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    if (@newNumberOfParticipants - @currentPlaces) > @placesLeft
      throw 50001, 'Too few free places to set this number!', 1

    update WorkshopBookings
    set NumberOfParticipants = @newNumberOfParticipants
    where WorkshopBookingID = @workshopBookingID

    update Workshops
    set PlacesLeft = @placesLeft - (@newNumberOfParticipants - @currentPlaces)
    where WorkshopID = @workshopID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with editing Booking number of participants for this workshop. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure CancelBooking
  @bookingID int
as
  begin try
    if not exists(select * from Bookings where BookingID = @bookingID)
      throw 50001, 'Booking does not exist!', 1

    if (select isValid from Bookings where BookingID = @bookingID) = 0
      throw 50001, 'Booking is already cancelled!', 1

    if dbo.AmountPaidForBooking(@bookingID) <> 0
      throw 50001, 'Booking has got non-zero payments!', 1

    update Bookings
    set isValid = 0
    where BookingID = @bookingID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with cancelling Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure CancelDayBooking
  @dayBookingID int
as
  begin try
    if not exists(select * from DayBookings where DayBookingID = @dayBookingID)
      throw 50001, 'Booking for day does not exist!', 1

    if (select isValid from DayBookings where DayBookingID = @dayBookingID) = 0
      throw 50001, 'Booking for day is already cancelled!', 1

    declare @bookingID int = (select BookingID from DayBookings where DayBookingID = @dayBookingID)
    if dbo.AmountPaidForBooking(@bookingID) <> 0
      throw 50001, 'Booking has got non-zero payments!', 1

    update DayBookings
    set isValid = 0
    where DayBookingID = @dayBookingID

    declare @dayID int = (select DayID from DayBookings where DayBookingID = @dayBookingID)
    declare @numberOfPlacesMadeFree int = (select NumberOfParticipants from DayBookings where DayBookingID = @dayBookingID)
    declare @placesLeft int = (select PlacesLeft from ConferenceDays where DayID = @dayID)
    update ConferenceDays
    set PlacesLeft = @placesLeft + @numberOfPlacesMadeFree
    where DayID = @dayID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with cancelling Day Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure CancelWorkshopBooking
  @workshopBookingID int
as
  begin try
    if not exists(select * from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
      throw 50001, 'Booking for workshop does not exist!', 1

    if (select isValid from WorkshopBookings where WorkshopBookingID = @workshopBookingID) = 0
      throw 50001, 'Booking for workshop is already cancelled!', 1

    declare @bookingID int = (select DayBookings.BookingID
            from DayBookings
              inner join WorkshopBookings WB
                on DayBookings.DayBookingID = WB.DayBookingID
            where WB.WorkshopBookingID = @workshopBookingID)
    if dbo.AmountPaidForBooking(@bookingID) <> 0
      throw 50001, 'Booking has got non-zero payments!', 1

    update WorkshopBookings
    set isValid = 0
    where WorkshopBookingID = @workshopBookingID

    declare @workshopID int = (select WorkshopID from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    declare @numberOfPlacesMadeFree int = (select NumberOfParticipants from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
    declare @placesLeft int = (select PlacesLeft from Workshops where WorkshopID = @workshopID)

    update Workshops
    set PlacesLeft = @placesLeft + @numberOfPlacesMadeFree
    where WorkshopID = @workshopID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with cancelling Workshop Booking. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddParticipant
  @firstName nvarchar(50),
  @lastName nvarchar(50),
  @title nvarchar(15)
as
  begin try
    insert into Participants
    (FirstName, LastName, Title)
    values
    (@firstName, @lastName, @title)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Participant. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddParticipantToDayBooking
  @participantID int,
  @dayBookingID int,
  @studentCardNumber varchar(15)
as
  begin try
    if not exists(select * from DayBookings where DayBookingID = @dayBookingID)
      throw 50001, 'Booking for day does not exist!', 1

    if not exists(select * from Participants where ParticipantID = @participantID)
      throw 50001, 'Participant does not exist!', 1

    if dbo.PlacesOnDayBookingLeft(@dayBookingID) = 0
      throw 50001, 'All places from booking are occupied!', 1

    insert into ParticipantsOfDay
    (ParticipantID, DayBookingID, StudentCardNumber)
    values
    (@participantID, @dayBookingID, @studentCardNumber)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Participant to a Day. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure AddParticipantToWorkshopBooking
  @workshopBookingID int,
  @participantOfDayID int
as
  begin try
    if not exists(select * from ParticipantsOfDay where ParticipantOfDayID = @participantOfDayID)
      throw 50001, 'This day booking does not exist!', 1

    if not exists(select * from WorkshopBookings where WorkshopBookingID = @workshopBookingID)
      throw 50001, 'This booking for workshop does not exist', 1

    if dbo.PlacesOnWorkshopBookingLeft(@workshopBookingID) = 0
      throw 50001, 'All places from workshop booking are occupied!', 1

    insert into ParticipantsOfWorkshop
    (WorkshopBookingID, ParticipantOfDayID)
    values
    (@workshopBookingID, @participantOfDayID)
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with adding Participant to a Workshop. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure DeleteParticipantFromDayBooking
  @participantOfDayID int
as
  begin try
    if not exists(select * from ParticipantsOfDay where ParticipantOfDayID = @participantOfDayID)
      throw 50001, 'This participant to day assignment does not exist!', 1

    delete from ParticipantsOfDay
    where ParticipantOfDayID = @participantOfDayID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with deleting Participant from Day. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch

create procedure DeleteParticipantFromWorkshop
  @participantOfDayID int,
  @workshopBookingID int
as
  begin try
    if not exists(select * from ParticipantsOfWorkshop
    where ParticipantOfDayID = @participantOfDayID
    and WorkshopBookingID = @workshopBookingID)
      throw 50001, 'This participant to workshop assignment does not exist!', 1

    delete from ParticipantsOfWorkshop
    where ParticipantOfDayID = @participantOfDayID
    and WorkshopBookingID = @workshopBookingID
  end try
  begin catch
    declare @errorMessage nvarchar(2048)
    = 'Error with deleting Participant from Workshop. Message: ' + error_message();
    throw 50001, @errorMessage, 1
  end catch
