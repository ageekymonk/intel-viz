import csv
import datetime
import operator


bu_details = {}

for i in range(1,6):
    with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv/activity{0}_status.csv'.format(i),'r') as fp:
        rd = csv.reader(fp,delimiter=',')
        for row in rd:
            bu = bu_details.get(row[1],{})
            timedetail = bu.get(row[0],{})
            timedetail['a'+row[3]] = row[2]
            bu[row[0]] = timedetail
            bu_details[row[1]] = bu

for i in range(1,6):
    with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv//policy{0}_status.csv'.format(i),'r') as fp:
        rd = csv.reader(fp,delimiter=',')
        rd.next()
        for row in rd:
            bu = bu_details.get(row[1],{})
            timedetail = bu.get(row[0],{})
            timedetail['p'+row[2]] = row[3]
            bu[row[0]] = timedetail
            bu_details[row[1]] = bu

with open('/Users/ramz/Projects/uni/datavis/visproj/bankworld/app/static/csv/overall_policy_activity_status_new.csv','w') as fp:
    wr = csv.writer(fp,delimiter=',')
    for bu,details in bu_details.iteritems():

        for time, timedetail in sorted(details.items(),key=operator.itemgetter(0)):
            wr.writerow((bu,time,timedetail.get('a1',0), timedetail.get('a2',0), timedetail.get('a3',0),
                         timedetail.get('a4',0), timedetail.get('a5',0),timedetail.get('p1',0), timedetail.get('p2',0),
                         timedetail.get('p3',0), timedetail.get('p4',0), timedetail.get('p5',0)))