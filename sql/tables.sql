create table Organizers (
  OrganizerID           int not null identity,
  OrganizerName         nvarchar(80) not null,
  ContactName           nvarchar(50) not null,
  Address               nvarchar(128) not null,
  PostalCode            nvarchar(25) not null,
  City                  nvarchar(60) not null,
  Region                nvarchar(60) default null,
  Country               nvarchar(60) not null,
  constraint PK_Organizers primary key (OrganizerID)
)

create table Conferences (
  ConferenceID          int not null identity,
  OrganizerID           int not null,
  ConferenceName        nvarchar(100) not null,
  FirstDay              date not null,
  LastDay               date not null,
  PlaceAddress          nvarchar(128) not null,
  PlaceCity             nvarchar(60) not null,
  PlaceRegion           nvarchar(60) default null,
  PlaceCountry          nvarchar(60) not null,
  constraint PK_Conferences primary key (ConferenceID),
  constraint Conferences_Organizers foreign key (OrganizerID) references Organizers (OrganizerID),
  constraint CK_LastDay_FirstDay_Conferences check (LastDay >= FirstDay)
)

create table Clients (
  ClientID              int not null identity,
  ClientName            nvarchar(80) not null,
  ContactName           nvarchar(50) default null,
  ContactEMail          nvarchar(50) not null check
    (ContactEMail like '%_@_%._%'),
  Address               nvarchar(128) not null,
  City                  nvarchar(60) not null,
  PostalCode            nvarchar(25) not null,
  Region                nvarchar(60) default null,
  Country               nvarchar(60) not null,
  Phone                 varchar(20) not null,
  Fax                   varchar(20) default null,
  constraint PK_Clients primary key (ClientID)
)

create table Bookings (
  BookingID             int not null identity,
  ClientID              int not null,
  ConferenceID          int not null,
  ParticipantsNumber    int not null check
    (ParticipantsNumber > 0),
  RegistrationDate      datetime not null default getdate(),
  isValid               bit not null default 1,
  constraint PK_Bookings primary key (BookingID),
  constraint Bookings_Clients foreign key (ClientID) references Clients (ClientID),
  constraint Bookings_Conferences foreign key (ConferenceID) references Conferences (ConferenceID)
)

create table Payments (
  PaymentID             int not null identity ,
  BookingID             int not null,
  PaymentDate           datetime not null default getdate(),
  AmountPaid            money not null check
    (AmountPaid > 0),
  constraint PK_Payments primary key (PaymentID),
  constraint Payments_Bookings foreign key (BookingID) references Bookings (BookingID)
)

create table ConferenceDays (
  DayID                 int not null identity,
  ConferenceID          int not null,
  Date                  date not null,
  NumberOfPlaces        int not null check
    (NumberOfPlaces > 0),
  PlacesLeft            int not null check
    (PlacesLeft >= 0),
  constraint PK_ConferenceDays primary key (DayID),
  constraint ConferenceDays_Conferences foreign key (ConferenceID) references Conferences (ConferenceID),
  constraint CK_Places_ConferenceDays check (PlacesLeft <= NumberOfPlaces),
  constraint Unique_Days_Conf unique (ConferenceID, Date)
)

create table PriceThresholds (
  ThresholdID           int not null identity,
  DayID                 int not null,
  Price                 money not null check
    (Price >= 0.0),
  StudentDiscount       real not null default 0 check
    (StudentDiscount between 0.0 and 100.0),
  StartDate             date not null,
  EndDate               date not null,
  constraint PK_PriceThresholds primary key (ThresholdID),
  constraint PriceThresholds_ConferenceDays foreign key (DayID) references ConferenceDays (DayID),
  constraint CK_Dates_PriceThresholds check (EndDate >= StartDate)
)

create table Workshops (
  WorkshopID            int not null identity,
  DayID                 int not null,
  WorkshopName          nvarchar(50) not null,
  WorkshopStart         time not null,
  WorkshopEnd           time not null,
  NumberOfPlaces        int not null check
    (NumberOfPlaces > 0),
  PlacesLeft            int not null check
    (PlacesLeft >= 0),
  Price                 money not null default 0 check
    (Price >= 0.0),
  constraint PK_Workshops primary key (WorkshopID),
  constraint Workshops_ConferenceDays foreign key (DayID) references ConferenceDays (DayID),
  constraint CK_Time_Workshops check (WorkshopEnd > WorkshopStart),
  constraint CK_Places_Workshops check (PlacesLeft <= NumberOfPlaces)
)

create table DayBookings (
  DayBookingID          int not null identity,
  DayID                 int not null,
  BookingID             int not null,
  NumberOfParticipants  int not null check
    (NumberOfParticipants > 0),
  NumberOfStudents      int not null default 0 check
    (NumberOfStudents >= 0),
  isValid               bit not null default 1,
  constraint PK_DayBookings primary key (DayBookingID),
  constraint DayBookings_ConferenceDays foreign key (DayID) references ConferenceDays (DayID),
  constraint DayBookings_Bookings foreign key (BookingID) references Bookings (BookingID),
  constraint CK_Students_DayBookings check (NumberOfStudents <= NumberOfParticipants),
  constraint unique_booking unique (DayID, BookingID)
)

create table WorkshopBookings (
  WorkshopBookingID     int not null identity,
  DayBookingID          int not null,
  WorkshopID            int not null,
  NumberOfParticipants  int not null check
    (NumberOfParticipants > 0),
  isValid               bit not null default 1,
  constraint PK_WorkshopBookings primary key (WorkshopBookingID),
  constraint WorkshopBookings_DayBookings foreign key (DayBookingID) references DayBookings (DayBookingID),
  constraint Workshop_WorkshopBookings foreign key (WorkshopID) references Workshops (WorkshopID),
  constraint Unique_Workshop_on_day unique (WorkshopID, DayBookingID)
)

create table Participants (
  ParticipantID         int not null identity,
  FirstName             nvarchar(50) not null,
  LastName              nvarchar(50) not null,
  Title                 nvarchar(15) default null,
  constraint PK_Participants primary key (ParticipantID)
)

create table ParticipantsOfDay (
  ParticipantOfDayID    int not null identity,
  ParticipantID         int not null,
  DayBookingID          int not null,
  StudentCardNumber     varchar(50) default null,
  constraint PK_ParticipantsOfDay primary key (ParticipantOfDayID),
  constraint ParticipantsOfDay_Participants foreign key (ParticipantID) references Participants (ParticipantID),
  constraint ParticipantsOfDay_DayBookings foreign key (DayBookingID) references DayBookings (DayBookingID),
  constraint Unique_Participant_for_Day unique (ParticipantID, DayBookingID)
)

create table ParticipantsOfWorkshop (
  WorkshopBookingID     int not null,
  ParticipantOfDayID    int not null,
  constraint PK_ParticipantsOfWorkshop primary key  (WorkshopBookingID, ParticipantOfDayID),
  constraint ParticipantsOfWorkshop_WorkshopBookings foreign key (WorkshopBookingID) references WorkshopBookings (WorkshopBookingID),
  constraint ParticipantsOfWorkshop_ParticipantsOfDay foreign key (ParticipantOfDayID) references ParticipantsOfDay (ParticipantOfDayID)
)

