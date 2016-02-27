library(data.table)

#Set directory path
path = getwd()
path = paste(path, '/dataset', sep="")

#function to cater reading and converting the x-train/x_test data files
fileToDataTable <- function(f) {
    df <- read.table(f)
    #convert to data table class
    dt <- data.table(df)
}

#Loading data set
subjectTrain <- read.table(file.path(path, "train", "subject_train.txt"))
subjectTest <- read.table(file.path(path, "test", "subject_test.txt"))

xTrain <- fileToDataTable(file.path(path, "train", "X_train.txt"))
xTest <- fileToDataTable(file.path(path, "test", "X_test.txt"))

yTrain <- read.table(file.path(path, "train", "Y_train.txt"))
yTest <- read.table(file.path(path, "test", "Y_test.txt"))

labelNames <- fread(file.path(path, "activity_labels.txt"))
setnames(labelNames, names(labelNames), c("index", "activity"))

#Load the feature info and set the column name to be readable
feature <- read.table("dataset/features.txt")
feature <- setNames(feature, c("index", "name"))

#Merging of train data and test data
subject <- rbind(subjectTrain, subjectTest)
x <- rbind(xTrain, xTest)
y <- rbind(yTrain, yTest)

#rename columns of y and subject 
setnames(subject, "V1", "subject")
setnames(y, "V1", "activity")

#combine x, y and feature together
subject <- cbind(subject, y)
dt <- cbind(x, subject)

#create a feature code column V1...V5XX to match with x data
feature$featureCode <-  paste("V", feature[,"index"], sep="")

#Regression to get the index of variable that is a measurement of mean or std
#grepl return a boolean vector of T/F which will be use to subset those name column which are true
feature = feature[grepl("mean\\(\\)|std\\(\\)",feature[,"name"]),]


#subset the dt data using the boolean vector (feature$featureCode)
select <- c("subject", "activity", feature$featureCode)
d = dt[, select, with = FALSE]


activity <- fread(file.path(path, "activity_labels.txt"))
setnames(activity, names(activity), c("index", "activity"))

#merge the activity label name (index) with the data in d (subject)
d <- merge(d, activity, by.x = "activity", by.y = "index", all.x = TRUE)
#remove the 1st column 
d <- d[, 2:length(d[1,]),with = FALSE]

#change the columns (Vx - Vxxx) in d using the feature name
for(i in 1:length(d[1,])){ #loop column
    for(t in 1:length(feature[,1])){ #loop by row
        if(colnames(d)[i] == feature[t,3]){
            print(colnames(d)[i])
            colnames(d)[i] <- as.character(feature[t,2])
            print(colnames(d)[i])
            break
        }
    }#end of feature loop
}#end of d loop

#remove "()" character from the column name
for(i in 1:length(d[1,])){
    colnames(d)[i] <- gsub('[()]','', colnames(d)[i])
}

#set key
setkey(d,subject, activity)

#group by subject and activity and determine the mean for each variable
#result is a tidy data
tidyData<-aggregate(d[,2:( length(d[1,])-1),with = FALSE], by=list(d$subject,d$activity), FUN=mean)

#Rename the grouped columns (subject and activity)
colnames(tidyData)[1] <- "subject"
colnames(tidyData)[2] <- "activity"

#write the tidy data to csv
write.csv(tidyData, 'DatasetHumanActivityRecognition.csv')



