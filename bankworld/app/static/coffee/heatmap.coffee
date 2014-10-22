class HeatMap
  constructor: (w=1800, h=1200, parent="body", title = "", evDispatch) ->
    @margin = {top: 20, right: 60, bottom: 50, left: 60}
    @width = w - @margin.left - @margin.right
    @height = h - @margin.top - @margin.bottom
    @parent = parent
    @allbudata = null
    @title = title
    @evDispatch = evDispatch
    @curregion = "headquarters"
    [@legendWidth, @legendHeight] = [700,300]
    @legendPadding = 100
    @titleWidth = @width/2
    @padding = 200
    @barPadding = 0.1
    #mintime = '2012-02-02 08:30:00'
    #maxtime =  '2012-02-02 12:00:00'
    @mintime = '2012-02-02 08:30:00'
    @maxtime =  '2012-02-02 08:30:00'
    @tmin = 0.2
    @tmax = 1
    @choices = ['pol5','pol4','pol3', 'pol2', 'pol1','act1','act2','act3','act4','act5']


#    @colPick = ['sumnumconnections', 'pol5','pol4','pol3', 'pol2', 'pol1','act1','act2','act3','act4','act5']
#    @colPick = ['sumnumconnections', 'pol5']
#    @colPick = ['pol5','pol4','pol3', 'pol2', 'pol1']
#    @colPick = ['act1','act2','act3','act4','act5']
#    @colPick = ['act3', 'pol5']
#    @colPick = ['pol5', 'pol1']
#    @colPick = ['act5']
  

    #Q1 whats happening @ 1400 
    #@colPick = ['pol2', 'pol3', 'pol4', 'pol5']
    # region 25 begins losing machines during the day.
    #@colPick = ['erspreadmax', 'erspreadmin']
    # region 5 and 10 missing pol 1
    #@colPick = ['pol1', 'pol2']
#    @colPick = ['pol5']
    #erspreadmin has issues in region 25. policy 1 maintains its ratio relative to the other regions, so it implies that those which are going down are being completely wiped out with a power outage or other mishap, rather than there being some general unhealth in the region. Also seems to be unrelated to the virus instance since the other regions are unaffected by machines going down during hte day. Likewise, region 25 gets it first virus symptoms 2.5 hours after the episode of machines being down is over. Of course this is obscured by the fact that end of day occurs and machines are supposed to be down, so the anomaly disappears. 
    #@colPick = ['pol5', 'pol4', 'pol3','pol2']
  
    #headquarters has increased activity flags after business hours over the timeperiod
    #@colPick = ['act2', 'act3','act4','act5']
    #region 5 and 10 lack of pol stastus 1
    #@colPick = ['act1', 'pol1']
    #region 5 and 10 increased pol2
    #@colPick = ['pol2']
    #maintenance issue
    #@colPick = ['act2']
    #virus
    #@colPick = ['pol5']
    # machine online deviations from expected. headquarters, region 25. Headquarters has more machines online than expected the whole time!
    #colPick = ['erspreadmax']
    #colPick = ['erspreadmin']
    @colPick = ['erspreadmax', 'erspreadmin']

    @scales = {}
    @palette = {
      sumnumconnections: 'green'
      erspreadmax: 'red'
      erspreadmin: 'blue'
      showregion: 'red'
      showtime: 'red'
      pol1: '#a6cee3'
      pol2: 'orange'
      pol3: 'blue'
      pol4: '#33a02c'
      pol5: '#e31a1c'
      act1: '#b2df8a'
      act2: '#fb9a99'
      act3: '#1f78b4'
      act4: '#ff7f00'
      act5: '#6a3d9a'
    }

    #@regions = ["headquarters-1", "region-1", "region-2", "region-3", "region-4", "region-5", "region-6", "region-7", "region-8", "region-9", "region-10", "region-11", "region-12", "region-13", "region-14", "region-15", "region-16", "region-17", "region-18", "region-19", "region-20", "region-21", "region-22", "region-23", "region-24", "region-25", "region-26", "region-27", "region-28", "region-29", "region-30", "region-31", "region-32", "region-33", "region-34", "region-35", "region-36", "region-37", "region-38", "region-39", "region-40", "region-41", "region-42", "region-43", "region-44", "region-45", "region-46", "region-47", "region-48", "region-49", "region-50"]

    @regions = ["s-35", "s-34", "L-2", "s-36", "s-11", "L-1", "s-37", "s-49", "s-41", "s-50", "s-33", "s-32", "s-48", "s-39", "s-47", "s-46", "L-8", "s-12", "s-43", "s-13", "s-44", "s-31", "L-9", "s-45", "s-40", "L-3", "s-42", "L-10", "s-14", "s-30", "L-6", "s-15","s-29", "s-17", "s-16", "s-38", "s-20", "L-5", "s-18", "s-19", "HEAD", "L-7", "s-27", "s-28", "s-23", "L-4", "s-22", "s-21", "s-26", "s-24", "s-25"]

#        @regions = ["region-35", "region-34", "region-2", "region-36", "region-11", "region-1", "region-37", "region-49", "region-41", "region-50", "region-33", "region-32", "region-48", "region-39", "region-47", "region-46", "region-8", "region-12", "region-43", "region-13", "region-44", "region-31", "region-9", "region-45", "region-40", "region-3", "region-42", "region-10", "region-14", "region-30", "region-6", "region-15","region-29", "region-17", "region-16", "region-38", "region-20", "region-5", "region-18", "region-19", "headquarters-1", "region-7", "region-27", "region-28", "region-23", "region-4", "region-22", "region-21", "region-26", "region-24", "region-25"]

    
    @times = ['2012-02-01 23:00:00','2012-02-01 23:15:00','2012-02-01 23:30:00','2012-02-01 23:45:00','2012-02-02 00:00:00','2012-02-02 00:15:00','2012-02-02 00:30:00','2012-02-02 00:45:00','2012-02-02 01:00:00','2012-02-02 01:15:00','2012-02-02 01:30:00','2012-02-02 01:45:00','2012-02-02 02:00:00','2012-02-02 02:15:00','2012-02-02 02:30:00','2012-02-02 02:45:00','2012-02-02 03:00:00','2012-02-02 03:15:00','2012-02-02 03:30:00','2012-02-02 03:45:00','2012-02-02 04:00:00','2012-02-02 04:15:00','2012-02-02 04:30:00','2012-02-02 04:45:00','2012-02-02 05:00:00','2012-02-02 05:15:00','2012-02-02 05:30:00','2012-02-02 05:45:00','2012-02-02 06:00:00','2012-02-02 06:15:00','2012-02-02 06:30:00','2012-02-02 06:45:00','2012-02-02 07:00:00','2012-02-02 07:15:00','2012-02-02 07:30:00','2012-02-02 07:45:00','2012-02-02 08:00:00','2012-02-02 08:15:00','2012-02-02 08:30:00','2012-02-02 08:45:00','2012-02-02 09:00:00','2012-02-02 09:15:00','2012-02-02 09:30:00','2012-02-02 09:45:00','2012-02-02 10:00:00','2012-02-02 10:15:00','2012-02-02 10:30:00','2012-02-02 10:45:00','2012-02-02 11:00:00','2012-02-02 11:15:00','2012-02-02 11:30:00','2012-02-02 11:45:00','2012-02-02 12:00:00','2012-02-02 12:15:00','2012-02-02 12:30:00','2012-02-02 12:45:00','2012-02-02 13:00:00','2012-02-02 13:15:00','2012-02-02 13:30:00','2012-02-02 13:45:00','2012-02-02 14:00:00','2012-02-02 14:15:00','2012-02-02 14:30:00','2012-02-02 14:45:00','2012-02-02 15:00:00','2012-02-02 15:15:00','2012-02-02 15:30:00','2012-02-02 15:45:00','2012-02-02 16:00:00','2012-02-02 16:15:00','2012-02-02 16:30:00','2012-02-02 16:45:00','2012-02-02 17:00:00','2012-02-02 17:15:00','2012-02-02 17:30:00','2012-02-02 17:45:00','2012-02-02 18:00:00','2012-02-02 18:15:00','2012-02-02 18:30:00','2012-02-02 18:45:00','2012-02-02 19:00:00','2012-02-02 19:15:00','2012-02-02 19:30:00','2012-02-02 19:45:00','2012-02-02 20:00:00','2012-02-02 20:15:00','2012-02-02 20:30:00','2012-02-02 20:45:00','2012-02-02 21:00:00','2012-02-02 21:15:00','2012-02-02 21:30:00','2012-02-02 21:45:00','2012-02-02 22:00:00','2012-02-02 22:15:00','2012-02-02 22:30:00','2012-02-02 22:45:00','2012-02-02 23:00:00','2012-02-02 23:15:00','2012-02-02 23:30:00','2012-02-02 23:45:00','2012-02-03 00:00:00','2012-02-03 00:15:00','2012-02-03 00:30:00','2012-02-03 00:45:00','2012-02-03 01:00:00','2012-02-03 01:15:00','2012-02-03 01:30:00','2012-02-03 01:45:00','2012-02-03 02:00:00','2012-02-03 02:15:00','2012-02-03 02:30:00','2012-02-03 02:45:00','2012-02-03 03:00:00','2012-02-03 03:15:00','2012-02-03 03:30:00','2012-02-03 03:45:00','2012-02-03 04:00:00','2012-02-03 04:15:00','2012-02-03 04:30:00','2012-02-03 04:45:00','2012-02-03 05:00:00','2012-02-03 05:15:00','2012-02-03 05:30:00','2012-02-03 05:45:00','2012-02-03 06:00:00','2012-02-03 06:15:00','2012-02-03 06:30:00','2012-02-03 06:45:00','2012-02-03 07:00:00','2012-02-03 07:15:00','2012-02-03 07:30:00','2012-02-03 07:45:00','2012-02-03 08:00:00','2012-02-03 08:15:00','2012-02-03 08:30:00','2012-02-03 08:45:00','2012-02-03 09:00:00','2012-02-03 09:15:00','2012-02-03 09:30:00','2012-02-03 09:45:00','2012-02-03 10:00:00','2012-02-03 10:15:00','2012-02-03 10:30:00','2012-02-03 10:45:00','2012-02-03 11:00:00','2012-02-03 11:15:00','2012-02-03 11:30:00','2012-02-03 11:45:00','2012-02-03 12:00:00','2012-02-03 12:15:00','2012-02-03 12:30:00','2012-02-03 12:45:00','2012-02-03 13:00:00','2012-02-03 13:15:00','2012-02-03 13:30:00','2012-02-03 13:45:00','2012-02-03 14:00:00','2012-02-03 14:15:00','2012-02-03 14:30:00','2012-02-03 14:45:00','2012-02-03 15:00:00','2012-02-03 15:15:00','2012-02-03 15:30:00','2012-02-03 15:45:00','2012-02-03 16:00:00','2012-02-03 16:15:00','2012-02-03 16:30:00','2012-02-03 16:45:00','2012-02-03 17:00:00','2012-02-03 17:15:00','2012-02-03 17:30:00','2012-02-03 17:45:00','2012-02-03 18:00:00','2012-02-03 18:15:00','2012-02-03 18:30:00','2012-02-03 18:45:00','2012-02-03 19:00:00','2012-02-03 19:15:00','2012-02-03 19:30:00','2012-02-03 19:45:00','2012-02-03 20:00:00','2012-02-03 20:15:00','2012-02-03 20:30:00','2012-02-03 20:45:00','2012-02-03 21:00:00','2012-02-03 21:15:00','2012-02-03 21:30:00','2012-02-03 21:45:00','2012-02-03 22:00:00','2012-02-03 22:15:00','2012-02-03 22:30:00','2012-02-03 22:45:00','2012-02-03 23:00:00','2012-02-03 23:15:00','2012-02-03 23:30:00','2012-02-03 23:45:00','2012-02-04 00:00:00','2012-02-04 00:15:00','2012-02-04 00:30:00','2012-02-04 00:45:00','2012-02-04 01:00:00','2012-02-04 01:15:00','2012-02-04 01:30:00','2012-02-04 01:45:00','2012-02-04 02:00:00','2012-02-04 02:15:00','2012-02-04 02:30:00','2012-02-04 02:45:00','2012-02-04 03:00:00','2012-02-04 03:15:00','2012-02-04 03:30:00','2012-02-04 03:45:00','2012-02-04 04:00:00','2012-02-04 04:15:00','2012-02-04 04:30:00','2012-02-04 04:45:00','2012-02-04 05:00:00','2012-02-04 05:15:00','2012-02-04 05:30:00','2012-02-04 05:45:00','2012-02-04 06:00:00','2012-02-04 06:15:00','2012-02-04 06:30:00','2012-02-04 06:45:00','2012-02-04 07:00:00','2012-02-04 07:15:00','2012-02-04 07:30:00','2012-02-04 07:45:00','2012-02-04 08:00:00']

    @reverseTimes= ['2012-02-04 08:00:00','2012-02-04 07:45:00','2012-02-04 07:30:00','2012-02-04 07:15:00','2012-02-04 07:00:00','2012-02-04 06:45:00','2012-02-04 06:30:00','2012-02-04 06:15:00','2012-02-04 06:00:00','2012-02-04 05:45:00','2012-02-04 05:30:00','2012-02-04 05:15:00','2012-02-04 05:00:00','2012-02-04 04:45:00','2012-02-04 04:30:00','2012-02-04 04:15:00','2012-02-04 04:00:00','2012-02-04 03:45:00','2012-02-04 03:30:00','2012-02-04 03:15:00','2012-02-04 03:00:00','2012-02-04 02:45:00','2012-02-04 02:30:00','2012-02-04 02:15:00','2012-02-04 02:00:00','2012-02-04 01:45:00','2012-02-04 01:30:00','2012-02-04 01:15:00','2012-02-04 01:00:00','2012-02-04 00:45:00','2012-02-04 00:30:00','2012-02-04 00:15:00','2012-02-04 00:00:00','2012-02-03 23:45:00','2012-02-03 23:30:00','2012-02-03 23:15:00','2012-02-03 23:00:00','2012-02-03 22:45:00','2012-02-03 22:30:00','2012-02-03 22:15:00','2012-02-03 22:00:00','2012-02-03 21:45:00','2012-02-03 21:30:00','2012-02-03 21:15:00','2012-02-03 21:00:00','2012-02-03 20:45:00','2012-02-03 20:30:00','2012-02-03 20:15:00','2012-02-03 20:00:00','2012-02-03 19:45:00','2012-02-03 19:30:00','2012-02-03 19:15:00','2012-02-03 19:00:00','2012-02-03 18:45:00','2012-02-03 18:30:00','2012-02-03 18:15:00','2012-02-03 18:00:00','2012-02-03 17:45:00','2012-02-03 17:30:00','2012-02-03 17:15:00','2012-02-03 17:00:00','2012-02-03 16:45:00','2012-02-03 16:30:00','2012-02-03 16:15:00','2012-02-03 16:00:00','2012-02-03 15:45:00','2012-02-03 15:30:00','2012-02-03 15:15:00','2012-02-03 15:00:00','2012-02-03 14:45:00','2012-02-03 14:30:00','2012-02-03 14:15:00','2012-02-03 14:00:00','2012-02-03 13:45:00','2012-02-03 13:30:00','2012-02-03 13:15:00','2012-02-03 13:00:00','2012-02-03 12:45:00','2012-02-03 12:30:00','2012-02-03 12:15:00','2012-02-03 12:00:00','2012-02-03 11:45:00','2012-02-03 11:30:00','2012-02-03 11:15:00','2012-02-03 11:00:00','2012-02-03 10:45:00','2012-02-03 10:30:00','2012-02-03 10:15:00','2012-02-03 10:00:00','2012-02-03 09:45:00','2012-02-03 09:30:00','2012-02-03 09:15:00','2012-02-03 09:00:00','2012-02-03 08:45:00','2012-02-03 08:30:00','2012-02-03 08:15:00','2012-02-03 08:00:00','2012-02-03 07:45:00','2012-02-03 07:30:00','2012-02-03 07:15:00','2012-02-03 07:00:00','2012-02-03 06:45:00','2012-02-03 06:30:00','2012-02-03 06:15:00','2012-02-03 06:00:00','2012-02-03 05:45:00','2012-02-03 05:30:00','2012-02-03 05:15:00','2012-02-03 05:00:00','2012-02-03 04:45:00','2012-02-03 04:30:00','2012-02-03 04:15:00','2012-02-03 04:00:00','2012-02-03 03:45:00','2012-02-03 03:30:00','2012-02-03 03:15:00','2012-02-03 03:00:00','2012-02-03 02:45:00','2012-02-03 02:30:00','2012-02-03 02:15:00','2012-02-03 02:00:00','2012-02-03 01:45:00','2012-02-03 01:30:00','2012-02-03 01:15:00','2012-02-03 01:00:00','2012-02-03 00:45:00','2012-02-03 00:30:00','2012-02-03 00:15:00','2012-02-03 00:00:00','2012-02-02 23:45:00','2012-02-02 23:30:00','2012-02-02 23:15:00','2012-02-02 23:00:00','2012-02-02 22:45:00','2012-02-02 22:30:00','2012-02-02 22:15:00','2012-02-02 22:00:00','2012-02-02 21:45:00','2012-02-02 21:30:00','2012-02-02 21:15:00','2012-02-02 21:00:00','2012-02-02 20:45:00','2012-02-02 20:30:00','2012-02-02 20:15:00','2012-02-02 20:00:00','2012-02-02 19:45:00','2012-02-02 19:30:00','2012-02-02 19:15:00','2012-02-02 19:00:00','2012-02-02 18:45:00','2012-02-02 18:30:00','2012-02-02 18:15:00','2012-02-02 18:00:00','2012-02-02 17:45:00','2012-02-02 17:30:00','2012-02-02 17:15:00','2012-02-02 17:00:00','2012-02-02 16:45:00','2012-02-02 16:30:00','2012-02-02 16:15:00','2012-02-02 16:00:00','2012-02-02 15:45:00','2012-02-02 15:30:00','2012-02-02 15:15:00','2012-02-02 15:00:00','2012-02-02 14:45:00','2012-02-02 14:30:00','2012-02-02 14:15:00','2012-02-02 14:00:00','2012-02-02 13:45:00','2012-02-02 13:30:00','2012-02-02 13:15:00','2012-02-02 13:00:00','2012-02-02 12:45:00','2012-02-02 12:30:00','2012-02-02 12:15:00','2012-02-02 12:00:00','2012-02-02 11:45:00','2012-02-02 11:30:00','2012-02-02 11:15:00','2012-02-02 11:00:00','2012-02-02 10:45:00','2012-02-02 10:30:00','2012-02-02 10:15:00','2012-02-02 10:00:00','2012-02-02 09:45:00','2012-02-02 09:30:00','2012-02-02 09:15:00','2012-02-02 09:00:00','2012-02-02 08:45:00','2012-02-02 08:30:00','2012-02-02 08:15:00','2012-02-02 08:00:00','2012-02-02 07:45:00','2012-02-02 07:30:00','2012-02-02 07:15:00','2012-02-02 07:00:00','2012-02-02 06:45:00','2012-02-02 06:30:00','2012-02-02 06:15:00','2012-02-02 06:00:00','2012-02-02 05:45:00','2012-02-02 05:30:00','2012-02-02 05:15:00','2012-02-02 05:00:00','2012-02-02 04:45:00','2012-02-02 04:30:00','2012-02-02 04:15:00','2012-02-02 04:00:00','2012-02-02 03:45:00','2012-02-02 03:30:00','2012-02-02 03:15:00','2012-02-02 03:00:00','2012-02-02 02:45:00','2012-02-02 02:30:00','2012-02-02 02:15:00','2012-02-02 02:00:00','2012-02-02 01:45:00','2012-02-02 01:30:00','2012-02-02 01:15:00','2012-02-02 01:00:00','2012-02-02 00:45:00','2012-02-02 00:30:00','2012-02-02 00:15:00','2012-02-02 00:00:00','2012-02-01 23:45:00','2012-02-01 23:30:00','2012-02-01 23:15:00','2012-02-01 23:00:00']

    @timelabels = ['2012-02-01 23:00:00','2012-02-02 00:00:00','2012-02-02 01:00:00','2012-02-02 02:00:00','2012-02-02 03:00:00','2012-02-02 04:00:00','2012-02-02 05:00:00','2012-02-02 06:00:00','2012-02-02 07:00:00','2012-02-02 08:00:00','2012-02-02 09:00:00','2012-02-02 10:00:00','2012-02-02 11:00:00','2012-02-02 12:00:00','2012-02-02 13:00:00','2012-02-02 14:00:00','2012-02-02 15:00:00','2012-02-02 16:00:00','2012-02-02 17:00:00','2012-02-02 18:00:00','2012-02-02 19:00:00','2012-02-02 20:00:00','2012-02-02 21:00:00','2012-02-02 22:00:00','2012-02-02 23:00:00','2012-02-03 00:00:00','2012-02-03 01:00:00','2012-02-03 02:00:00','2012-02-03 03:00:00','2012-02-03 04:00:00','2012-02-03 05:00:00','2012-02-03 06:00:00','2012-02-03 07:00:00','2012-02-03 08:00:00','2012-02-03 09:00:00','2012-02-03 10:00:00','2012-02-03 11:00:00','2012-02-03 12:00:00','2012-02-03 13:00:00','2012-02-03 14:00:00','2012-02-03 15:00:00','2012-02-03 16:00:00','2012-02-03 17:00:00','2012-02-03 18:00:00','2012-02-03 19:00:00','2012-02-03 20:00:00','2012-02-03 21:00:00','2012-02-03 22:00:00','2012-02-03 23:00:00','2012-02-04 00:00:00','2012-02-04 01:00:00','2012-02-04 02:00:00','2012-02-04 03:00:00','2012-02-04 04:00:00','2012-02-04 05:00:00','2012-02-04 06:00:00','2012-02-04 07:00:00','2012-02-04 08:00:00']

    @reverseTimeLabels = ['2012-02-04 08:00:00','2012-02-04 07:00:00','2012-02-04 06:00:00','2012-02-04 05:00:00','2012-02-04 04:00:00','2012-02-04 03:00:00','2012-02-04 02:00:00','2012-02-04 01:00:00','2012-02-04 00:00:00','2012-02-03 23:00:00','2012-02-03 22:00:00','2012-02-03 21:00:00','2012-02-03 20:00:00','2012-02-03 19:00:00','2012-02-03 18:00:00','2012-02-03 17:00:00','2012-02-03 16:00:00','2012-02-03 15:00:00','2012-02-03 14:00:00','2012-02-03 13:00:00','2012-02-03 12:00:00','2012-02-03 11:00:00','2012-02-03 10:00:00','2012-02-03 09:00:00','2012-02-03 08:00:00','2012-02-03 07:00:00','2012-02-03 06:00:00','2012-02-03 05:00:00','2012-02-03 04:00:00','2012-02-03 03:00:00','2012-02-03 02:00:00','2012-02-03 01:00:00','2012-02-03 00:00:00','2012-02-02 23:00:00','2012-02-02 22:00:00','2012-02-02 21:00:00','2012-02-02 20:00:00','2012-02-02 19:00:00','2012-02-02 18:00:00','2012-02-02 17:00:00','2012-02-02 16:00:00','2012-02-02 15:00:00','2012-02-02 14:00:00','2012-02-02 13:00:00','2012-02-02 12:00:00','2012-02-02 11:00:00','2012-02-02 10:00:00','2012-02-02 09:00:00','2012-02-02 08:00:00','2012-02-02 07:00:00','2012-02-02 06:00:00','2012-02-02 05:00:00','2012-02-02 04:00:00','2012-02-02 03:00:00','2012-02-02 02:00:00','2012-02-02 01:00:00','2012-02-02 00:00:00','2012-02-01 23:00:00',]


    #maxradius = height/times.length
    @rectWidth = (@width-2*@padding)/@regions.length
    @innerRectWidth = (@rectWidth)/@colPick.length
    #rectHeight = (height-2*padding)/times.length
    @alldata = []
    @alllocdata = []

  load: (d,c, colselections=['act1', 'act2']) ->
    @alldata = d
    @alllocdata = c
    @selections = colselections
    dateFormat = d3.time.format("%Y-%m-%d %H:%M:%S")
    @alldata.forEach( (dat) =>
      dat.timestamp = dateFormat.parse(dat.time)
    )

  #main drawing code
  draw: (start_time=null, end_time=null, timecount=192) ->
    dataset = @alldata
    dataset2 = @alllocdata

    d3.select(@parent).select("#heat_pol_button").remove()
    d3.select(@parent).select("#heat_data_button").remove()

    color_scale = d3.scale.category10().domain(["pol1", "pol2", "pol3", "pol4","pol5", "act1", "act2", "act3", "act4","act5"])
    button = d3.select(@parent).append("div").attr("id", "heat_pol_button").selectAll("button").data(["pol1", "pol2", "pol3", "pol4","pol5", "act1", "act2", "act3", "act4","act5"])
    .enter().append('button').attr("type", "button").attr(
      class: "btn btn-xs"
      id: (d) -> d
    ).style('background-color', (d) -> color_scale(d)).text((d) -> d)

    local_global_button = d3.select(@parent).append("div").attr("id", "heat_data_button").selectAll('button').data(["local", "global"]).enter().append('button').attr("type", "button")
    .attr(
      class: "btn btn-xs"
      id: "local"
    ).text((d) -> d)

    local_global_button.on("click", (elem) =>
      if elem == "local"
        d3.csv('/static/csv/everything_5_loc.csv', (d) =>
          d3.csv('/static/csv/heat_latlong.csv', (c)=>
            @load d,c
            @draw() ))
      else
        d3.csv('/static/csv/everything_5_glob.csv', (d)=>
          d3.csv('/static/csv/heat_latlong.csv', (c)=>
            @load d,c
            @draw() ))
    )

    # TODO: Toggle the active and inactive state for the button
    button.on("click", (d) =>
      if d not in @colPick
        @colPick.push(d)
      else
        @colPick = @colPick.filter( (val) => d != val )
      @rectWidth = (@width-2*@padding)/@regions.length
      @innerRectWidth = (@rectWidth)/@colPick.length
      @draw())

    dataset = dataset.filter( (d) =>
      if start_time != null and end_time != null
        start_time <= d.timestamp <= end_time
      else
        true
    )

    rectHeight = (@height-2*@padding)/(timecount+1)

    #  heatRectScale = d3.scale.ordinal()
    #    .domain(colPick)
    #    .rangeBands([0,rectWidth-rectWidth/colPick.length])

    xScaleHeat = d3.scale.ordinal()
  #    .domain([0..regions.length])
      .domain(@regions)
      .rangeBands([@padding, @width-@padding])

    yScaleHeat = d3.time.scale().range([@padding,@height-@padding-rectHeight])
    yScaleHeat.domain(d3.extent(dataset, (d) -> d.timestamp))

    for i in @colPick
      @scales[i] = d3.scale.linear()
        .domain([0,d3.max(dataset, (d)->
          +d[i]/d.sizepol)])
        .range([@tmin,@tmax])

    yAxis = d3.svg.axis()
      .scale(yScaleHeat)
      .orient('left')
      .ticks(10)
#      .tickValues(@timelabels)

    xAxis = d3.svg.axis()
      .scale(xScaleHeat)
      .ticks(50)

    d3.select(@parent).selectAll('svg').remove()
    svgHeat = d3.select(@parent)
      .append('svg')
      .attr(
        width: @width
        height: @height
      )

#    showCurrentTime =
#    if @maxtime[14..15] is '00'
#    else
#      svgHeat.append('text')
#        .text(@maxtime)
#        .attr(
#          x: 0
#          y: @height - @padding - rectHeight/2
#          stroke: 'red'
#          fill: 'red'
#        )

    showtime = (d)=>
      svgHeat.append('text')
        .text(d.toTimeString()[0..8])
        .attr(
          id: 'showtime'
          x: 0
          y: yScaleHeat d
          stroke: @palette['showtime']
          fill: 'black'
          "font-size": 25
          "transform": "translate(#{@padding/3.5},0)"
        )

    showregion = (region)=>
      svgHeat.append('text')
        .text(region)
        .attr(
          id: 'showregion'
          x: xScaleHeat region
          y: @padding/1.2
          stroke: @palette['showregion']
          "stroke-width": 1
          fill: 'black'
          'font-size': 30
  #        "transform": "rotate(20)"
        )

  # iterate over all chosen columns and dynamically adjust scales and sizes
    for i in [0..@colPick.length]
      svgHeat.selectAll("rect#{i}")
        .data(dataset)
        .enter()
        .append('rect')
        .attr(
          x: (d)->
            xScaleHeat d['region']
          y: (d)->
            yScaleHeat d['timestamp']
          width: @innerRectWidth-1
          height: rectHeight - 2*@barPadding
          transform: (d)=>
              "translate(#{(@innerRectWidth-1)*i}, 0)"
          fill: (d)=>
            @palette[@colPick[i]]
          "stroke-width":0
        )
        .style("opacity": (d)=>
#          if @colPick[i] is 'erspread'
#            if +d[@colPick[i]] > 0
#              @scales['erspreadmax'] (+d[@colPick[i]])/d.sizepol
#            else
#              @scales['erspreadmin'] (+d[@colPick[i]])/d.sizepol
#          else
            if +d[@colPick[i]]
              @scales[@colPick[i]] +d[@colPick[i]]/d.sizepol
            else
              0
        )
        .on(
          mouseover: (d)->
            showtime d.timestamp
            showregion d.region, d.timestamp
          mouseout: (d)->
            svgHeat.select('#showregion').remove()
            svgHeat.select('#showtime').remove()
          click: (d) =>
            @evDispatch.selectRegion(d.regionold)
        )

    xLabel = svgHeat.append('g')
      .call(xAxis)
      .attr(
        class: "axis"
        "transform": "translate(0, #{@height-@padding})")
      .selectAll('text')
#        .style("text-anchor", "right")
        .attr(
          "transform": "translate(#{-@rectWidth},40) rotate(-90)"
          "font-size": 20
  #        "transform","translate(#{-innerRectWidth/2}, 0)"
        )

    yLabel = svgHeat.append('g')
        .call(yAxis)
        .attr(
          class: 'axis'
          "stroke-width": 1
          stroke: 'black'
          "transform": "translate(#{@padding},0)"
        ).style('opacity': 0.8)


    xGrid = svgHeat.selectAll('.xgrid')
      .data(@regions)
      .enter()
      .append('line')
      .attr(
        x1: (d)->
          xScaleHeat d
        x2: (d)->
          xScaleHeat d
        y1: @padding
        y2: @height-@padding
        stroke: 'black'
        )
        .style(
          opacity: 0.5)

#    yGrid = svgHeat.selectAll('line')
#      .data(dataset2)
#      .enter()
#      .append('line')
#      .attr(
#        x1: @padding
#        x2: @width-@padding
#        y1: (d, i)=>
#          @padding + 4*i*rectHeight
#        y2: (d, i)=>
#          @padding + 4*i*rectHeight
#        "stroke-width": 1
#        stroke: 'black'
#      )
#      .style('opacity': 0.8)
  
    title = svgHeat.selectAll('.title')
      .data(@colPick)
      .enter()
      .append('text')
      .text((d,i)=>
        if i is 0
          @colPick[i]
        else
          ' & ' + @colPick[i])
      .attr(
        x: (d,i)=>
          i*@titleWidth/@colPick.length
        y: @padding/2
        "transform": "translate(#{@titleWidth/@colPick.length}, 0)"
        stroke: (d,i)=>
          @palette[d]
        fill: (d,i)=>
          @palette[d]        
        "font-size": 30
        )

#    svgLegend = d3.select(@parent)
#      .append('svg')
#      .attr(
#        width: @legendWidth
#        height: @legendHeight
#      )
#
#    svgLegend.selectAll('rect')
#      .data(@colPick)
#      .enter()
#      .append('rect')
#      .attr(
#        x: (d,i)=>
#          @legendPadding + i*(@legendWidth-2*@legendPadding)/@colPick.length
#        y: @legendPadding
#        width: (@legendWidth-2*@legendPadding)/@colPick.length
#        height: @legendHeight/3
#        fill: (d)=>
#          @palette[d]
#        )
#
#    svgLegend.selectAll('text')
#      .data(@colPick)
#      .enter()
#      .append('text')
#      .text((d, i)=>
#        @colPick[i]
#      )
#      .attr(
#        x: (d,i)=>
#          @legendPadding + i*(@legendWidth-2*@legendPadding)/@colPick.length + 0.5*(@legendWidth-2*@legendPadding)/@colPick.length
#        y: @legendPadding/1.1
#        stroke: "black"
#        "stroke-width": 1
#        "text-anchor": "middle"
#        "font-size": 20
#      )
#
#
#    svgLegend.append('text')
#      .text('REGION #')
#      .attr(
#        x: (@legendWidth-2*@legendPadding)/2
#        y: 250
#        fill: "black"
#        'font-size': 30)
#
#    svgLegend.append('text')
#      .text('TIME t')
#      .attr(
#        x: 0
#        y: @legendHeight/2
#        fill: "black"
#        'font-size': 30)
  
  


