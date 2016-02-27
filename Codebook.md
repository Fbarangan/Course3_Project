#Human Activity Recognition Using Smartphones Dataset

#Fields

First Header | Second Header
------------ | -------------
"subject" | ID the subject who performed the activity for each window sample. Its range is from 1 to 30.                   
"activity" | Name of the activity that was performed                 
"BodyAcc-mean-X" | Mean acceleration signal for body in X variable       
* "BodyAcc-mean-Y" | Mean acceleration signal for body in Y variable          
* "BodyAcc-mean-Z" | Mean acceleration signal for body in Z variable 
* "BodyAcc-std-X"   | Standard Deviation acceleration signal for body in X variable         
* "BodyAcc-std-Y"   | Standard Deviation acceleration signal for body in Y variable              
* "BodyAcc-std-Z"   | Standard Deviation acceleration signal for body in Z variable             
* "GravityAcc-mean-X"   | Mean gravity signal for body in X variable          
* "GravityAcc-mean-Y"    | Mean gravity signal for body in Y variable    
* "GravityAcc-mean-Z"   | Mean gravity signal for body in Z variable      
* "GravityAcc-std-X"    | Standard Deviation gravity signal for body in X variable     
* "GravityAcc-std-Y"    | Standard Deviation gravity signal for body in Y variable       
* "GravityAcc-std-Z"   | Standard Deviation gravity signal for body in Z variable       
* "BodyAccJerk-mean-X"    | Mean jerk signal for body in X variable  when performing acceleration signal gathering   
* "BodyAccJerk-mean-Y"    | Mean jerk signal for body in Y variable  when performing acceleration signal gathering     
* "BodyAccJerk-mean-Z"    | Mean jerk signal for body in Z variable  when performing acceleration signal gathering      
* "BodyAccJerk-std-X"      | Standard Deviation jerk signal for body in X variable  when performing acceleration signal gathering    
* "BodyAccJerk-std-Y"      | Standard Deviation jerk signal for body in Y variable  when performing acceleration signal gathering     
* "BodyAccJerk-std-Z"     | Standard Deviation jerk signal for body in Z variable  when performing acceleration signal gathering    
* "BodyGyro-mean-X"       | Mean Gyroscope signal for body in X variable    
* "BodyGyro-mean-Y"       | Mean Gyroscope signal for body in Y variable   
* "BodyGyro-mean-Z"       | Mean Gyroscope signal for body in Z variable    
* "BodyGyro-std-X"         | Standard Deviation Gyroscope signal for body in X variable  
* "BodyGyro-std-Y"         | Standard Deviation Gyroscope signal for body in Y variable   
* "BodyGyro-std-Z"         | Standard Deviation Gyroscope signal for body in Z variable  
* "BodyGyroJerk-mean-X"    | Mean jerk signal for body in X variable when performing gyroscope signal gathering      
* "BodyGyroJerk-mean-Y"     | Mean jerk signal for body in Y variable when performing gyroscope signal gathering  
* "BodyGyroJerk-mean-Z"     | Mean jerk signal for body in Z variable when performing gyroscope signal gathering   
* "BodyGyroJerk-std-X"      | Standard Deviation jerk signal for body in X variable when performing gyroscope signal gathering  
* "BodyGyroJerk-std-Y"      | Standard Deviation jerk signal for body in Y variable when performing gyroscope signal gathering   
* "BodyGyroJerk-std-Z"      | Standard Deviation jerk signal for body in Z variable when performing gyroscope signal gathering  
* "BodyAccMag-mean"        | Mean acceleration signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm    
* "BodyAccMag-std"          | Standard Deviation acceleration signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm    
* "GravityAccMag-mean"    | Mean gravity signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm     
* "GravityAccMag-std"      | Standard Deviation gravity signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm   
* "BodyAccJerkMag-mean"  | Mean jerk signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm when performing acceleration signal gathering         
* "BodyAccJerkMag-std" | Standard Deviation jerk signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm when performing acceleration signal gathering      
* "BodyGyroMag-mean" | Mean gyroscope signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm             
* "BodyGyroMag-std"  | Standard Deviation gyroscope signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm            
* "BodyGyroJerkMag-mean" | Mean jerk signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm when performing gyroscope signal gathering      
* "BodyGyroJerkMag-std"  | Standard Deviation jerk signal for body in X variable with Magnitude of the signals calculated using the Euclidean norm when performing gyroscope signal gathering      


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

##This whole part till the writing to csv basically divide the t and f data to 2 files and merge it together
##There will be some missing columns in f data which we will need to add in order to rbind with t data
tmpData <- tidyData[,43:68]
tmpData <- cbind(tidyData[,1:2], tmpData)
for(k in 1:3){
    index <- 8
    list<- c("tGravityAcc-mean-X", "tGravityAcc-mean-Y","tGravityAcc-mean-Z" ,"tGravityAcc-std-X","tGravityAcc-std-Y" ,"tGravityAcc-std-Z" )
    if(k == 2){
        index <- 26
        list<-c("tBodyGyroJerk-mean-X","tBodyGyroJerk-mean-Y","tBodyGyroJerk-mean-Z" ,"tBodyGyroJerk-std-X","tBodyGyroJerk-std-Y" ,"tBodyGyroJerk-std-Z" )
    }    
    else if(k == 3){
        index <- 34
        list<-c("tGravityAccMag-mean" ,"tGravityAccMag-std")
    }
    
    for(i in 1:length(list)){
        tmpData <- data.frame(tmpData[1:index],"x"="",tmpData[(index+1):ncol(tmpData)])
        index <- index + 1
        colnames(tmpData)[index] <- list[i]
    }
}
for(i in 3:length(tmpData[1,])){
    if(i <= (length(tmpData[1,]) - 6)){
        colnames(tmpData)[i] <- substring(colnames(tmpData)[i], 2, nchar(colnames(tmpData)[i]))
    }
    else{
        colnames(tmpData)[i] <- substring(colnames(tmpData)[i], 6, nchar(colnames(tmpData)[i]))
    }
    
    colnames(tmpData)[i] <- str_replace_all(colnames(tmpData)[i], "([.])", "-")
}

t <- tidyData[,1:42]
for(i in 3:length(t[1,])){
    colnames(t)[i] <- substring(colnames(t)[i], 2, nchar(colnames(t)[i]))
}

tidyData <- rbind(t, tmpData)

##write the tidy data to csv
* write.csv(tidyData, 'DatasetHumanActivityRecognition.csv')






