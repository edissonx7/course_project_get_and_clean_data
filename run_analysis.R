#Download and upzip the data

# if(!file.exists("./data")){dir.create("./data")}
# fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# # download the file under Windows10.
# download.file(fileUrl,destfile="./data/Dataset.zip")
# 
# unzip(zipfile="./data/Dataset.zip",exdir="./data")

path <- file.path("./data" , "UCI HAR Dataset")
#files<-list.files(path, recursive=TRUE)
#files

#Load data from the files
datActTest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
datActTrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
datSubTrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
datSubTest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
datFeaTest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
datFeaTrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

#1.Merges the training and the test sets to create one data set

datSub <- rbind(datSubTrain, datSubTest)
datAct<- rbind(datActTrain, datActTest)
datFea<- rbind(datFeaTrain, datFeaTest)

names(datSub)<-c("subject")
names(datAct)<- c("activity")
datFeaNames <- read.table(file.path(path, "features.txt"),head=FALSE)
names(datFea)<- datFeaNames$V2
datSubAct <- cbind(datSub, datAct)
dat <- cbind(datFea, datSubAct)

#2.Extracts only the measurements on the mean and standard deviation for each measurement

subdatFeaNames<-datFeaNames$V2[grep("mean\\(\\)|std\\(\\)", datFeaNames$V2)]
selectedNames<-c(as.character(subdatFeaNames), "subject", "activity" )
dat<-subset(dat,select=selectedNames)
#str(dat)

#3.Uses descriptive activity names to name the activities in the data set
dtActLabels <- read.table(file.path(path, "activity_labels.txt"),header = FALSE)
dat$activity <- dtActLabels[dat$activity,2]
#head(dat$activity,50)

#4.Appropriately labels the data set with descriptive variable names
names(dat)<-gsub("^t", "Time", names(dat))
names(dat)<-gsub("^f", "Frequency", names(dat))
names(dat)<-gsub("Acc", "Accelerometer", names(dat))
names(dat)<-gsub("Gyro", "Gyroscope", names(dat))
names(dat)<-gsub("Mag", "Magnitude", names(dat))
names(dat)<-gsub("BodyBody", "Body", names(dat))

#names(dat)

##5.Creates a second,independent tidy data set and ouput it

library(plyr);
datTidy<-aggregate(. ~subject + activity, dat, mean)
datTidy<-datTidy[order(datTidy$subject,datTidy$activity),]
write.table(datTidy, file = "tidydata.txt",row.name=FALSE)

##6.Make Cood book.
library(knitr)
knit2html("codebook.Rmd")