import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split

import warnings
warnings.filterwarnings(action="ignore")

import os, sys

abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)

data= pd.read_csv(f"{dname}//clients_edited_with_month_int.csv")

data = data.drop(columns = ["Contract_ID", "OvdSequence10M", "OvdSequence11M", "OvdSequence12M",
                  "OvdSequence1M", "OvdSequence2M","OvdSequence3M","OvdSequence4M","OvdSequence5M","OvdSequence6M",
                  "OvdSequence7M", "OvdSequence8M", "OvdSequence9M", "EXCLUDE", "Before/After holiday","Day", "AppDate"])

columns_Var_CCR = ["Var_CCR_01", "Var_CCR_02", "Var_CCR_03", "Var_CCR_04",
                   "Var_CCR_05", "Var_CCR_05", "Var_CCR_06", "Var_CCR_07",
                   "Var_CCR_08", "Var_CCR_09", "Var_CCR_10", "CCR_UsedAmountTot"]
columns_Income = ["Income", "Income3M"]

columns_Installment = ["Installment"]

for c in columns_Var_CCR:
    
    Range=c
    data[Range]=0        
    data.loc[((data[c]>0)&(data[c]<=500)),Range]=1
    data.loc[((data[c]>500)&(data[c]<=1000)),Range]=2
    data.loc[((data[c]>1000)&(data[c]<=3000)),Range]=3
    data.loc[((data[c]>3000)&(data[c]<=5000)),Range]=4
    data.loc[((data[c]>5000)&(data[c]<=10000)),Range]=5
    data.loc[((data[c]>10000)),Range]=6
for c in columns_Income:
    
    Range=c
    data[Range]=0        
    data.loc[((data[c]>=0)&(data[c]<=250)),Range]=1
    data.loc[((data[c]>250)&(data[c]<=500)),Range]=2
    data.loc[((data[c]>500)&(data[c]<=1000)),Range]=3
    data.loc[((data[c]>1000)&(data[c]<=1500)),Range]=4
    data.loc[((data[c]>1500)&(data[c]<=2500)),Range]=5
    data.loc[((data[c]>2500)),Range]=6

for c in columns_Installment:
    
    Range=c
    data[Range]=0        
    data.loc[((data[c]>=0)&(data[c]<=250)),Range]=1
    data.loc[((data[c]>250)&(data[c]<=500)),Range]=2
    data.loc[((data[c]>500)&(data[c]<=1000)),Range]=3
    data.loc[((data[c]>1000)&(data[c]<=1500)),Range]=4
    data.loc[((data[c]>1500)&(data[c]<=2500)),Range]=5
    data.loc[((data[c]>2500)),Range]=6

data = data[data.Age > 17]
data = data[data.Age < 71]

for ind in data.index:
    if data['CreditType'][ind] == "loan_to_salary":
        data.at[ind,'Period'] = data['Period'][ind]/30
        
data["CreditType"] = data["CreditType"].astype('category')
data['CreditType'] = pd.factorize(data['CreditType'])[0]
data["Season"] = data["Season"].astype('category')
data['Season'] = pd.factorize(data['Season'])[0]

list_with_nan = data.columns[data.isna().any()].tolist()


def Linear_Reg_NaN(data):
    df_empty = pd.DataFrame({'A' : []})
    for column in list_with_nan:
        test_data = data[data[column].isnull()]
        test_data.fillna(0, inplace = True)
        test_data = test_data.drop(column,axis = 1)
        train_data = data.dropna(subset=[column])
        
        y_train = train_data[column]
        X_train = train_data.drop(column,axis = 1)
        X_train.fillna(0, inplace = True)
        
        model = LinearRegression()
        model.fit(X_train, y_train)
        model = LinearRegression().fit(X_train, y_train)
        y_pred = model.predict(test_data)
        r_sq = model.score(X_train, y_train)
        print(f"coefficient of determination: {r_sq}")
        df_removed_nan = pd.DataFrame(y_pred, columns = [column])
        df_ALL = test_data.join(df_removed_nan)
        df_empty = pd.concat([df_ALL, train_data], axis=0)
    return df_empty

df_empty = Linear_Reg_NaN(data)

