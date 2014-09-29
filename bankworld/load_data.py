from pymongo import MongoClient
from datetime import datetime
client = MongoClient('localhost', 27017)

db = client.bankworld

# with open('/Users/ramz/Projects/uni/datavis/project/Mini1/metaDB-csv-3-7/meta-3-7.csv') as fp:
#     for line in fp:
#         ipaddr, machineclass, machinefunction, businessunit, facility, latitude, longitude = line.strip().split(',')
#         machine_info = {'ipaddr' : ipaddr, 'machineclass' : machineclass, 'machinefunction' : machinefunction, 'businessunit' : businessunit,
#                         'facility' : facility, 'latitude' : latitude, 'longitude' : longitude.strip(), 'status': []}
#         db.minfo.insert(machine_info)
#
# print "completed step 1"
with open('/Users/ramz/Projects/uni/datavis/project/Mini1/metaDB-csv-3-7/metaStatus-3-7.csv') as fp:
    c = -1
    for line in fp:
        c = c+1
        if c ==0:
            continue
        tkey, ipaddr, healthtime, numconnections, policystatus, activityflag = line.strip().split(',')
        healthtime = datetime.strptime(healthtime, "%Y-%m-%d %H:%M:%S")
        info = {"date" : healthtime, 'numconnections' : numconnections, 'policystatus' : policystatus, 'activityflag' : activityflag}
        db.minfo.update({'ipaddr' : ipaddr}, {"$push" : {'status' : info}})

        if (c % 1000000 == 0):
            print "{0} million entry completed".format(c/1000000)