from unicodedata import category
import pandas as pd
from datetime import datetime
import numpy as np
import os, sys
from sklearn.neighbors import KNeighborsClassifier
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans



abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)

# Loading of the dataframe
df_clients = pd.read_csv(f"{dname}/clients.csv")
df_manual = pd.read_csv(f"{dname}/manual_offer.csv")
df_auto = pd.read_csv(f"{dname}/auto_generated.csv")

test = df_clients.head()
#auto_manual = df_auto.merge(df_manual, key="user_id",", how="outer")

df_manual_C = df_manual.pivot_table(index="user_id",columns='type', aggfunc = "size")
# The total sum of money a user have been taken in auto_generated.csv
df_auto_C_type = df_auto.pivot_table(index="user_id",columns='type', aggfunc = "size")
df_auto_C_amount = df_auto.pivot_table(index="user_id", values = "amount", aggfunc = [np.sum])
# Total unique against loan amount
df_clients_C = df_clients.pivot_table(index="Client_ID", values = "Amount", aggfunc = [np.sum])
#
test_cddasdasdasd = pd.concat([df_manual_C, df_auto_C_type,df_auto_C_amount,df_clients_C], axis=1)
############# Clustering of the data ########################
# Dropping all the non personal info APP_date, Contact ID, Client_ID, OvdSequence10M, OvdSequence11M, 
# OvdSequence12M, OvdSequence1M, OvdSequence2M,OvdSequence3M,OvdSequence4M,OvdSequence5M,OvdSequence6M,
# OvdSequence7M, OvdSequence8M, OvdSequence9M, EXCLUDE
KNN_clustering = df_clients.drop(columns = ["Contract_ID", "Client_ID", "OvdSequence10M", "OvdSequence11M", "OvdSequence12M",
                  "OvdSequence1M", "OvdSequence2M","OvdSequence3M","OvdSequence4M","OvdSequence5M","OvdSequence6M",
                  "OvdSequence7M", "OvdSequence8M", "OvdSequence9M", "EXCLUDE", 'Var_CCR_01',
                                           'Var_CCR_02', 'Var_CCR_03', 'Var_CCR_04', 'Var_CCR_05', 'Var_CCR_06',
                                           'Var_CCR_07', 'Var_CCR_08', 'Var_CCR_09', 'Var_CCR_10', 'CCR_UsedAmountTot'])
# Filling with forward filling method all the NaN values
KNN_clustering.fillna(method='ffill', inplace=True)
# Not all the NaNs are fixed, Unnamed: 5 have 9 rows, with NaN still, removing the 9 rows, in order to do the KNN analize
KNN_clustering = KNN_clustering.dropna()
KNN_clustering = KNN_clustering.reset_index(drop=True)
# From object to data-time object in clients

# Correcting the problem where installment credit is in months but loan-to-salary is in days
# Makes Period column in type Float
KNN_clustering['Period'] = KNN_clustering['Period'].astype(float)

# Makes the correction
for ind in KNN_clustering.index:
    if KNN_clustering['CreditType'][ind] == "loan_to_salary":
        KNN_clustering.at[ind,'Period'] = KNN_clustering['Period'][ind]/30

# Makes the only object type in ord encoded 0 - loan_to_salary, 1 - installment_credit
for col in KNN_clustering['CreditType']:
    KNN_clustering[col] = KNN_clustering[col].astype('category')
KNN_clustering['CreditType'] = pd.factorize(KNN_clustering['CreditType'])[0]



df = pd.DataFrame(KNN_clustering, columns=['Age', 'Installment', 'Unnamed: 5', 'Amount', 'Period',
                                           "Period", 'CreditType', 'AccessChannel2', "AccessChannel",
                                           "BirthRegion", "CreditsCount", "Gender", "IncomeType", 
                                           "NewClient", "PaidCreditsCount", 'PaymentType',
                                           'Income', 'WorkingDays', 'Income3M', 'WorkingDays3M',
                                           'WorkingPlacesCount3M', 'ContractStatus'])

kmeans = KMeans(n_clusters=10)

label = kmeans.fit_predict(KNN_clustering[['Age', 'Installment', 'Unnamed: 5', 'Amount', 'Period',
                                           "Period", 'CreditType', 'AccessChannel2', "AccessChannel",
                                           "BirthRegion", "CreditsCount", "Gender", "IncomeType", 
                                           "NewClient", "PaidCreditsCount", 'PaymentType',
                                           'Income', 'WorkingDays', 'Income3M', 'WorkingDays3M',
                                           'WorkingPlacesCount3M', 'ContractStatus']],  sample_weight = [1,2])

KNN_clustering['Cluster'] = label 


print(KNN_clustering.head())
print(label)
#### NQMA DA STANE
# VISUAL PLS
predict = kmeans.predict(KNN_clustering)
KNN_clustering['Cluster'] = predict
pd.plotting.parallel_coordinates(KNN_clustering, 'Cluster')
plt.show()

print("help")

days = []
df_ct =  df_clients.head()
for i in range(0,len(df_ct)):
    df_ct["AppDate"][i] = df_ct["AppDate"][i].date()

