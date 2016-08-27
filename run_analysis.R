library("reshape2")
library("knitr")
library("markdown")

# Download and unzip dataset [this should already be in the working folder]

#fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download.file(fileUrl,destfile="Dataset.zip")
#unzip("Dataset.zip")

# Extract activity labels and features

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("ActivityId", "Activity"))
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("FeatureId", "Feature"))
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation

ReqFeatures <- grep(".*mean.*|.*std.*", features[,2])
ReqFeatures.names <- features[ReqFeatures,2]
ReqFeatures.names = gsub('-mean', 'Mean', ReqFeatures.names)
ReqFeatures.names = gsub('-std', 'Std', ReqFeatures.names)
ReqFeatures.names <- gsub('[-()]', '', ReqFeatures.names)


# Load the train and test datasets

train <- read.table("UCI HAR Dataset/train/X_train.txt")[ReqFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[ReqFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# Merge datasets and add labels

allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", ReqFeatures.names)

# Turn activities and subjects into factors

allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

# Change data to wide format and aggregate by mean value

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)


# Export a second, independent tidy data set with the average of each variable for each activity and each subject.

write.table(allData.mean, "tidy-output.txt", row.names = FALSE, quote = FALSE)
