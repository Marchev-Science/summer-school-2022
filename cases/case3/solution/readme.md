Analysis:
1.	VBA Code ” folder contains a Visual module Basic to retrieve:
•	The day of the date – business, holiday with its name, before the holiday, after the holiday; The year;
•	Month from date ;
•	The day of the date;
•	The season of the date.;
a.	To execute it, five empty columns must be added to the left of the original clients.csv file. The result can be seen in the folder: Case3_work_files/ Case Inputs transformed with Dates and Holidays


2.	Distributions " folder there are 3 pictures from Orange of the distribution of the data in the clients.csv file as originally received, without corrections. Distributions are divided by credit status – 1 taken, 2 denied. The three images in the folder show the distribution of credits by year; day - including holidays and the periods before or after them and ; months.


3.	Only the credits taken from the clients.csv file and both the auto_generated.csv and manual_offer.csv files are sorted by date and can be viewed in the folder Case3_work_files/ Case Inputs transformed with Dates and Holidays . The resulting file: clients_credit_accepted_channel_by_date.csv is used to determine if there was a message on one of the channels before the credit was taken. This idea will be further developed.

4.	In the folder Case3_work_files/ SMS, E- mail , Viber price and number , there are two files summing up the number of sms , e -mails and viber messages, multiply by the price for them to find the cost of a campaign and calculate the cost per channel or client. The price for them is calculated from package marketing plans for 10,000 messages. We did not find prices on Bulgarian sites, but only on foreign ones in dollars or euros, which are equated to levs. Therefore, the price may vary from the real one for Bulgaria. This idea will be further developed

5.	In Case3_work_files/ Python folder code , there are 5 files:
•	case3.py - the initial script that was used as a testbed to examine the data.
•	testcaseClusters.py - The script with which we performed the Within-Cluster analysis Sum of Squares and adding the clusters to dataframe -a. This is the code for all 3 iterations, with feature extraction .
•	Profit_Margin.p y - This code calculates the Profit for each customer and outputs it to the DataFrame.
•	Test_Join_Profit_Clusters.py - To execute the last part of a task, the script is not ready. 
•	Liner - Regression-Filling-Nans.py - We tried filling the NaN values using Linear Regression , but the success and accuracy was up to 20%, so we don't use it in the Assignment.

Answer:
Orange " folder is the logic for constructing a tree with the target day. The resulting file from the Python conversion : data_with_Prof_clusters.csv is loaded into the Orange program , using the Tree.ows file for settings . This is how we get the tree, photos of which are also in the " Orange " folder.


