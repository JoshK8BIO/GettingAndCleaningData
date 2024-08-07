library(dplyr)
#Download data set if not present
file <- "ProjectData.zip"
if(!file.exists(file)){
    URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(URL,file,method="curl")
}
#Unzip file to folder if not already done
if(!file.exists("UCI HAR Dataset")){
    unzip(file)
}
#Read in all necessary files and give each column more descriptive names
activity <- read.table("UCI HAR Dataset/activity_labels.txt",col.names = c("code", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names=c("n","functions"))
testSubject <- read.table("UCI HAR Dataset/test/subject_test.txt",col.names="subject")
testX <- read.table("UCI HAR Dataset/test/X_test.txt",col.names=features$functions)
testY <- read.table("UCI HAR Dataset/test/y_test.txt",col.names="code")
trainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names="subject")
trainX <- read.table("UCI HAR Dataset/train/X_train.txt",col.names=features$functions)
trainY <- read.table("UCI HAR Dataset/train/Y_train.txt",col.names="code")

#Merge training and test data
x <- rbind(trainX, testX)
y <- rbind(trainY, testY)
subject <- rbind(trainSubject,testSubject)
data <- cbind(subject,x,y)

#Selects data variables which contain mean or std
tidyData <- data %>% select(subject,code,contains("mean"),contains("std"))
#Adds column of type of activty
tidyData$code <- activity[tidyData$code, 2]

#Relabel variables
names(tidyData)[2]= "activity"
names(tidyData)<-gsub("Acc","Accelerometer", names(tidyData))
names(tidyData)<-gsub("Gyro","Gyroscope", names(tidyData))
names(tidyData)<-gsub("BodyBody","Body", names(tidyData))
names(tidyData)<-gsub("Mag","Magnitude", names(tidyData))
names(tidyData)<-gsub("^t","Time", names(tidyData))
names(tidyData)<-gsub("^f","Frequency", names(tidyData))
names(tidyData)<-gsub("tBody","TimeBody", names(tidyData))
names(tidyData)<-gsub("-mean()","Mean", names(tidyData), ignore.case=TRUE)
names(tidyData)<-gsub("-std()","STD", names(tidyData), ignore.case=TRUE)
names(tidyData)<-gsub("-freq()","Frequency", names(tidyData), ignore.case=TRUE)

#Create final data with average of each activity and subject
avgData <- tidyData %>% group_by(subject, activity) %>%
    summarise_all(list(mean))
