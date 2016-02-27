#Human Activity Recognition Using Smartphones Dataset

#Fields
* "subject"                   
* "activity"                 
* "tBodyAcc-mean-X"           
* "tBodyAcc-mean-Y"          
* "tBodyAcc-mean-Z"           
* "tBodyAcc-std-X"           
* "tBodyAcc-std-Y"            
* "tBodyAcc-std-Z"           
* "tGravityAcc-mean-X"        
* "tGravityAcc-mean-Y"       
* "tGravityAcc-mean-Z"        
* "tGravityAcc-std-X"        
* "tGravityAcc-std-Y"         
* "tGravityAcc-std-Z"        
* "tBodyAccJerk-mean-X"       
* "tBodyAccJerk-mean-Y"      
* "tBodyAccJerk-mean-Z"       
* "tBodyAccJerk-std-X"       
* "tBodyAccJerk-std-Y"        
* "tBodyAccJerk-std-Z"       
* "tBodyGyro-mean-X"          
* "tBodyGyro-mean-Y"         
* "tBodyGyro-mean-Z"          
* "tBodyGyro-std-X"          
* "tBodyGyro-std-Y"           
* "tBodyGyro-std-Z"          
* "tBodyGyroJerk-mean-X"      
* "tBodyGyroJerk-mean-Y"     
* "tBodyGyroJerk-mean-Z"      
* "tBodyGyroJerk-std-X"      
* "tBodyGyroJerk-std-Y"       
* "tBodyGyroJerk-std-Z"      
* "tBodyAccMag-mean"          
* "tBodyAccMag-std"          
* "tGravityAccMag-mean"       
* "tGravityAccMag-std"       
* "tBodyAccJerkMag-mean"      
* "tBodyAccJerkMag-std"      
* "tBodyGyroMag-mean"         
* "tBodyGyroMag-std"         
* "tBodyGyroJerkMag-mean"     
* "tBodyGyroJerkMag-std"     
* "fBodyAcc-mean-X"           
* "fBodyAcc-mean-Y"          
* "fBodyAcc-mean-Z"           
* "fBodyAcc-std-X"           
* "fBodyAcc-std-Y"            
* "fBodyAcc-std-Z"           
* "fBodyAccJerk-mean-X"       
* "fBodyAccJerk-mean-Y"      
* "fBodyAccJerk-mean-Z"       
* "fBodyAccJerk-std-X"       
* "fBodyAccJerk-std-Y"        
* "fBodyAccJerk-std-Z"       
* "fBodyGyro-mean-X"          
* "fBodyGyro-mean-Y"         
* "fBodyGyro-mean-Z"          
* "fBodyGyro-std-X"          
* "fBodyGyro-std-Y"           
* "fBodyGyro-std-Z"          
* "fBodyAccMag-mean"          
* "fBodyAccMag-std"          
* "fBodyBodyAccJerkMag-mean"  
* "fBodyBodyAccJerkMag-std"  
* "fBodyBodyGyroMag-mean"     
* "fBodyBodyGyroMag-std"     
* "fBodyBodyGyroJerkMag-mean" 
* "fBodyBodyGyroJerkMag-std"


#The dataset includes the following files
* run_analysis.R - the actual code to produce DatasetHumanActivityRecognition.csv based on the input using the train and test data from Human Activity Recognition Using Smartphones Dataset from smartlab.ws

* DatasetHumanActivityRecognition.csv - the result data produced using the above R script

* ReadMe.md - read me info

* CodeBook.md - more information of executing the script and the fields contained from the result csv


#Executing the script
##Library required
In this script we will required to use data.table
* library(data.table)

##Set directory path
* path = getwd()
* path = paste(path, '/dataset', sep="")

##function to cater reading and converting the x-train/x_test data files
Note that, as the input files for x data have a lot of unwanted rows and columns, we will need to carefully select and clean up the data after loading
Thus, this function help on that job when we try to load the x data files

fileToDataTable <- function(f) {
    df <- read.table(f)
    #convert to data table class
    dt <- data.table(df)
}

##Loading data set
* subjectTrain <- read.table(file.path(path, "train", "subject_train.txt"))
* subjectTest <- read.table(file.path(path, "test", "subject_test.txt"))
* xTrain <- fileToDataTable(file.path(path, "train", "X_train.txt"))
* xTest <- fileToDataTable(file.path(path, "test", "X_test.txt"))
* yTrain <- read.table(file.path(path, "train", "Y_train.txt"))
* yTest <- read.table(file.path(path, "test", "Y_test.txt"))

##Label some of the default label to something sensable
* labelNames <- fread(file.path(path, "activity_labels.txt"))
* setnames(labelNames, names(labelNames), c("index", "activity"))

##Load the feature info and set the column name to be readable
* feature <- read.table("dataset/features.txt")
* feature <- setNames(feature, c("index", "name"))

##Merging of train data and test data
* subject <- rbind(subjectTrain, subjectTest)
* x <- rbind(xTrain, xTest)
* y <- rbind(yTrain, yTest)

##rename columns of y and subject 
* setnames(subject, "V1", "subject")
* setnames(y, "V1", "activity")

##combine x, y and feature together
* subject <- cbind(subject, y)
* dt <- cbind(x, subject)

##create a feature code column V1...V5XX to match with x data
* feature$featureCode <-  paste("V", feature[,"index"], sep="")

##Regression to get the index of variable that is a measurement of mean or std
##grepl return a boolean vector of T/F which will be use to subset those name column which are true
* feature = feature[grepl("mean()|std()",feature[,"name"]),]


##subset the dt data using the boolean vector (feature$featureCode)
* select <- c("subject", "activity", feature$featureCode)
* d = dt[, select, with = FALSE]

* activity <- fread(file.path(path, "activity_labels.txt"))
* setnames(activity, names(activity), c("index", "activity"))


##merge the activity label name (index) with the data in d (subject)
*d <- merge(d, activity, by.x = "activity", by.y = "index", all.x = TRUE)


##remove the 1st column 
* d <- d[, 2:length(d[1,]),with = FALSE]


##change the columns (Vx - Vxxx) in d using the feature name
for(i in 1:length(d[1,])){ #loop column
    for(t in 1:length(feature[,1])){ #loop by row
        if(colnames(d)[i] == feature[t,3]){
            print(colnames(d)[i])
            colnames(d)[i] <- as.character(feature[t,2])
            print(colnames(d)[i])
            break
        }
    }#end of feature loop
} *end of d loop*

##remove "()" character from the column name
for(i in 1:length(d[1,])){
    colnames(d)[i] <- gsub('[()]','', colnames(d)[i])
}

##set key
* setkey(d,subject, activity)

##group by subject and activity and determine the mean for each variable
##result is a tidy data
* tidyData<-aggregate(d[,2:( length(d[1,])-1),with = FALSE], by=list(d$subject,d$activity), FUN=mean)

##Rename the grouped columns (subject and activity)
* colnames(tidyData)[1] <- "subject"
* colnames(tidyData)[2] <- "activity"

##write the tidy data to csv
* write.csv(tidyData, 'DatasetHumanActivityRecognition.csv')






