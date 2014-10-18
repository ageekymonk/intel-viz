import psycopg2
import csv
import datetime
import operator
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

# def extract_ws_num_conn_count():
#     with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv/ws_connection_new.csv','w') as fp:
#         writer = csv.writer(fp, delimiter=',')
#         for i in range(1,57):
#             if 0 < i <= 10:
#                 total_machines = 41000
#                 server_machines = 28000
#                 atm_machines = 2000
#                 ws_machines = 11000
#             elif 51 <= i < 56:
#                 total_machines = 50005
#                 server_machines = 50000
#                 atm_machines = 0
#                 ws_machines = 5
#                 continue
#             elif i == 56:
#                 total_machines = 15000
#                 server_machines = 0
#                 atm_machines = 0
#                 ws_machines = 15000
#             elif i == 0:
#                 total_machines = 15000
#                 server_machines = 250000
#                 atm_machines = 0
#                 ws_machines = 15000
#             else:
#                 total_machines = 5500
#                 server_machines = 2250
#                 atm_machines = 500
#                 ws_machines = 2750
#
#             cur.execute("select longitude from region_info_{0} where facility='headquarters' limit 1".format(i))
#             rows = cur.fetchall()
#             lag = longitude_to_timediff(rows[0][0])
#             cur.execute("select healthtime, businessunit, machinefunction,count(ipaddr), avg(numconnections) "
#                         "from region_info_{0} where machineclass='workstation' group by "
#                         "healthtime, businessunit, machinefunction order by healthtime asc;".format(i))
#             rows = cur.fetchall()
#             print "Query completed for {0}".format(i)
#             start_time = datetime.time(7,0,0)
#             end_time = datetime.time(18,0,0)
#             bu_info = {}
#             for row in rows:
#                 time_info = bu_info.get(row[0], {'teller_reported' : 0, 'loan_reported' : 0 , 'office_reported' : 0,
#                                                 'teller_avg_conn' : 0, 'loan_avg_conn' : 0, 'office_avg_conn' : 0})
#                 time_info['businessunit'] = row[1]
#                 time_info['lag'] = lag
#                 time_info[row[2] +'_reported'] = row[3]
#                 time_info[row[2] +'_avg_conn'] = row[4]
#                 bu_info[row[0]] = time_info
#
#             for key, time_info in sorted(bu_info.items(),key=operator.itemgetter(0)):
#                 writer.writerow((key, time_info['businessunit'], lag, time_info['teller_reported'], time_info['teller_avg_conn'],
#                                  time_info['loan_reported'], time_info['loan_avg_conn'], time_info['office_reported'], time_info['office_avg_conn']))
#
# extract_ws_num_conn_count()
#
# def extract_num_conn_loan_count():
#     with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/ws_loan_connection.csv','w') as fp:
#         writer = csv.writer(fp, delimiter=',')
#         for i in range(1,57):
#             if 0 < i <= 10:
#                 total_machines = 41000
#                 server_machines = 28000
#                 atm_machines = 2000
#                 ws_machines = 11000
#             elif 51 <= i < 56:
#                 total_machines = 50005
#                 server_machines = 50000
#                 atm_machines = 0
#                 ws_machines = 5
#                 continue
#             elif i == 56:
#                 total_machines = 15000
#                 server_machines = 0
#                 atm_machines = 0
#                 ws_machines = 15000
#             elif i == 0:
#                 total_machines = 15000
#                 server_machines = 250000
#                 atm_machines = 0
#                 ws_machines = 15000
#             else:
#                 total_machines = 5500
#                 server_machines = 2250
#                 atm_machines = 500
#                 ws_machines = 2750
#
#             cur.execute("select longitude from region_info_{0} where facility='headquarters' limit 1".format(i))
#             rows = cur.fetchall()
#             lag = longitude_to_timediff(rows[0][0])
#             print lag
#             cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='loan'".format(i))
#             rows = cur.fetchall()
#             teller_count = rows[0][0]
#             cur.execute("select healthtime, businessunit, count(ipaddr), avg(numconnections) "
#                         "from region_info_{0} where machineclass='workstation' and machinefunction='loan' group by healthtime, businessunit order by healthtime asc".format(i))
#             rows = cur.fetchall()
#             print "Query completed for {0}".format(i)
#             start_time = datetime.time(7,0,0)
#             end_time = datetime.time(18,0,0)
#             for row in rows:
#                 if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
#                     writer.writerow((row[0], row[1], row[2], row[3], teller_count, lag))
#                 else:
#                     writer.writerow((row[0], row[1], row[2], row[3], 0, lag))
#
# def extract_num_conn_office_count():
#     with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/ws_office_connection.csv','w') as fp:
#         writer = csv.writer(fp, delimiter=',')
#         for i in range(1,57):
#             if 0 < i <= 10:
#                 total_machines = 41000
#                 server_machines = 28000
#                 atm_machines = 2000
#                 ws_machines = 11000
#             elif 51 <= i < 56:
#                 total_machines = 50005
#                 server_machines = 50000
#                 atm_machines = 0
#                 ws_machines = 5
#                 continue
#             elif i == 56:
#                 total_machines = 15000
#                 server_machines = 0
#                 atm_machines = 0
#                 ws_machines = 15000
#             elif i == 0:
#                 total_machines = 15000
#                 server_machines = 250000
#                 atm_machines = 0
#                 ws_machines = 15000
#             else:
#                 total_machines = 5500
#                 server_machines = 2250
#                 atm_machines = 500
#                 ws_machines = 2750
#
#             cur.execute("select longitude from region_info_{0} where facility='headquarters' limit 1".format(i))
#             rows = cur.fetchall()
#             lag = longitude_to_timediff(rows[0][0])
#             print lag
#             cur.execute("select count(distinct(ipaddr)) from region_info_{0} where machinefunction='office'".format(i))
#             rows = cur.fetchall()
#             teller_count = rows[0][0]
#             cur.execute("select healthtime, businessunit, count(ipaddr), avg(numconnections) "
#                         "from region_info_{0} where machineclass='workstation' and machinefunction='office' group by healthtime, businessunit order by healthtime asc".format(i))
#             rows = cur.fetchall()
#             print "Query completed for {0}".format(i)
#             start_time = datetime.time(7,0,0)
#             end_time = datetime.time(18,0,0)
#             for row in rows:
#                 if (start_time <= (row[0]- datetime.timedelta(hours=lag)).time() <= end_time):
#                     writer.writerow((row[0], row[1], row[2], row[3], teller_count, lag))
#                 else:
#                     writer.writerow((row[0], row[1], row[2], row[3], 0, lag))
#
# # extract_num_conn_count()
# # extract_num_conn_loan_count()
# # extract_num_conn_office_count()
#
# def extract_datacenter():
#     with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/datacenter_report_status','w') as fp:
#         cur.execute("select healthtime,facility,count(ipaddr) from region_info_55 group by healthtime,facility order by healthtime asc")
#         rows = cur.fetchall()
#         writer = csv.writer(fp, delimiter=',')
#         for row in rows:
#             writer.writerow((row[0],row[1],row[2],50000))
#
# # extract_datacenter()
#
# def extract_workstation_activity_policy():
#     with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv/server_policy_activity_status.csv','w') as fp:
#         for i in range(1,57):
#             bu_info = {}
#             cur.execute("select healthtime, businessunit, policystatus, count(ipaddr) from region_info_{0} where machineclass='server' "
#                         "group by healthtime, policystatus, businessunit order by healthtime asc;".format(i))
#             rows = cur.fetchall()
#             for row in rows:
#                 time_info = bu_info.get(row[0], {})
#                 time_info['businessunit'] = row[1]
#                 time_info['p'+str(row[2])] = row[3]
#                 bu_info[row[0]] = time_info
#
#             cur.execute("select healthtime, businessunit, activityflag, count(ipaddr) from region_info_{0} where machineclass='server' "
#                         "group by healthtime, activityflag, businessunit order by healthtime asc;".format(i))
#             rows = cur.fetchall()
#             for row in rows:
#                 time_info = bu_info.get(row[0], {})
#                 time_info['businessunit'] = row[1]
#                 time_info['a'+str(row[2])] = row[3]
#                 bu_info[row[0]] = time_info
#
#             wr = csv.writer(fp,delimiter=',')
#             for key,timedetail in sorted(bu_info.items(),key=operator.itemgetter(0)):
#                 temp = timedetail['businessunit']
#                 if 51 <= i <= 55:
#                     temp = "datacenter-{0}".format(i-50)
#                 wr.writerow((key, temp , timedetail.get('a1',0), timedetail.get('a2',0), timedetail.get('a3',0),
#                              timedetail.get('a4',0), timedetail.get('a5',0),timedetail.get('p1',0), timedetail.get('p2',0),
#                              timedetail.get('p3',0), timedetail.get('p4',0), timedetail.get('p5',0)))

# extract_workstation_activity_policy()
def extract_server_num_conn_count():
    with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv/server_connection_new.csv','w') as fp:
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

            if 51 <= i <= 55:
                cur.execute("select longitude from region_info_{0} where facility='datacenter-{1}' limit 1".format(i, i-50))
            else:
                cur.execute("select longitude from region_info_{0} where facility='headquarters' limit 1".format(i))
            rows = cur.fetchall()
            lag = longitude_to_timediff(rows[0][0])
            cur.execute("select healthtime, businessunit, machinefunction,count(ipaddr), avg(numconnections) "
                        "from region_info_{0} where machineclass='server' group by "
                        "healthtime, businessunit, machinefunction order by healthtime asc;".format(i))
            rows = cur.fetchall()
            print "Query completed for {0}".format(i)
            start_time = datetime.time(7,0,0)
            end_time = datetime.time(18,0,0)
            bu_info = {}
            for row in rows:
                time_info = bu_info.get(row[0], {'file_server_reported' : 0, 'multiple_reported' : 0 , 'email_reported' : 0,  'compute_reported' : 0, 'web_reported' : 0,
                                                 'file_server_avg_conn' : 0, 'multiple_avg_conn' : 0, 'email_avg_conn' : 0, 'compute_avg_conn' : 0, 'web_avg_conn' : 0})
                time_info['businessunit'] = row[1]
                if 51 <= i <= 55:
                    time_info['businessunit'] = "datacenter-{0}".format(i-50)

                time_info['lag'] = lag
                time_info[row[2].replace(' ','_') +'_reported'] = row[3]
                time_info[row[2].replace(' ','_') +'_avg_conn'] = row[4]
                bu_info[row[0]] = time_info

            for key, time_info in sorted(bu_info.items(),key=operator.itemgetter(0)):
                writer.writerow((key, time_info['businessunit'], lag, time_info['file_server_reported'], time_info['file_server_avg_conn'],
                                 time_info['multiple_reported'], time_info['multiple_avg_conn'], time_info['email_reported'], time_info['email_avg_conn'],
                                 time_info['compute_reported'], time_info['compute_avg_conn'], time_info['web_reported'], time_info['web_avg_conn']))

extract_server_num_conn_count()