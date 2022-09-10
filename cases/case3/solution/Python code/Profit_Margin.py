import pandas as pd
from pathlib import Path
import os, sys

abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)

data= pd.read_csv(f"{dname}//clients_edited_with_month_int.csv")

data["CCR_UsedAmountTot"] = data["CCR_UsedAmountTot"].clip(upper=40000)

data["WorkingDays3M"] = data["WorkingDays3M"].clip(upper=90)

data["WorkingPlacesCount3M"] = data["WorkingPlacesCount3M"].clip(upper=3)


# Making seasons as dummies
data = pd.get_dummies(data, columns = ["Season"])
# Making credit type facturized

data["CreditType"] = data["CreditType"].astype('category')

for ind in data.index:
    if data['CreditType'][ind] == "installment":
        data.at[ind,'Period'] = data['Period'][ind] * 30


data["Sum"] = data["OvdSequence1M"] + data["OvdSequence2M"] + data["OvdSequence3M"] + data["OvdSequence4M"] + data["OvdSequence5M"] + data["OvdSequence6M"] + data["OvdSequence7M"] + data["OvdSequence8M"] + data["OvdSequence9M"] + data["OvdSequence10M"] + data["OvdSequence11M"] + data["OvdSequence12M"]

data.loc[(data['WorkingDays'].isnull()==True),'WorkingDays']=data['WorkingDays'].mean()
data.loc[(data['Income'].isnull()==True),'Income']=data['Income'].mean()


df1 = data[["OvdSequence9M","OvdSequence10M", "OvdSequence11M", "OvdSequence12M"]]
data.drop(columns = ["OvdSequence10M", "OvdSequence11M", "OvdSequence12M", "OvdSequence9M"], inplace = True)

df1_list = df1['OvdSequence9M'].tolist()
data.insert(21, 'OvdSequence9M', df1_list)
df1_list = df1['OvdSequence10M'].tolist()
data.insert(22, 'OvdSequence10M', df1_list)
df1_list = df1['OvdSequence11M'].tolist()
data.insert(23, 'OvdSequence11M', df1_list)
df1_list = df1['OvdSequence10M'].tolist()
df1_list = df1['OvdSequence12M'].tolist()
data.insert(24, 'OvdSequence12M', df1_list)


#df.loc[12:26, ["OvdSequence1M", "OvdSequence2M", "OvdSequence3M", "OvdSequence4M", "OvdSequence5M" ,"OvdSequence6M" ,"OvdSequence7M" , "OvdSequence8M" ,"OvdSequence9M" ,"OvdSequence10M" ,"OvdSequence11M" ,"OvdSequence12M" ]]


columns = data.columns
i_day = float(0.40/360)

Profit_not_format = []




for i in range(0, len(data)):
    print(i/(len(data)))
    if data.iloc[i]["ContractStatus"] == 1 and data.iloc[i]["Sum"] != 0 and not data.iloc[i]["Sum"] >= 0:
        Profit_not_format.append(0)
    overdue_com = 0 # For given ID, current lateness
    P = data.iloc[i]["Amount"]  # Кредита които са взели, Главница
    NN = data.iloc[i]["Period"] # Периода на кредита в дни
    Ov = data.iloc[i]["Sum"] # Сумата на всички закъснения за 12 месеца
    S = P*(1+i_day)**NN  # Крайната цена на кредита, Сложна лихва
    if data.iloc[i]["ContractStatus"] == 2:
        Profit_not_format.append(0)
    elif Ov == 0 and NN <= 360:
        Profit_not_format.append(S - P)
    elif Ov == 0 and NN > 360:
        Profit_not_format.append((S - P)*360/NN)
    elif Ov > 0 and NN <= 360: #and NN <= 360:
        Profit_temp = 0 # Profit temp, when Ov > 0
        Interest_temp = S - P # The total interest for given credit
        for x in range(columns.get_loc("OvdSequence1M"),columns.get_loc("OvdSequence12M")+1):
            #Paid without rising the overdue_com count
            if data.iloc[i][x] == overdue_com and data.iloc[i][x] != 8:
                Interest_temp += (-1)*(S/NN*30)
                if Interest_temp < 0 and P > 0:
                    P += Interest_temp
                    Interest_temp += (-1)*Interest_temp
                Profit_temp += S/NN*30
                if P <= 0:
                    Profit_temp += P
                    break
            elif data.iloc[i][x] > overdue_com and data.iloc[i][x] != 8:
                Interest_temp += P*(0.1/12)
                overdue_com += 1
            elif data.iloc[i][x] == 8 and data.iloc[i][x] == 8:
                Profit_temp += (P + Interest_temp)*0.1
                break
        Profit_not_format.append(Profit_temp - data.iloc[i]["Amount"])
    elif Ov > 0 and NN > 360: 
        Expected_profit = (S/NN*30)*12
        Profit_temp = 0 # Profit temp, when Ov > 0
        Interest_temp = S - P # The total interest for given credit
        for x in range(columns.get_loc("OvdSequence1M"),columns.get_loc("OvdSequence12M")+1):
            #Paid without rising the overdue_com count
            if data.iloc[i][x] == overdue_com and data.iloc[i][x] != 8:
                Interest_temp += (-1)*(S/NN*30)
                if Interest_temp < 0 and P > 0:
                    P += Interest_temp
                    Interest_temp += (-1)*Interest_temp
                Profit_temp += S/NN*30
                if P <= 0:
                    Profit_temp += P
                    break
            elif data.iloc[i][x] > overdue_com and data.iloc[i][x] != 8:
                Interest_temp += P*(0.1/12)
                overdue_com += 1
            elif data.iloc[i][x] == 8 and data.iloc[i][x] == 8:
                Profit_temp += (P + Interest_temp)*0.1
                break
        prof = Profit_temp - (P*(360/NN))
        Profit_not_format.append(prof)
            
data["Profit"] = Profit_not_format 

#filepath = Path(f"{dname}/data_with_Profit.csv")
#filepath.parent.mkdir(parents=True, exist_ok=True)  
#data.to_csv(filepath)

######################### Joing the data with Profit Margine


