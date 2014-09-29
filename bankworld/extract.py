import psycopg2
import csv
import datetime
conn = psycopg2.connect("dbname=ramz user=ramz")

cur = conn.cursor()

def longitude_to_timediff(longitude):
    return  int(abs(longitude) / 15)

def extract_lat_long():
    with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/branch_lat_long','w') as fp:
        for i in range(1,51):
            cur.execute("select min(latitude), max(latitude), min(longitude), max(longitude) from region_info_{0}".format(i))
            rows = cur.fetchall()
            min_lat, max_lat, min_long, max_long = rows[0]
            print("Query done for Region {0}".format(i))
            writer = csv.writer(fp, delimiter=',')
            writer.writerow(("region-{0}".format(i), min_lat, max_lat, min_long, max_long))

def extract():

    # for activity in range(1,3):
    with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/atm_report_status.csv','w') as fp:
        for i in range(1,57):
            if 0 < i <= 10:
                total_machines = 41000
                server_machines = 28000
                atm_machines = 2000
                ws_machines = 11000
            elif 51 <= i < 56:
                total_machines = 50005
                server_machines = 50000
                atm_machines = 0
                ws_machines = 5
                continue
            elif i == 56:
                total_machines = 15000
                server_machines = 0
                atm_machines = 0
                ws_machines = 15000
            elif i == 0:
                total_machines = 15000
                server_machines = 250000
                atm_machines = 0
                ws_machines = 15000
            else:
                total_machines = 5500
                server_machines = 2250
                atm_machines = 500
                ws_machines = 2750
            print("Query Started for Region {0} ".format(i))
            cur.execute("select longitude from region_info_{0} limit 1".format(i))
            rows = cur.fetchall()
            lag = longitude_to_timediff(rows[0][0])
            print lag
            # cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='teller' ".format(i))
            # rows = cur.fetchall()
            # num_teller = rows[0][0]
            # print num_teller
            cur.execute("select healthtime, businessunit, count(distinct(ipaddr)) "
                        "from region_info_{0} where machineclass='atm' group by healthtime, businessunit".format(i))
            rows = cur.fetchall()
            writer = csv.writer(fp, delimiter=',')
            print("Query done for Region {0}".format(i))
            # for row in rows:
            #     writer.writerow(row)

            start_time = datetime.time(7,0,0)
            end_time = datetime.time(18,0,0)
            for row in rows:
                if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
                    writer.writerow((row[0], row[1], row[2], atm_machines))
                else:
                    writer.writerow((row[0], row[1], row[2], 0))

# extract_lat_long()
# extract()

# def extract_bu_count():
#     with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/servercount.csv','w') as fp:
#         writer = csv.writer(fp, delimiter=',')
#         for i in range(51):
#             cur.execute("select businessunit, count(distinct(ipaddr)) "
#                         "from region_info_{0} where machineclass='server' group by businessunit".format(i))
#             rows = cur.fetchall()
#             print "Query completed for {0}".format(i)
#             for row in rows:
#                 writer.writerow(row)
#
# extract_bu_count()

def extract_num_conn_count():
    with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/ws_teller_connection.csv','w') as fp:
        writer = csv.writer(fp, delimiter=',')
        for i in range(1,57):
            if 0 < i <= 10:
                total_machines = 41000
                server_machines = 28000
                atm_machines = 2000
                ws_machines = 11000
            elif 51 <= i < 56:
                total_machines = 50005
                server_machines = 50000
                atm_machines = 0
                ws_machines = 5
                continue
            elif i == 56:
                total_machines = 15000
                server_machines = 0
                atm_machines = 0
                ws_machines = 15000
            elif i == 0:
                total_machines = 15000
                server_machines = 250000
                atm_machines = 0
                ws_machines = 15000
            else:
                total_machines = 5500
                server_machines = 2250
                atm_machines = 500
                ws_machines = 2750

            cur.execute("select longitude from region_info_{0} limit 1".format(i))
            rows = cur.fetchall()
            lag = longitude_to_timediff(rows[0][0])
            print lag
            cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='teller'".format(i))
            rows = cur.fetchall()
            teller_count = rows[0][0]
            cur.execute("select healthtime, businessunit, count(ipaddr), avg(numconnections) "
                        "from region_info_{0} where machineclass='workstation' and machinefunction='teller' group by healthtime, businessunit order by healthtime asc".format(i))
            rows = cur.fetchall()
            print "Query completed for {0}".format(i)
            start_time = datetime.time(7,0,0)
            end_time = datetime.time(18,0,0)
            for row in rows:
                if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
                    writer.writerow((row[0], row[1], row[2], row[3], teller_count))
                else:
                    writer.writerow((row[0], row[1], row[2], row[3], 0))

def extract_num_conn_loan_count():
    with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/ws_loan_connection.csv','w') as fp:
        writer = csv.writer(fp, delimiter=',')
        for i in range(1,57):
            if 0 < i <= 10:
                total_machines = 41000
                server_machines = 28000
                atm_machines = 2000
                ws_machines = 11000
            elif 51 <= i < 56:
                total_machines = 50005
                server_machines = 50000
                atm_machines = 0
                ws_machines = 5
                continue
            elif i == 56:
                total_machines = 15000
                server_machines = 0
                atm_machines = 0
                ws_machines = 15000
            elif i == 0:
                total_machines = 15000
                server_machines = 250000
                atm_machines = 0
                ws_machines = 15000
            else:
                total_machines = 5500
                server_machines = 2250
                atm_machines = 500
                ws_machines = 2750

            cur.execute("select longitude from region_info_{0} limit 1".format(i))
            rows = cur.fetchall()
            lag = longitude_to_timediff(rows[0][0])
            print lag
            cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='loan'".format(i))
            rows = cur.fetchall()
            teller_count = rows[0][0]
            cur.execute("select healthtime, businessunit, count(ipaddr), avg(numconnections) "
                        "from region_info_{0} where machineclass='workstation' and machinefunction='loan' group by healthtime, businessunit order by healthtime asc".format(i))
            rows = cur.fetchall()
            print "Query completed for {0}".format(i)
            start_time = datetime.time(7,0,0)
            end_time = datetime.time(18,0,0)
            for row in rows:
                if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
                    writer.writerow((row[0], row[1], row[2], row[3], teller_count))
                else:
                    writer.writerow((row[0], row[1], row[2], row[3], 0))

def extract_num_conn_office_count():
    with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/ws_office_connection.csv','w') as fp:
        writer = csv.writer(fp, delimiter=',')
        for i in range(1,57):
            if 0 < i <= 10:
                total_machines = 41000
                server_machines = 28000
                atm_machines = 2000
                ws_machines = 11000
            elif 51 <= i < 56:
                total_machines = 50005
                server_machines = 50000
                atm_machines = 0
                ws_machines = 5
                continue
            elif i == 56:
                total_machines = 15000
                server_machines = 0
                atm_machines = 0
                ws_machines = 15000
            elif i == 0:
                total_machines = 15000
                server_machines = 250000
                atm_machines = 0
                ws_machines = 15000
            else:
                total_machines = 5500
                server_machines = 2250
                atm_machines = 500
                ws_machines = 2750

            cur.execute("select longitude from region_info_{0} limit 1".format(i))
            rows = cur.fetchall()
            lag = longitude_to_timediff(rows[0][0])
            print lag
            cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='office'".format(i))
            rows = cur.fetchall()
            teller_count = rows[0][0]
            cur.execute("select healthtime, businessunit, count(ipaddr), avg(numconnections) "
                        "from region_info_{0} where machineclass='workstation' and machinefunction='office' group by healthtime, businessunit order by healthtime asc".format(i))
            rows = cur.fetchall()
            print "Query completed for {0}".format(i)
            start_time = datetime.time(7,0,0)
            end_time = datetime.time(18,0,0)
            for row in rows:
                if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
                    writer.writerow((row[0], row[1], row[2], row[3], teller_count))
                else:
                    writer.writerow((row[0], row[1], row[2], row[3], 0))

extract_num_conn_count()
extract_num_conn_loan_count()
extract_num_conn_office_count()