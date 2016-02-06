# Load necessary libraries, download data and unzip it
library(reshape2)
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data.zip")
unzip("data.zip") 

# Extract labels and features
labels <- read.table("UCI HAR Dataset/activity_labels.txt",colClasses=c("integer","character"))
features <- read.table("UCI HAR Dataset/features.txt",colClasses=c("integer","character"))

# Extract only variables with mean and SD
feats <- grep(".*mean.*|.*std.*", features[,2])
f_names <- features[feats,2]
f_names = gsub('-mean', 'Mean', f_names)
f_names = gsub('-std', 'Std', f_names)
f_names <- gsub('[-()]', '', f_names)

# Get the training data and extract only the features we're after
myTrain <- read.table("UCI HAR Dataset/train/X_train.txt")
train<-myTrain[,feats]

# Add columns related to which subject it is and which activities they're completing
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

# Get the test dataset and extract only the features we're after
myTest <- read.table("UCI HAR Dataset/test/X_test.txt")
test<-myTest[,feats]

# Add columns related to which subject it is and which activities they're completing
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# Combine training and test sets, and then add in the column headers
myData <- rbind(train, test)
colnames(myData) <- c("subject", "activity", f_names)

# Convert the activity and subject labels into factors and fetch the correct values for the activity labels
myData$activity <- factor(myData$activity, levels = labels[,1], labels = labels[,2])
myData$subject <- as.factor(myData$subject)

# Reshape the data
myData <- melt(myData, id = c("subject", "activity"))
myData <- dcast(myData, subject + activity ~ variable, mean)

# Write output to a file
write.table(myData, "final.txt", row.names = FALSE, quote = FALSE)