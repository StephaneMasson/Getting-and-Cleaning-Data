##Course Projet Getting and Cleaning Data

##Compile Library

library(dplyr)
library(data.table)

##Getting Data

dataset_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#Create Directory
if(!file.exists("./ProjectData")) {dir.create("./ProjectData")}

#Download DataSet
download.file(dataset_url, destfile = "./ProjectData/ProjectDataSet.zip" )

#Unzip Data Sets
unzip (".ProjectData/ProjectDataSet.zip", exdir = "./ProjectData")

#Load DataSets in R

#test and training sets
trainsubject <-read.table("./ProjectData/UCI HAR Dataset/train/subject_train.txt")
testsubject <- read.table("./ProjectData/UCI HAR Dataset/test/subject_test.txt")
ytrain <- read.table("./ProjectData/UCI HAR Dataset/train/y_train.txt")
xtrain <- read.table("./ProjectData/UCI HAR DataSet/train/X_train.txt")
ytest <- read.table("./ProjectData/UCI HAR Dataset/test/y_test.txt")
xtest <- read.table("./ProjectData/UCI HAR DataSet/test/X_test.txt")

#features
feature <- read.table("./ProjectData/UCI HAR Dataset/features.txt")

#Activities
activity <-read.table("./ProjectData/UCI HAR Dataset/activity_labels.txt")


#Merging the test and training DataSets using rbind()

subject <- rbind(trainsubject,testsubject)
y <-rbind(ytest,ytrain)
x <- rbind (xtest,xtrain)

#Identifying the mean and std dev measures
mean.stddev <- grep("-mean\\(\\)|-std\\(\\)", feature[, 2])
x.mean.stddev <- x[, mean.stddev]

# Identify and transform features
names(x.mean.stddev) <- feature[mean.stddev, 2]
names(x.mean.stddev) <- tolower(names(x.mean.stddev)) 
names(x.mean.stddev) <- gsub("\\(|\\)", "", names(x.mean.stddev))

# Identify and transform Activity labels
activity[, 2] <- tolower(as.character(activity[, 2]))
activity[, 2] <- gsub("_", "", activity[, 2])

#Rename Columns
mergedactiviy = merge(y,activity, by.x = "V1", by.y ="V1", all = TRUE)
y[, 1] = mergedactiviy[,2]
colnames(y) <- 'activity'
colnames(subject) <- 'subject'

# Match labels and descriptive activity names.
dataset <- cbind(subject, y, x.mean.stddev)
str(dataset)
write.table(dataset, './ProjectData/ProjectDataSet.txt')

## Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

#transform previous DataSet into Data.table format

data <- data.table(dataset)

#aggregate by subject and activity
ProjectDataSet2 <- data[, lapply(.SD,mean, na.rm = TRUE), by=list(subject,activity)]

str(ProjectDataSet2)

#Write Dataset in txt file
write.table(ProjectDataSet2, './ProjectData/ProjectDataSet2.txt', row.name = FALSE)
