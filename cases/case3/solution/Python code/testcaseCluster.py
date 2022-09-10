#from numba import jit, cuda
import numpy as np
import pandas as pd
from pathlib import Path
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans
import statsmodels.api as sm
from statsmodels.formula.api import ols
import os, sys

abspath = os.path.abspath(sys.argv[0])
dname = os.path.dirname(abspath)
os.chdir(dname)

data= pd.read_csv(f"{dname}//clients_edited_with_month_int.csv")
print(data.shape)
print(data.head())

print(data.describe())
data_describe = data.describe()

# Dealing with Missing Values  
print(data.isnull().sum().sort_values(ascending=False).head())  
# Replacing missing values with mean, except for OvdSequence1M, OvdSequence10M, OvdSequence8M
data.loc[(data['WorkingDays'].isnull()==True),'WorkingDays']=data['WorkingDays'].mean()
data.loc[(data['Income'].isnull()==True),'Income']=data['Income'].mean() 
#Checking again for Missing Values
print(data.isnull().sum().sort_values(ascending=False).head())
######################
# Removing the problematic Ages, ages in the module from 18 to 70 years old
data = data[data.Age > 17]
data = data[data.Age < 71]


# Removing the problem with loan-to-salary and installment credit
for ind in data.index:
    if data['CreditType'][ind] == "installment":
        data.at[ind,'Period'] = data['Period'][ind] * 30
#########################
# Making seasons as dummies
data = pd.get_dummies(data, columns = ["Season"])
# Making credit type facturized

data["CreditType"] = data["CreditType"].astype('category')


values = ["Month", "Age", "Installment", "Period", "Season_Fall","Season_Spring", "Season_Summer", "Season_Winter",
          "ContractStatus", "WorkingPlacesCount3M", "WorkingDays3M", "Income", "Income3M", "BirthRegion",
          "AccessChannel", "AccessChannel2", "CreditType", "Var_CCR_01", "Var_CCR_02", "Var_CCR_03",
          "Var_CCR_04", "Var_CCR_05", "Var_CCR_06", "Var_CCR_07", "Var_CCR_08",
          "Var_CCR_09", "Var_CCR_10", "Installment","CCR_UsedAmountTot"]



# Clients ID unique making
def sum_int_client_id(df, index,value):
    # Counter for CLIENT occurance
    count_weight = data.pivot_table(values='Age', index='Client_ID', aggfunc="count")
    # Index, po koito trqbva da gleda
    # Columns ime na kolona, koqto iskam da vidq
    for element in value:
        df_element = df.pivot_table(index=index,values=element, aggfunc = np.sum)
        count_weight = pd.merge(count_weight,df_element, left_on = "Client_ID", right_on = "Client_ID" ,how = "outer")
    return count_weight

# For CCR_USEDAmountToT

data["CCR_UsedAmountTot"] = data["CCR_UsedAmountTot"].clip(upper=40000)

data["WorkingDays3M"] = data["WorkingDays3M"].clip(upper=90)

data["WorkingPlacesCount3M"] = data["WorkingPlacesCount3M"].clip(upper=3)
    
########## CREATING THE DATAFRAME THAT WILL MAKE THE K-Means 
count_weight = sum_int_client_id(data, "Client_ID", values)

# Creating the list for the weight value
weight_factor = []
for ind in count_weight.index:
    weight_factor.append(1/count_weight['Age_x'][ind]) 
    
    
#Creating column maker if all numeric
def column_maker(df):
    columns = []
    for column in df:
        columns.append(column)
    return columns


def weight_columns(df):
    columns = column_maker(count_weight)
    for col in columns:
        if col != "Age_x":
            df[col] = df[col].div(df["Age_x"].values)
    return df
# Dataframe Weighted 
df_Weight = weight_columns(count_weight)

#data_describe_W = df_Weight.describe()


#####################The code before is making the data##########################

###################### First part of the documentation code######################
min_clusters = 2
max_clusters = 15

# function returns WSS score for k values from 1 to kmax
def within_sum_of_squares(data, centroids, labels):
  
    SSW = 0
    for l in np.unique(labels):
        data_l = data[labels == l]
        resid = data_l - centroids[l]
        SSW += (resid**2).sum()
    return SSW

wss_list = []
for i in range(min_clusters, max_clusters+1):
  print('Training {} cluster algoritem'.format(i))
  km = KMeans(n_clusters=i)
  km.fit(df_Weight)
  wss = within_sum_of_squares(np.array(df_Weight),km.cluster_centers_, km.predict(df_Weight))    
  wss_list.append(wss)
plt.plot(wss_list)
plt.title('WSS Plot')
plt.xlabel('# of Clusters')
plt.ylabel('WSS')
plt.show()

perc_improve_list = [0]
rel_improvement = []
base_wss = wss_list[0]
for i in range(len(wss_list)):
  improvement = (wss_list[0] - wss_list[i])/wss_list[0]
  rel_improvement.append(improvement - perc_improve_list[-1])
  perc_improve_list.append(improvement)
  
threshold = 0.05
plt.plot([i for i in range(min_clusters+1,max_clusters+1)], rel_improvement[1:])
plt.axhline(threshold, linestyle='--', color='grey')
plt.title('WSS Improvement Plot')
plt.xlabel('# of Clusters')
plt.ylabel('% improvement in WSS')
plt.ylim([0,0.3])
plt.show()



list_columns = df_Weight.columns

df = pd.DataFrame(df_Weight, columns=list_columns)

kmeans = KMeans(n_clusters=7)

label = kmeans.fit_predict(df_Weight[list_columns])

df_Weight['Cluster'] = label 
df_Weight = pd.DataFrame(df_Weight)


print(df_Weight.head())
print(label)








######## ANOVA ############## 
df_Weight.drop("Installment_y", axis = 1, inplace = True)
df_Weight = df_Weight.rename(columns = {"Age_x": "Numb_of_Creds"})
df_Weight = df_Weight.rename(columns = {"Age_y": "Age"})
df_Weight = df_Weight.rename(columns = {"Installment_x": "Installment"})


def Ete_sqr(data):
    cols = data.columns
    dict_Ete_sqr = {}
    for col in cols:
        if col != "Cluster":
            model = ols(f'{col} ~ C(Cluster)', data=data).fit()
            anova_table = sm.stats.anova_lm(model, typ=2)
            a = anova_table
            cluster = a.iloc[0]["sum_sq"]
            residual = a.iloc[1]["sum_sq"]
            dict_Ete_sqr[col] = cluster/(cluster+residual)
    return dict_Ete_sqr

dict_Ete_sqr = Ete_sqr(df_Weight)

Ete_vis = dict_Ete_sqr
names = list(Ete_vis.keys())
values = list(Ete_vis.values())
plt.xticks(rotation=90)
plt.bar(range(len(Ete_vis)), values, tick_label=names)


###################### End of First Part, End of 1 iteration ##################

###################### Second iteration of the clusterization #################

# FEATURE extraction ######################


df_Weight.drop(["Numb_of_Creds", "Month", "Installment",
                "Season_Fall", "Season_Spring", "Season_Summer", "Season_Winter",
                "BirthRegion", "AccessChannel", "AccessChannel2"], axis = 1, inplace = True)


min_clusters = 2
max_clusters = 15

# function returns WSS score for k values from 1 to kmax
def within_sum_of_squares(data, centroids, labels):
  
    SSW = 0
    for l in np.unique(labels):
        data_l = data[labels == l]
        resid = data_l - centroids[l]
        SSW += (resid**2).sum()
    return SSW

wss_list = []
for i in range(min_clusters, max_clusters+1):
  print('Training {} cluster algoritem'.format(i))
  km = KMeans(n_clusters=i)
  km.fit(df_Weight)
  wss = within_sum_of_squares(np.array(df_Weight),km.cluster_centers_, km.predict(df_Weight))    
  wss_list.append(wss)
plt.plot(wss_list)
plt.title('WSS Plot')
plt.xlabel('# of Clusters')
plt.ylabel('WSS')
plt.show()

perc_improve_list = [0]
rel_improvement = []
base_wss = wss_list[0]
for i in range(len(wss_list)):
  improvement = (wss_list[0] - wss_list[i])/wss_list[0]
  rel_improvement.append(improvement - perc_improve_list[-1])
  perc_improve_list.append(improvement)
  
threshold = 0.05
plt.plot([i for i in range(min_clusters+1,max_clusters+1)], rel_improvement[1:])
plt.axhline(threshold, linestyle='--', color='grey')
plt.title('WSS Improvement Plot')
plt.xlabel('# of Clusters')
plt.ylabel('% improvement in WSS')
plt.ylim([0,0.3])
plt.show()


list_columns = df_Weight.columns

df = pd.DataFrame(df_Weight, columns=list_columns)

kmeans = KMeans(n_clusters=7)

label = kmeans.fit_predict(df_Weight[list_columns])

df_Weight['Cluster'] = label 
df_Weight = pd.DataFrame(df_Weight)


dict_Ete_sqr = Ete_sqr(df_Weight)

Ete_vis = dict_Ete_sqr
names = list(Ete_vis.keys())
values = list(Ete_vis.values())
plt.xticks(rotation=90)
plt.bar(range(len(Ete_vis)), values, tick_label=names)

######################## End of second iteration ##############################

#################### Start of 3th iteration ###################################

#df_Weight.drop(["Income3M","CCR_UsedAmountTot", "Var_CCR_03", "Var_CCR_06",
                #"Var_CCR_08", "Var_CCR_10", "Contract_ID"], axis = 1, inplace = True)
pd.get_dummies(data["CreditType"])
#pd.get_dummies(data["CreditType"])
data.drop(["AppDate","OvdSequence1M","OvdSequence2M" ,"OvdSequence3M"
           ,"OvdSequence4M", "OvdSequence5M", "OvdSequence6M"
           ,"OvdSequence7M", "OvdSequence8M", "OvdSequence9M","OvdSequence10M"
           ,"OvdSequence11M","OvdSequence12M", "Unnamed: 10", "Before/After holiday", "EXCLUDE", "Day"], axis =1, inplace=True)
data = pd.get_dummies(data,columns =["CreditType"], dtype = int)

data.interpolate(method='linear', limit_direction='both', axis=1, inplace = True)

min_clusters = 2
# change to 15, when giving the code to repository
max_clusters = 15

# function returns WSS score for k values from 1 to kmax
def within_sum_of_squares(data, centroids, labels):
    SSW = 0
    for l in np.unique(labels):
        data_l = data[labels == l]
        resid = data_l - centroids[l]
        SSW += (resid**2).sum()
    return SSW

wss_list = []
for i in range(min_clusters, max_clusters+1):
  print('Training {} cluster algoritem'.format(i))
  km = KMeans(n_clusters=i)
  km.fit(data)
  wss = within_sum_of_squares(np.array(data),km.cluster_centers_, km.predict(data))    
  wss_list.append(wss)
plt.plot(wss_list)
plt.title('WSS Plot')
plt.xlabel('# of Clusters')
plt.ylabel('WSS')
plt.show()

perc_improve_list = [0]
rel_improvement = []
base_wss = wss_list[0]
for i in range(len(wss_list)):
  improvement = (wss_list[0] - wss_list[i])/wss_list[0]
  rel_improvement.append(improvement - perc_improve_list[-1])
  perc_improve_list.append(improvement)
  
threshold = 0.05
plt.plot([i for i in range(min_clusters+1,max_clusters+1)], rel_improvement[1:])
plt.axhline(threshold, linestyle='--', color='grey')
plt.title('WSS Improvement Plot')
plt.xlabel('# of Clusters')
plt.ylabel('% improvement in WSS')
plt.ylim([0,0.3])
plt.show()


list_columns = ["Income3M","CCR_UsedAmountTot", "Var_CCR_03", "Var_CCR_06",
                "Var_CCR_08", "Var_CCR_10", "Client_ID"]

df = pd.DataFrame(data, columns=list_columns)

kmeans = KMeans(n_clusters=4)

label = kmeans.fit_predict(data[list_columns])

data['Cluster'] = label 
data = pd.DataFrame(data)

dict_Ete_sqr = Ete_sqr(data)

Ete_vis = dict_Ete_sqr
names = list(Ete_vis.keys())
values = list(Ete_vis.values())
plt.xticks(rotation=90)
plt.bar(range(len(Ete_vis)), values, tick_label=names)



#filepath = Path(f"{dname}/data_with_Profit.csv")
#filepath.parent.mkdir(parents=True, exist_ok=True)  
#df_Weight.to_csv(filepath)