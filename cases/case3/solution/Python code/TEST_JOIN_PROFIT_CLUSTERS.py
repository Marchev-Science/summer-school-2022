import pandas as pd
import numpy as np
from pathlib import Path
from datetime import time
from dateutil import parser
from datetime import timedelta
import os, sys

abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)

# Load Client Data
data= pd.read_csv(f"{dname}//data_with_Profit.csv")
#data['AppDate'] = pd.to_datetime(data['AppDate'])
date_str = []
for el in data["AppDate"]:
    date_str.append(el[0:8])
data["AppDate"] = date_str
# Load data with clusters
cluster = pd.read_csv(f"{dname}//3th_cluster.csv")
# Loading sms and Auto data .csv
sms_df = pd.read_csv(f"{dname}//manual_offer.csv")
date_str1 = []
for el in sms_df["date"]:
    date_str1.append(el[0:8])
sms_df["date"] = date_str1
auto_df = pd.read_csv(f"{dname}//auto_generated.csv")
date_str2 = []
for el in auto_df["date"]:
    date_str2.append(el[0:8])
auto_df["date"] = date_str2


# Making the data vars
#sms_df['date'] = pd.to_datetime(sms_df['date'])
#auto_df['date'] = pd.to_datetime(auto_df['date'])

auto_df = auto_df[~(auto_df['date'] < '2021-01-01' )]
auto_df = auto_df[~(auto_df['date'] > '2021-09-09' )]
sms_df = sms_df[~(sms_df['date'] < '2021-01-01' )]
sms_df = sms_df[~(sms_df['date'] > '2021-09-09' )]

sms_df.drop(["chanel", "type"], axis = 1, inplace = True)
sms_df.drop(["amount"], axis = 1, inplace = True)


cluster.drop(["Income3M", "Var_CCR_03", "Var_CCR_06", "Var_CCR_08",
              "Var_CCR_10", "CCR_UsedAmountTot"], axis = 1, inplace = True)

data = pd.merge(cluster, 
                      data, 
                      on ='Client_ID', 
                      how ='left')

sms_list = []
auto_list = []


def time_making():
    for i in range(0, len(data)):
        row_id = data.iloc[i]["Client_ID"]
        df1 = data.query("Client_ID == @row_id")
        df2 = sms_df.query("user_id == @row_id")
        df3 = auto_df.query("user_id == @row_id")
        for x in range(0,(df1.shape[0]-1)):
            if df2.shape[0] == 0 and df3.shape[0] == 0:
               sms_list.append(0)
               auto_list.append(0)
            elif df2.shape[0] > 0 and df3.shape[0] == 0:
                auto_list.append(0)
                for el in df2["date"]:
                    df2_temp = df2.query(f"{data.iloc[i]['AppDate']} <= {el} ")
                    sms_list.append(df2_temp.shape[1])
            elif df3.shape[0] > 0 and df2.shape[0] == 0:
                sms_list.append(0)
                df3_temp = df3.query(f"{data.iloc[i]['AppDate']} <= {df3['date']} ")
                auto_list.append(df3_temp.shape[1])
            elif df2.shape[0] > 0 and df3.shape > 0:
                df2_temp = df2.query(f"{data.iloc[i]['AppDate']} <= {df2['date']} ")
                sms_list.append(df2_temp.shape[1])
                df3_temp = df3.query(f"{data.iloc[i]['AppDate']} <= {df3['date']} ")
                auto_list.append(df3_temp.shape[1])
    dict_add_to_data = {"sms Count" : sms_list, "Auto Count" : auto_list}
    return dict_add_to_data
dict_add_to_data = time_making()
