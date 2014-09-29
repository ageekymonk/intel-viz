from flask import render_template, jsonify, request, Response
from . import app
from app import bwinfo, conn, cur
import csv
import cStringIO
import datetime

@app.route('/')
def index():
    return render_template('base.html')

def get_policy_csv(regionid, policystatusid, branchid='ignore'):

    if branchid == 'ignore':
        cur.execute("select healthtime, machineclass, machinefunction, count(ipaddr) from region_info_{0} "
                "where policystatus={1} group by healthtime,machineclass,machinefunction  order by healthtime asc".format(regionid,policystatusid))
    else:
        cur.execute("select healthtime, machineclass, machinefunction, count(ipaddr) from region_info_{0} "
                    "where policystatus={1} and facility='{2}' group by healthtime,machineclass,machinefunction  order by healthtime asc".format(regionid,policystatusid, branchid))
    rows = cur.fetchall()
    output = cStringIO.StringIO()
    writer = csv.writer(output, delimiter=',')
    writer.writerow(("healthtime","machineclass","machinefunction","ipaddrcount"))
    for row in rows:
        writer.writerow(row)
    return output.getvalue()

def get_activity_csv(regionid, activityflagid,branchid='ignore'):

    if branchid == 'ignore':
        cur.execute("select healthtime, machineclass, machinefunction, count(ipaddr) from region_info_{0} "
                "where activityflag={1} group by healthtime,machineclass,machinefunction  order by healthtime asc".format(regionid,activityflagid))
    else:
        cur.execute("select healthtime, machineclass, machinefunction, count(ipaddr) from region_info_{0} "
                    "where activityflag={1} and facility='{2}' group by healthtime,machineclass,machinefunction  order by healthtime asc".format(regionid,activityflagid, branchid))

    rows = cur.fetchall()
    print rows
    output = cStringIO.StringIO()
    writer = csv.writer(output, delimiter=',')
    writer.writerow(("healthtime","machineclass","machinefunction","ipaddrcount"))
    for row in rows:
        writer.writerow(row)
        print row
    return output.getvalue()

@app.route('/regionpolicy')
def get_region_policy_info():
    regionid = request.args.get('region')
    print regionid
    policystatusid = request.args.get('policystatus')
    result = []
    branchid = request.args.get('branch')
    return Response(get_policy_csv(regionid, policystatusid,branchid), mimetype='text/csv')
    # cur.execute("select healthtime, count(ipaddr) from region_info_{0} where policystatus={1} group by "
    #             "healthtime order by healthtime asc".format(regionid, policystatusid))
    # rows = cur.fetchall()
    # for i in range(192):
    #     result.append({'name': 'timestamp',
    #                 'value' : datetime.datetime.strptime("2012-02-02 08:15:00", "%Y-%m-%d %H:%M:%S") + datetime.timedelta(minutes=15*i),
    #                 'cols' : []} )
    # prevvalue = 0
    # start = 0
    # for idx,row in enumerate(rows):
    #     for i in range(idx, 192):
    #
    #         if result[i]['value'] == row[0]:
    #             result[i]['cols'].append({'name' : policystatusid, 'value' : row[1]})
    #             prevvalue = row[1]
    #             break;
    #         else:
    #             if len(result[i]['cols']) == 0:
    #                 result[i]['cols'].append({'name' : policystatusid, 'value' : prevvalue})
    #             continue
    # return jsonify(result=result)

@app.route('/regionactivity')
def get_region_activity_info():
    regionid = request.args.get('region')
    print regionid
    activityflagid = request.args.get('activityflag')
    result = []
    branchid = request.args.get('branch')
    return Response(get_activity_csv(regionid, activityflagid,branchid), mimetype='text/csv')

@app.route('/test')
def get_at_2():
    # for policy in range(3,6):
    # with open('/Users/ramz/Projects/uni/datavis/Assignments/bankworld/app/static/csv/at2pm_numipaddr.csv','w') as fp:
    #     for i in range(51):
    #         print i
    #         cur.execute("select businessunit, facility, count(distinct(ipaddr)) from region_info_{0} where healthtime='2012-02-02 14:00:00' group by businessunit, facility ".format(i))
    #         rows = cur.fetchall()
    #         writer = csv.writer(fp, delimiter=',')
    #         for row in rows:
    #             print row
    #             writer.writerow(row)
    return "Hello world"