comp_names = open('company-names.csv', 'r')
comp_names_list = comp_names.readlines()
comp_names.close()
for i in range(0, len(comp_names_list)):
    if '"' in comp_names_list[i]:
        comp_names_list[i] = comp_names_list[i].replace('"', '')

full_names = open('full-names.csv', 'r')
full_names_list = full_names.readlines()
full_names.close()
for i in range(0, len(full_names_list)):
    if "'" in full_names_list[i]:
        full_names_list[i] = full_names_list[i].replace("'", "")

addresses = open('addresses.csv', 'r')
addresses_list = addresses.readlines()
addresses.close()
for i in range(0, len(addresses_list)):
    if "'" in addresses_list[i]:
        addresses_list[i] = addresses_list[i].replace("'", "")

conference_names = open('conf-names.csv', 'r')
conference_names_list = conference_names.readlines()
conference_names.close()

num_of_places = open('num-of-places.csv', 'r')
num_of_places_list = num_of_places.readlines()
num_of_places.close()

conf_prices = open('conf-prices.csv', 'r')
conf_prices_list = conf_prices.readlines()
conf_prices.close()
for i in range(0, len(conf_prices_list)):
    if "," in conf_prices_list[i]:
        conf_prices_list[i] = conf_prices_list[i].replace(",", ".")
        
workshop_names = open('workshop-names.csv', 'r')
workshop_names_list = workshop_names.readlines()
workshop_names.close()

e_mails = open('e-mails.csv', 'r')
e_mails_list = e_mails.readlines()
e_mails.close()

phones = open('phones.csv', 'r')
phones_list = phones.readlines()
phones.close()

titles = open('titles.csv', 'r')
titles_list = titles.readlines()
titles.close()

student_cards = open('student-cards.csv', 'r')
student_cards_list = student_cards.readlines()
student_cards.close()

def make_insert_query(table, columns, values):
    result = "insert into " + table + " ("
    for i in columns[0:-1]:
        result += i     
        result += ", "
    result += columns[-1]
    result += ") values ("
    for i in values[0:-1]:
        if i == '':
            result += "null"
        else:
            result += "'" +  i.replace('\n', '') + "'"
        result += ", "
    if values[-1] == '':
        result += "null"
    else:
        result += "'" + values[-1].replace('\n', '') + "'"
    result += ") \n"
    return result

def make_update_query(table, column_to_set, value, where_column, where_value):
    result = "update " + table + " set " + column_to_set + " = " + str(value) + " where " + \
    where_column + " = " + str(where_value) + '\n'
    return result

def make_organizers(attributes):
    organizers_cols = ["OrganizerID", "OrganizerName", "ContactName", "Address", "PostalCode", "City", "Region", "Country"]
    return make_insert_query("Organizers", organizers_cols, attributes)
    
def make_conferences(attributes):
    conferences_cols = ["ConferenceID", "OrganizerID", "ConferenceName", "FirstDay", "LastDay", "PlaceAddress", "PlaceCity", "PlaceRegion", "PlaceCountry"]
    return make_insert_query("Conferences", conferences_cols, attributes)

def make_confdays(attributes):
    confdays_cols = ["DayID", "ConferenceID", "Date", "NumberOfPlaces", "PlacesLeft"]
    return make_insert_query("ConferenceDays", confdays_cols, attributes)

def make_pricethr(attributes):
    pricethr_cols = ["ThresholdID", "DayID", "Price", "StudentDiscount", "StartDate", "EndDate"]
    return make_insert_query("PriceThresholds", pricethr_cols, attributes)

def make_workshops(attributes):
    workshops_cols = ["WorkshopID", "DayID", "WorkshopName", "WorkshopStart", "WorkshopEnd", "NumberOfPlaces", "PlacesLeft", "Price"]
    return make_insert_query("Workshops", workshops_cols, attributes)

def make_clients(attributes):
    clients_cols = ["ClientID", "ClientName", "ContactName", "ContactEMail", "Address", "City", "PostalCode", "Region", "Country", "Phone", "Fax"]
    return make_insert_query("Clients", clients_cols, attributes)

def make_booking(attributes):
    booking_cols = ["BookingID", "ClientID", "ConferenceID", "ParticipantsNumber", "RegistrationDate", "isValid"]
    return make_insert_query("Bookings", booking_cols, attributes)

def make_payment(attributes):
    payment_cols = ["PaymentID", "BookingID", "PaymentDate", "AmountPaid"]
    return make_insert_query("Payments", payment_cols, attributes)
    
def make_daybooking(attributes):
    daybooking_cols = ["DayBookingID", "DayID", "BookingID", "NumberOfParticipants", "NumberOfStudents", "isValid"]
    return make_insert_query("DayBookings", daybooking_cols, attributes)

def make_workshopbooking(attributes):
    workshopbooking_cols = ["WorkshopBookingID", "DayBookingID", "WorkshopID", "NumberOfParticipants", "isValid"]
    return make_insert_query("WorkshopBookings", workshopbooking_cols, attributes)

def make_participant(attributes):
    participant_cols = ["ParticipantID", "FirstName", "LastName", "Title"]
    return make_insert_query("Participants", participant_cols, attributes)

def make_participant_of_day(attributes):
    pod_cols = ["ParticipantOfDayID", "ParticipantID", "DayBookingID", "StudentCardNumber"]
    return make_insert_query("ParticipantsOfDay", pod_cols, attributes)

def make_participant_of_workshop(attributes):
    pow_cols = ["WorkshopBookingID", "ParticipantOfDayID"]
    return make_insert_query("ParticipantsOfWorkshop", pow_cols, attributes)

import random

set_command = "set identity_insert "

organizers_out = open('gen-organizers.sql', 'w')
organizers_out.write(set_command + "Organizers on\n\n")

conferences_out = open('gen-conferences.sql', 'w')
conferences_out.write(set_command + "Conferences on\n\n")

confdays_out = open('gen-confdays.sql', 'w')
confdays_out.write(set_command + "ConferenceDays on\n\n")

pricethr_out = open('gen-pricethr.sql', 'w')
pricethr_out.write(set_command + "PriceThresholds on\n\n")

workshops_out = open('gen-workshops.sql', 'w')
workshops_out.write(set_command + "Workshops on\n\n")

clients_out = open('gen-clients.sql', 'w')
clients_out.write(set_command + "Clients on\n\n")

bookings_out = open('gen-bookings.sql', 'w')
bookings_out.write(set_command + "Bookings on\n\n")

payments_out = open('gen-payments.sql', 'w')
payments_out.write(set_command + "Payments on\n\n")

daybookings_out = open('gen-daybookings.sql', 'w')
daybookings_out.write(set_command + "DayBookings on\n\n")

workshopbookings_out = open('gen-workshopbookings.sql', 'w')
workshopbookings_out.write(set_command + "WorkshopBookings on\n\n")

participants_out = open('gen-participants.sql', 'w')
participants_out.write(set_command + "Participants on\n\n")

pod_out = open('gen-pods.sql', 'w')
pod_out.write(set_command + "ParticipantsOfDay on\n\n")

pow_out = open('gen-pows.sql', 'w')

day_id = 1
workshop_id = 1
price_thr_id = 1

conf_max_places = []
day_places = []
workshop_places_list = []
conf_start_days = []
conferences_days_ids = {}
conferences_days_workshops_ids = {}

first_years = ('2017', '2018', '2019')
first_months = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12')
first_days = ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12',
              '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23')
student_discounts = ['0', '10', '25', '50']
workshop_starts = ['09:00:00', '11:00:00', '14:00:00']

#making organizers and conferences (and its details)
for organizer_id in range(1,11):
    org_attributes = []
    org_attributes.append(str(organizer_id))
    org_attributes.append(comp_names_list[organizer_id])
    org_attributes.append(full_names_list[organizer_id])
    full_address = addresses_list[organizer_id].split(';')
    for i in full_address:
        org_attributes.append(i)
    if org_attributes[4] == '':
        org_attributes[4] = str(random.randrange(30800,45000))
    organizers_out.write(make_organizers(org_attributes))
        
    #conferences
    first_dates = []
    end_dates = []
    for y in first_years:
        for conf_num in range(0,3):
            month = random.choice(first_months)
            day = int(random.choice(first_days))
            how_long = random.randrange(2,5)
            first_dates.append(y + "-" + month + "-" + str(day))
            end_dates.append(y + "-" + month + "-" + str(day + how_long))

    for conference_id in range(1 + (organizer_id - 1) * 9, (organizer_id) * 9 + 1):
        conf_attributes = [str(conference_id), str(organizer_id)]
        conf_attributes.append(conference_names_list[conference_id])
        conf_attributes.append(first_dates[conference_id % 9])
        conf_attributes.append(end_dates[conference_id % 9])
        conf_full_address = addresses_list[10 + conference_id].split(';') #10 to avoid the same address as organizers
        conf_year = conf_attributes[3][0:4]
        conf_month = conf_attributes[3][5:7]
        conf_fday = int(conf_attributes[3][8:10])
        conf_lday = int(conf_attributes[4][8:10])
        for i in range(0, len(conf_full_address)):
            if i != 1: #on 1st position there is a postal code which is not needed in Conference table
                conf_attributes.append(conf_full_address[i])
        conferences_out.write(make_conferences(conf_attributes))
        conf_start_days.append(first_dates[conference_id % 9])
        
        #conference days
        day_counter = 0
        day_diff = conf_lday - conf_fday  
        temp_places = []
        days_id_list = []
        
        while day_counter <= day_diff:
            date = conf_year + "-" + conf_month + "-" + str(day_counter + conf_fday)
            places = random.choice(num_of_places_list)
            day_attributes = [str(day_id), str(conference_id), date, places, places]
            confdays_out.write(make_confdays(day_attributes))
            day_places.append(int(places))
            temp_places.append(int(places))  
            days_id_list.append(day_id)
            
            #price thresholds
            day_price = random.choice(conf_prices_list)[1:]
            stud_disc = random.choice(student_discounts)
            thr_starts = ['1970-01-01']
            thr_year = int(conf_year)
            thr_month = int(conf_month) - 3
            if thr_month < 0:
                thr_month %= 12
                thr_year -= 1
            elif thr_month == 0:
                thr_month = 12
                thr_year -= 1            
            thr_day = conf_fday + day_counter
            thr_ends = [str(thr_year) + "-" + str(thr_month) + "-" + str(thr_day)]
            for thr_counter in range(0,3):
                thr_starts.append(str(thr_year) + "-" + str(thr_month) + "-" + str(thr_day + 1))
                thr_month += 1
                if thr_month > 12:
                    thr_month %= 12
                    thr_year += 1
                thr_ends.append(str(thr_year) + "-" + str(thr_month) + "-" + str(thr_day))            
            
            for price_num in range(0,4):            
                pricethr_attributes = [str(price_thr_id), str(day_id), day_price, stud_disc, thr_starts[price_num], thr_ends[price_num]]
                pricethr_out.write(make_pricethr(pricethr_attributes))
                price_thr_id += 1                
                price = float(day_price)
                price *= 1.15
                day_price = str(price)     
        
            #workshops
            workshop_number = random.randrange(2,6)
            workshop_list = []
            for workshop_num in range(0, workshop_number):
                workshop_attributes = [str(workshop_id), str(day_id), random.choice(workshop_names_list)]
                workshop_start_time = random.choice(workshop_starts)
                workshop_attributes.append(workshop_start_time)
                workshop_end_time = str(int(workshop_start_time[0:2]) + random.randrange(1,4))
                workshop_end_time += ":00:00"
                workshop_attributes.append(workshop_end_time)
                workshop_places = int(random.uniform(0.1, 1.0) * int(places))
                if workshop_places == 0:
                    workshop_places += 1
                workshop_attributes.append(str(workshop_places))
                workshop_attributes.append(str(workshop_places))
                workshop_attributes.append(str(random.uniform(0.0, 0.1) * price))
                workshops_out.write(make_workshops(workshop_attributes))
                workshop_list.append(workshop_id)
                workshop_places_list.append(workshop_places)
            
                workshop_id += 1
            conferences_days_workshops_ids[day_id] = workshop_list
            
            day_counter += 1
            day_id += 1
        max_places = 0
        for el in temp_places:
            if el > max_places:
                max_places = el
        conf_max_places.append(max_places)
        conferences_days_ids[conference_id] = days_id_list

booking_id = 1
payments_id = 1
day_booking_id = 1
workshop_booking_id = 1
bookings_days_ids_nums = {}
number_of_bookings = 0
booking_workshops_ids_nums = {}

#Clients
for client_id in range(1, 751):
    client_attributes = [str(client_id)]
    is_company = random.randint(0,2)
    if is_company == 1:
        client_attributes.append(comp_names_list[client_id + 20]) #to avoid the same values as in organizers
        client_attributes.append(full_names_list[client_id + 20])
    else:
        client_attributes.append(full_names_list[client_id + 20])
        client_attributes.append('')
    client_attributes.append(e_mails_list[client_id])
    client_full_address = addresses_list[len(addresses_list) - client_id].split(';')
    for i in client_full_address:
        client_attributes.append(i)
    buff = client_attributes[5]
    client_attributes[5] = client_attributes[6]
    client_attributes[6] = buff
    if client_attributes[6] == '':
        client_attributes[6] = str(random.randrange(30800,45000))
    client_attributes.append(phones_list[client_id])
    if is_company == 1:
        client_attributes.append(str(random.randrange(10005, 67889)))
    else:
        client_attributes.append('')
    clients_out.write(make_clients(client_attributes))
    
    #bookings
    number_of_bookings = random.randrange(2,5)
    for booking_num in range(0, number_of_bookings):
        booking_attributes = [str(booking_id), str(client_id)]
        booking_number_of_places = 0
        while booking_number_of_places == 0:
            conf_id = random.randrange(0, len(conf_max_places))
            if conf_max_places[conf_id] > 15:
                booking_number_of_places = random.randrange(1, int(conf_max_places[conf_id] * 0.15))
            elif conf_max_places[conf_id] > 0:
                booking_number_of_places = 1
            else:
                booking_number_of_places = 0
        booking_attributes.append(str(conf_id + 1))
        booking_attributes.append(str(booking_number_of_places))
        
        conf_max_places[conf_id] -= booking_number_of_places
        
        conf_start_date = conf_start_days[conf_id]
        conf_year = int(conf_start_date[0:4])
        conf_month = int(conf_start_date[5:7])
        conf_day = int(conf_start_date[8:10])
        
        res_month_diff = random.randrange(1,6)
        res_month = conf_month - res_month_diff
        if res_month < 0:
            res_month %= 12
            res_year = conf_year - 1
        elif res_month == 0:
            res_month = 12
            res_year = conf_year - 1
        else:
            res_year = conf_year
        res_day = conf_day
        
        res_date = str(res_year) + "-"
        if res_month < 10:
            res_date += "0"
        res_date += str(res_month) + "-"
        if res_day < 10:
            res_date += "0"
        res_date += str(res_day)
        
        booking_attributes.append(res_date)
        booking_attributes.append('1')
        bookings_out.write(make_booking(booking_attributes))
        
        #Payments        
        payments_number = random.randrange(0,3)
        pay_day = res_day
        for payment_made in range(0, payments_number):
            payments_attributes = [str(payments_id), str(booking_id)]
            pay_day += 1
            pay_date = res_date[0:8]
            if pay_day < 10:
                pay_date += "0"
            pay_date += str(pay_day)
            payments_attributes.append(pay_date)
            amount_paid = float(random.choice(conf_prices_list)[1:]) * 0.15
            payments_attributes.append(str(amount_paid))
            payments_out.write(make_payment(payments_attributes))
            payments_id += 1
        
        #DaysBooking
        book_days_info = []
        
        for conf_day_id in conferences_days_ids[conf_id + 1]:
            make_booking_for_this_day = random.randrange(0,2)
            if make_booking_for_this_day == 1:
                days_booking_attributes = [str(day_booking_id), str(conf_day_id), str(booking_id)]
                max_allowed_places_taken = min(booking_number_of_places, day_places[conf_day_id - 1])
                if max_allowed_places_taken == 0:
                    continue
                elif max_allowed_places_taken == 1:
                    booked_places = 1
                else:
                    booked_places = random.randrange(1, max_allowed_places_taken)
                    
                days_booking_attributes.append(str(booked_places))
                number_of_students = random.randrange(0, booked_places + 1)
                days_booking_attributes.append(str(number_of_students))
                days_booking_attributes.append('1')
                day_places[conf_day_id - 1] -= booked_places
                
                daybookings_out.write(make_daybooking(days_booking_attributes))
                daybookings_out.write(make_update_query("ConferenceDays", "PlacesLeft", day_places[conf_day_id - 1], "DayID", conf_day_id))
                
                book_days_info.append((day_booking_id, booked_places, number_of_students))
                
                #WorkshopBooking
                workshop_booking_info = []
                
                for workshop_to_book_id in conferences_days_workshops_ids[conf_day_id]:
                    make_booking_for_this_workshop = random.randrange(0,2)
                    if make_booking_for_this_workshop == 1:
                        workshop_booking_attributes = [str(workshop_booking_id), str(day_booking_id), str(workshop_to_book_id)]
                        max_allowed_ws_places_taken = min(booked_places, workshop_places_list[workshop_to_book_id - 1] // 3)
                        if max_allowed_ws_places_taken == 0:
                            continue
                        elif max_allowed_ws_places_taken == 1:
                            booked_workshop_places = 1
                        else:
                            booked_workshop_places = max_allowed_ws_places_taken // 2
                        workshop_booking_attributes.append(str(booked_workshop_places))
                        workshop_booking_attributes.append('1')
                        workshop_places_list[workshop_to_book_id - 1] -= booked_workshop_places

                        workshopbookings_out.write(make_workshopbooking(workshop_booking_attributes))
                        workshopbookings_out.write(make_update_query("Workshops", "PlacesLeft", workshop_places_list[workshop_to_book_id - 1], "WorkshopID", workshop_to_book_id))                        
                        
                        workshop_booking_info.append((workshop_booking_id, booked_workshop_places))
                        
                        workshop_booking_id += 1
                
                booking_workshops_ids_nums[day_booking_id] = workshop_booking_info
                day_booking_id += 1
        bookings_days_ids_nums[booking_id] = book_days_info
        booking_id += 1

#Participants
for participant_id in range(1, 1001):
    participant_attributes = [str(participant_id)]
    participant_full_name = full_names_list[participant_id - 1]
    participant_full_name = participant_full_name.split()
    participant_attributes.append(participant_full_name[0])
    participant_attributes.append(participant_full_name[1])
    
    participant_with_title = random.randrange(0,2)
    if participant_with_title == 1:
        participant_title = random.choice(titles_list)
        participant_attributes.append(participant_title)
    else:
        participant_attributes.append('')
    
    participants_out.write(make_participant(participant_attributes))

participant_of_day_id = 1
    
#ParticipantsOfDay
for booking_id in bookings_days_ids_nums.keys():
    for booking_day_info in bookings_days_ids_nums[booking_id]:
        booking_day_id = booking_day_info[0]
        number_of_participants = booking_day_info[1]
        number_of_students = booking_day_info[2]
            
        complete_all_places = random.randrange(0,2)
        if complete_all_places != 0:
            places_to_fill = number_of_participants
        else:
            places_to_fill = max(number_of_students, random.randrange(0, number_of_participants))

        day_participants_ids = []
        first_pod_id = participant_of_day_id
        
        for participants_of_day in range(0, places_to_fill):
            participant_id = random.randrange(1, 1001)
            while participant_id in day_participants_ids:
                participant_id = random.randrange(1, 1001)
            day_participants_ids.append(participant_id)
            participants_of_day_attributes = [str(participant_of_day_id), str(participant_id), str(booking_day_id)]
            
            if number_of_students > 0:
                student_card_number = random.choice(student_cards_list)
                number_of_students -= 1
            else:
                student_card_number = ''
            participants_of_day_attributes.append(student_card_number)

            pod_out.write(make_participant_of_day(participants_of_day_attributes))
            participant_of_day_id += 1
            
        #ParticipantsOfWorkshop
        for workshop_booking_info in booking_workshops_ids_nums[booking_day_id]:
            workshop_booking_id = workshop_booking_info[0]
            workshop_booked_places = workshop_booking_info[1]
            workshop_filled_places = min(workshop_booked_places, places_to_fill)                
            taken_pod_ids = [i for i in range(first_pod_id, participant_of_day_id)]                
            
            for workshop_place in range(0, workshop_filled_places):
                pow_attributes = [str(workshop_booking_id)]
                pod_id_to_become_pow = random.choice(taken_pod_ids)
                taken_pod_ids.remove(pod_id_to_become_pow)
                pow_attributes.append(str(pod_id_to_become_pow))
                pow_out.write(make_participant_of_workshop(pow_attributes))
                
            
            
organizers_out.write('\n' + set_command + "Organizers off\n\n")
conferences_out.write('\n' + set_command + "Conferences off\n\n")
confdays_out.write('\n' + set_command + "ConferenceDays off\n\n")
pricethr_out.write('\n' + set_command + "PriceThresholds off\n\n")
workshops_out.write('\n' + set_command + "Workshops off\n\n")
clients_out.write('\n' + set_command + "Clients off\n\n")
bookings_out.write('\n' + set_command + "Bookings off\n\n")
payments_out.write('\n' + set_command + "Payments off\n\n")
daybookings_out.write('\n' + set_command + "DayBookings off\n\n")
workshopbookings_out.write('\n' + set_command + "WorkshopBookings off\n\n")
participants_out.write('\n' + set_command + "Participants off\n\n")
pod_out.write('\n' + set_command + "ParticipantsOfDay off\n\n")

organizers_out.close()
conferences_out.close()
confdays_out.close()
pricethr_out.close()
workshops_out.close()
clients_out.close()
bookings_out.close()
payments_out.close()
daybookings_out.close()
workshopbookings_out.close()
participants_out.close()
pod_out.close()
pow_out.close()

import os
os.system('cat gen-organizers.sql gen-conferences.sql gen-confdays.sql gen-pricethr.sql gen-workshops.sql \
gen-clients.sql gen-bookings.sql gen-payments.sql gen-daybookings.sql gen-workshopbookings.sql \
gen-participants.sql gen-pods.sql gen-pows.sql > generator.sql')
os.system('rm gen-*')
